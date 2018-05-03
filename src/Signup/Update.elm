module Signup.Update exposing (..)

import Signup.Model exposing (..)
import Signup.Message exposing (..)
import Signup.Validation exposing (..)


update : Msg -> SignupPageModel -> ( SignupPageModel, Cmd Msg, Maybe SignupData )
update msg model =
    case msg of
        SignupClick data ->
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
