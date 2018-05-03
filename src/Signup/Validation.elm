module Signup.Validation exposing (..)

import Signup.Model exposing (SignupPageModel)
import Helper.Core exposing (isNothing)
import Regex
import Helper.Regex


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


validate : SignupPageModel -> ValidationResult
validate model =
    { emailInvalidMessage =
        if model.email == "" then
            Just "Email is required"
        else if Regex.contains Helper.Regex.email model.email then
            Nothing
        else
            Just "Email is invalid"
    , passwordInvalidMessage =
        if model.password == "" then
            Just "Password is required"
        else
            Nothing
    }
