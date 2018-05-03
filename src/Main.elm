module Main exposing (..)

import Alert
import Model exposing (..)
import Message exposing (..)
import Update exposing (update, andThen)
import View exposing (view)
import ProgramData exposing (programData, credentials, getPersisters)
import DatePicker
import Task
import Date
import Time
import Navigation
import Nav exposing (..)
import Ports exposing (..)
import User exposing (UserData, decoder)
import Json.Decode as D
import Helper.Core exposing (mapBoth, isJust)
import Window


main : Program Flags Model Msg
main =
    let
        ( datePicker, datePickerCmd ) =
            DatePicker.init

        andThen_ =
            andThen programData
    in
        Navigation.programWithFlags UrlChange
            { init =
                \flags location ->
                    let
                        page =
                            locationToPage location |> Maybe.withDefault PageNotFound

                        maybeUser =
                            D.decodeString decoder flags.rawUserData
                                |> mapBoth (always Nothing) Just

                        model =
                            { initialModel | page = page, userData = maybeUser }

                        cmds =
                            [ todayCmd, getSizeCmd, setTitle <| pageNamer page ]
                    in
                        if isJust maybeUser then
                            ({ model | loadingModal = Loading { message = LoadingTransactionData, isFading = False } } ! cmds) |> andThen_ KickOffLoadData
                        else
                            model ! cmds
            , view = view
            , update = update programData
            , subscriptions = subscriptions
            }


initialModel : Model
initialModel =
    { txns = []
    , accounts = []
    , categories = []
    , page = HomePage
    , accountPageModel =
        { editingAccountRow = Nothing
        , confirmDeleteKey = Nothing
        , nextFakeId = 0
        }
    , categoryPageModel =
        { editingCategoryRow = Nothing
        , confirmDeleteKey = Nothing
        , nextFakeId = 0
        }
    , transactionsPageModel =
        { editingTransaction = Nothing
        , confirmDeleteKey = Nothing
        , nextFakeId = 0
        , selectedAccountKey = ""
        , datePreset = "" -- to be updated
        , showBalancesOnMobile = False
        }
    , alerts = Alert.initModel True
    , popupMessage = Nothing
    , whatsLoaded = { accounts = False, categories = False, transactions = False }
    , loadingModal = NotLoading
    , today = Date.fromTime 0 -- to be updated
    , signupPageModel = { email = "", password = "", showValidationErrors = False }
    , loginPageModel = { email = "", password = "", showValidationErrors = False }
    , forgotPasswordModel = { email = "", showValidationErrors = False }
    , resendConfirmationModel = { email = "", showValidationErrors = False }
    , userData = Nothing
    , windowSize = { width = 0, height = 0 }
    }


todayCmd : Cmd Msg
todayCmd =
    Task.perform (\t -> SetTodaysDate (Date.fromTime t)) Time.now


getSizeCmd : Cmd Msg
getSizeCmd =
    Window.size
        |> Task.attempt
            (\result ->
                case result of
                    Ok size ->
                        SizeUpdate size

                    _ ->
                        None
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Message.AlertMsg <| Alert.subscriptions model.alerts
        , onUserChange (\u -> SetUserFromLocalStorage (Just u)) None
        , Window.resizes SizeUpdate
        ]


type alias Flags =
    { rawUserData : String }
