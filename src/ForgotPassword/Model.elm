module ForgotPassword.Model exposing (..)


type alias ForgotPasswordPageModel =
    { email : String
    , showValidationErrors : Bool
    }


type Mode
    = ForgotPasswordMode
    | ResendConfirmationMode


initialModel : ForgotPasswordPageModel
initialModel =
    { email = ""
    , showValidationErrors = False
    }
