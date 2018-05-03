module ForgotPassword.View exposing (..)

import Html exposing (Html, div, label, text, input, h1, p, button)
import Html.Attributes exposing (for, type_, id, class, classList, name, value)
import Html.Events exposing (onInput, onClick)
import Helper.SkeletonCss as Skeleton
import ForgotPassword.Model exposing (..)
import ForgotPassword.Message exposing (..)
import Helper.Html exposing (onKeyDown, keyCodeEnter)
import ForgotPassword.Validation exposing (validate, okValidationResult)
import Helper.Core exposing (isJust)


view : Mode -> ForgotPasswordPageModel -> Html Msg
view mode model =
    let
        validationResult =
            if model.showValidationErrors then
                validate model
            else
                okValidationResult

        signupClick =
            Click { email = model.email }

        validationMessageBox : Maybe String -> Html Msg
        validationMessageBox result =
            case result of
                Just msg ->
                    div [ class "validation-error-text" ] [ text msg ]

                _ ->
                    text ""

        headerText =
            case mode of
                ForgotPasswordMode ->
                    "Forgot Password"

                ResendConfirmationMode ->
                    "Resend Email Confirmation"

        paraText =
            case mode of
                ForgotPasswordMode ->
                    "Enter your email below if you need to reset your password."

                ResendConfirmationMode ->
                    "Enter you email below to be sent your email confirmation again."
    in
        div
            [ onKeyDown
                (\k ->
                    if k == keyCodeEnter then
                        signupClick
                    else
                        Noop
                )
            ]
            [ Skeleton.row []
                [ Skeleton.col12 []
                    [ h1 [] [ text headerText ]
                    , p [] [ text paraText ]
                    ]
                ]
            , Skeleton.row []
                [ Skeleton.col6 []
                    [ label [ for "signup_email" ] [ text "Email Address" ]
                    , input
                        [ classList
                            [ ( "u-full-width", True )
                            , ( "validation-error", isJust validationResult.emailInvalidMessage )
                            ]
                        , id "signup_email"
                        , name "signup_email"
                        , type_ "text"
                        , onInput EmailChange
                        , value model.email
                        ]
                        []
                    , validationMessageBox validationResult.emailInvalidMessage
                    ]
                ]
            , button [ class "button-primary", onClick <| signupClick ] [ text "Submit" ]
            ]
