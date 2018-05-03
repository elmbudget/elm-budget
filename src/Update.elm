module Update exposing (..)

import Update.Extra as UE
import Alert
import Message exposing (..)
import Model exposing (..)
import Accounts.Update
import Categories.Update
import Transactions.Update
import ProgramData exposing (ProgramData, Persisters, getPersisters, getUserPersister, getLogout)
import Helper.Core exposing (delay, isJust)
import Time
import Nav exposing (..)
import Helper.Task as TaskH
import Signup.Update
import Login.Update
import Navigation
import Helper.Html exposing (focus)
import Tuple exposing (first, second)
import Login.Model
import Signup.Model
import Ports exposing (..)
import Persistence.Interface exposing (LoginErrorMessage(..))
import Transactions.Common exposing (defaultPreset)


andThen : ProgramData -> Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen programData msg ( model, cmd ) =
    let
        ( newmodel, newcmd ) =
            update programData msg model
    in
        newmodel ! [ cmd, newcmd ]


withCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withCmd cmd2 ( model, cmd1 ) =
    model ! [ cmd1, cmd2 ]


update : ProgramData -> Message.Msg -> Model -> ( Model, Cmd Message.Msg )
update programData msg model =
    let
        hideModalCommand =
            delay (0.5 * Time.second) HideLoadingModal

        andThen_ =
            andThen programData

        persistersIfLoggedIn =
            model.userData |> Maybe.map (\userData -> getPersisters programData.credentials userData.sessionToken)

        userPersister =
            getUserPersister programData.credentials

        withMaybe f m =
            Maybe.map f m |> Maybe.withDefault ( model, Cmd.none )

        withPersister f =
            persistersIfLoggedIn |> withMaybe f
    in
        case msg of
            None ->
                ( model, Cmd.none )

            Message.Transaction txnMsg ->
                withPersister
                    (\persisters ->
                        let
                            ( newTransactionsPageModel, newTxns, txnCmd, topMsg ) =
                                Transactions.Update.update model.today persisters txnMsg model.transactionsPageModel model.txns
                        in
                            --( model, Cmd.none )
                            ( { model | transactionsPageModel = newTransactionsPageModel, txns = newTxns }, Cmd.map Message.Transaction txnCmd )
                                |> UE.andThen (update programData) topMsg
                    )

            Message.Account accMsg ->
                withPersister
                    (\persisters ->
                        let
                            ( newAccountPageModel, newAccounts, newTxns, accCmd, topMsg ) =
                                Accounts.Update.update persisters accMsg model.accountPageModel model.accounts model.txns
                        in
                            ( { model | accountPageModel = newAccountPageModel, accounts = newAccounts, txns = newTxns }, Cmd.map Message.Account accCmd )
                                |> UE.andThen (update programData) topMsg
                    )

            Message.Category catMsg ->
                withPersister
                    (\persisters ->
                        let
                            ( newCategoryPageModel, newCategories, newTxns, catCmd, topMsg ) =
                                Categories.Update.update persisters catMsg model.categoryPageModel model.categories model.txns
                        in
                            ( { model | categoryPageModel = newCategoryPageModel, categories = newCategories, txns = newTxns }, Cmd.map Message.Category catCmd )
                                |> UE.andThen (update programData) topMsg
                    )

            Load maybeAccounts maybeCategories maybeTransactions hasFailures ->
                let
                    accounts =
                        Maybe.withDefault model.accounts maybeAccounts

                    categories =
                        Maybe.withDefault model.categories maybeCategories

                    transactions =
                        Maybe.withDefault model.txns maybeTransactions

                    whatsLoaded =
                        model.whatsLoaded

                    debug =
                        if hasFailures then
                            Debug.log "app" "Some data failed to load. Please check your transactions and accounts"
                        else
                            ""

                    newModel =
                        { model
                            | accounts = accounts
                            , categories = categories
                            , txns = transactions
                            , loadingModal = Loading { message = LoadingTransactionData, isFading = False }
                            , whatsLoaded =
                                { whatsLoaded
                                    | accounts = whatsLoaded.accounts || isJust maybeAccounts
                                    , categories = whatsLoaded.categories || isJust maybeCategories
                                    , transactions = whatsLoaded.transactions || isJust maybeTransactions
                                }
                        }
                in
                    if Model.hasLoaded newModel then
                        ( { newModel | loadingModal = Loading { message = LoadingTransactionData, isFading = True } }
                        , hideModalCommand
                        )
                    else
                        ( newModel, Cmd.none )

            AlertMsg alertMsg ->
                let
                    ( alerts, cmd ) =
                        Alert.update alertMsg model.alerts
                in
                    ( { model | alerts = alerts }, Cmd.map AlertMsg cmd )

            HidePopupMessage ->
                ( { model | popupMessage = Nothing }, Cmd.none )

            ShowPopupMessage s m ->
                ( { model | popupMessage = Just ( s, m ) }, focus "modal-ok" None )

            HideLoadingModal ->
                ( { model | loadingModal = NotLoading }, Cmd.none )

            SetTodaysDate date ->
                let
                    tpm =
                        model.transactionsPageModel
                in
                    ( { model | today = date, transactionsPageModel = { tpm | datePreset = defaultPreset date } }, Cmd.none )

            UrlChange location ->
                urlUpdate location { model | signupPageModel = Signup.Model.initialModel, loginPageModel = Login.Model.initialModel }

            LoginFail msg ->
                update programData HideLoadingModal model
                    |> andThen_ (defaultShowPopupMessage msg)

            SignupFail msg ->
                update programData HideLoadingModal model
                    |> andThen_ (defaultShowPopupMessage msg)

            LoginSuccess userData ->
                let
                    newPage =
                        case model.page of
                            LoginPage ->
                                HomePage

                            x ->
                                x
                in
                    update programData HideLoadingModal model
                        |> andThen_ (UpdateUser (Just userData))
                        |> andThen_ KickOffLoadData
                        |> withCmd (navigateTo newPage)

            UpdateUser maybeUser ->
                ( { model | userData = maybeUser }, storeUser maybeUser )

            SetUserFromLocalStorage maybeUser ->
                ( { model | userData = maybeUser }, Cmd.none )
                    |> andThen_ KickOffLoadData

            KickOffLoadData ->
                withPersister (\persisters -> ( model, loadAllData persisters ))

            SignupSuccess ->
                update programData HideLoadingModal model
                    |> andThen_
                        (ShowPopupMessage
                            "You have been signed up. To log in, please check your email and open the confirmation link."
                            SignupSuccessAcknoweldged
                        )

            SignupSuccessAcknoweldged ->
                ( model, navigateTo LoginPage )
                    |> andThen_ HidePopupMessage

            Signup msg ->
                let
                    ( newSignupPageModel, cmd, action ) =
                        Signup.Update.update msg model.signupPageModel

                    newModelBase =
                        { model | signupPageModel = newSignupPageModel }

                    newModel =
                        case action of
                            Just _ ->
                                { newModelBase
                                    | loadingModal = Loading { message = SigningUp, isFading = False }
                                    , signupPageModel = Signup.Model.initialModel
                                }

                            _ ->
                                newModelBase

                    commands =
                        Cmd.map Signup cmd
                            :: case action of
                                Just data ->
                                    [ userPersister.saveUser { username = data.email, password = data.password }
                                        |> TaskH.attempt2 SignupFail (always SignupSuccess)
                                    ]

                                _ ->
                                    []
                in
                    ( newModel
                    , Cmd.batch commands
                    )

            Login msg ->
                let
                    ( newLoginPageModel, cmd, action ) =
                        Login.Update.update msg model.loginPageModel

                    newModelBase =
                        { model | loginPageModel = newLoginPageModel }

                    newModel =
                        case action of
                            Just _ ->
                                { newModelBase
                                    | loadingModal = Loading { message = LoggingIn, isFading = False }
                                    , loginPageModel = Login.Model.initialModel
                                }

                            _ ->
                                newModelBase

                    commands =
                        Cmd.map Login cmd
                            :: case action of
                                Just data ->
                                    [ userPersister.loginUser { username = data.email, password = data.password }
                                        |> TaskH.attempt2
                                            (\err ->
                                                LoginFail <|
                                                    case err of
                                                        LoginGeneralErrorMessage msg ->
                                                            msg

                                                        UserEmailNotVerified ->
                                                            "You need to verify your email before you login. Please check your inbox for a verification email. Otherwise click here to have it sent again."
                                            )
                                            (\token -> LoginSuccess { sessionToken = token, username = data.email })
                                    ]

                                _ ->
                                    []
                in
                    ( newModel
                    , Cmd.batch commands
                    )

            Logout ->
                model.userData
                    |> withMaybe
                        (\userData ->
                            ( model
                            , getLogout programData.credentials userData.sessionToken
                                |> TaskH.attempt2 (always None) (always None)
                            )
                        )
                    |> andThen_ (UpdateUser Nothing)

            SizeUpdate size ->
                ( { model | windowSize = size }, Cmd.none )

            ForgotPassword _ ->
                ( model, Cmd.none )


loadAllData : Persisters -> Cmd Msg
loadAllData persisters =
    let
        atfn =
            TaskH.attempt2 (always Message.lostConnection)
    in
        Cmd.batch <|
            [ persisters.accountBaaSPersister.get [] |> atfn (\data -> Load (Just (first data)) Nothing Nothing (second data))
            , persisters.categoryBaaSPersister.get [] |> atfn (\data -> Load Nothing (Just (first data)) Nothing (second data))
            , persisters.transactionBaaSPersister.get [] |> atfn (\data -> Load Nothing Nothing (Just (first data)) (second data))
            ]
