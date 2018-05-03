module Model exposing (..)

import Alert
import Accounts.Model exposing (..)
import Categories.Model exposing (..)
import Transactions.Model exposing (..)
import PersistableData exposing (..)
import Date exposing (Date)
import Signup.Model exposing (..)
import Login.Model as LM
import Message
import User exposing (UserData)
import Window
import ForgotPassword.Model


type Page
    = HomePage
    | AccountsPage
    | CategoriesPage
    | TransactionsPage
    | SignUpPage
    | LoginPage
    | ForgotPasswordPage
    | ResendConfirmationPage
    | PageNotFound


pageNamer : Page -> String
pageNamer page =
    case page of
        HomePage ->
            "Home"

        AccountsPage ->
            "Accounts"

        TransactionsPage ->
            "Transactions"

        CategoriesPage ->
            "Categories"

        SignUpPage ->
            "Sign Up"

        LoginPage ->
            "Login"

        ForgotPasswordPage ->
            "Forgot Password"

        ResendConfirmationPage ->
            "Resend Email Confirmation"

        PageNotFound ->
            "Not Found"


type LoadingModalState
    = NotLoading
    | Loading { message : LoadingMessage, isFading : Bool }


type LoadingMessage
    = LoadingTransactionData
    | SigningUp
    | LoggingIn


type alias Model =
    { txns : List Transaction
    , accounts : List Account
    , categories : List Category
    , page : Page
    , accountPageModel : AccountPageModel
    , categoryPageModel : CategoryPageModel
    , transactionsPageModel : TransactionsPageModel
    , signupPageModel : SignupPageModel
    , loginPageModel : LM.LoginPageModel
    , forgotPasswordModel : ForgotPassword.Model.ForgotPasswordPageModel
    , resendConfirmationModel : ForgotPassword.Model.ForgotPasswordPageModel
    , alerts : Alert.Model
    , popupMessage : Maybe ( String, Message.Msg )
    , whatsLoaded : WhatsLoaded
    , loadingModal : LoadingModalState
    , today : Date
    , userData : Maybe UserData
    , windowSize : Window.Size
    }


type alias WhatsLoaded =
    { accounts : Bool
    , categories : Bool
    , transactions : Bool
    }


hasLoaded : Model -> Bool
hasLoaded model =
    let
        w =
            model.whatsLoaded
    in
        w.accounts && w.categories && w.transactions
