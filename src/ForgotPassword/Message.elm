module ForgotPassword.Message exposing (..)


type alias ForgotPasswordData =
    { email : String
    }


type Msg
    = Click ForgotPasswordData
    | EmailChange String
    | Noop
