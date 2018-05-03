module Login.Validation exposing (..)

import Login.Model exposing (LoginPageModel)
import Helper.Core exposing (isNothing)


type alias ValidationResult =
    { emailInvalidMessage : Maybe String
    , passwordInvalidMessage : Maybe String
    }


isValid : ValidationResult -> Bool
isValid result =
    isNothing result.emailInvalidMessage && isNothing result.passwordInvalidMessage


okValidationResult : ValidationResult
okValidationResult =
    { emailInvalidMessage = Nothing, passwordInvalidMessage = Nothing }


validate : LoginPageModel -> ValidationResult
validate model =
    { emailInvalidMessage =
        if model.email == "" then
            Just "Email is required"
        else
            Nothing
    , passwordInvalidMessage =
        if model.password == "" then
            Just "Password is required"
        else
            Nothing
    }
