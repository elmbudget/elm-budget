module Signup.Message exposing (..)


type alias SignupData =
    { email : String
    , password : String
    }


type Msg
    = SignupClick SignupData
    | EmailChange String
    | PasswordChange String
    | Noop
