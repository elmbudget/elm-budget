module Login.Update exposing (..)

import Login.Model exposing (..)
import Login.Message exposing (..)
import Login.Validation exposing (..)


update : Msg -> LoginPageModel -> ( LoginPageModel, Cmd Msg, Maybe LoginData )
update msg model =
    case msg of
        LoginClick data ->
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

        PasswordChange text ->
            ( { model | password = text, showValidationErrors = False }, Cmd.none, Nothing )

        Noop ->
            ( model, Cmd.none, Nothing )
