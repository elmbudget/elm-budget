module ForgotPassword.Update exposing (..)

import ForgotPassword.Model exposing (..)
import ForgotPassword.Message exposing (..)
import ForgotPassword.Validation exposing (..)


update : Msg -> ForgotPasswordPageModel -> ( ForgotPasswordPageModel, Cmd Msg, Maybe ForgotPasswordData )
update msg model =
    case msg of
        Click data ->
            let
                valid =
                    isValid <| validate model
            in
                ( { model | showValidationErrors = not valid }
                , Cmd.none
                , if valid then
                    Just data
                  else
                    Nothing
                )

        EmailChange text ->
            ( { model | email = text, showValidationErrors = False }, Cmd.none, Nothing )

        Noop ->
            ( model, Cmd.none, Nothing )
