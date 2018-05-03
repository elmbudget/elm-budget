module Login.Message exposing (..)


type alias LoginData =
    { email : String
    , password : String
    }


type Msg
    = LoginClick LoginData
    | EmailChange String
    | PasswordChange String
    | Noop
