module Signup.Model exposing (..)


type alias SignupPageModel =
    { email : String
    , password : String
    , showValidationErrors : Bool
    }


initialModel : SignupPageModel
initialModel =
    { email = ""
    , password = ""
    , showValidationErrors = False
    }
