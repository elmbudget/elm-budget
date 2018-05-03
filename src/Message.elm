module Message exposing (..)

import Alert
import Transactions.Message
import Accounts.Message
import Categories.Message
import PersistableData exposing (..)
import Date exposing (Date)
import Navigation exposing (Location)
import Signup.Message
import Login.Message
import ForgotPassword.Message
import User exposing (UserData)
import Window


type Msg
    = None
    | Transaction Transactions.Message.Msg
    | Account Accounts.Message.Msg
    | Category Categories.Message.Msg
    | Load (Maybe (List Account)) (Maybe (List Category)) (Maybe (List Transaction)) Bool
    | AlertMsg Alert.Msg
    | HidePopupMessage
    | ShowPopupMessage String Msg
    | HideLoadingModal
    | SetTodaysDate Date
    | UrlChange Location
    | Signup Signup.Message.Msg
    | SignupFail String
    | SignupSuccess
    | SignupSuccessAcknoweldged
    | LoginFail String
    | LoginSuccess UserData
    | Login Login.Message.Msg
    | ForgotPassword ForgotPassword.Message.Msg
    | KickOffLoadData
    | UpdateUser (Maybe UserData)
    | SetUserFromLocalStorage (Maybe UserData)
    | Logout
    | SizeUpdate Window.Size


defaultShowPopupMessage : String -> Msg
defaultShowPopupMessage text =
    ShowPopupMessage text HidePopupMessage


lostConnection : Msg
lostConnection =
    defaultShowPopupMessage "Problem communicating with server. Some information may be lost. Please refresh the browser before entering more information."
