module ForgotPassword.Validation exposing (..)

import ForgotPassword.Model exposing (ForgotPasswordPageModel)
import Helper.Core exposing (isNothing)
import Regex
import Helper.Regex


type alias ValidationResult =
    { emailInvalidMessage : Maybe String
    }


isValid : ValidationResult -> Bool
isValid result =
    isNothing result.emailInvalidMessage


okValidationResult : ValidationResult
okValidationResult =
    { emailInvalidMessage = Nothing }


validate : ForgotPasswordPageModel -> ValidationResult
validate model =
    { emailInvalidMessage =
        if model.email == "" then
            Just "Email is required"
        else if Regex.contains Helper.Regex.email model.email then
            Nothing
        else
            Just "Email is invalid"
    }
