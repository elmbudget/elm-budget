module Login.Model exposing (..)


type alias LoginPageModel =
    { email : String
    , password : String
    , showValidationErrors : Bool
    }


initialModel : LoginPageModel
initialModel =
    { email = ""
    , password = ""
    , showValidationErrors = False
    }
