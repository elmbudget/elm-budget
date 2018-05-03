module Signup.View exposing (..)

import Html exposing (Html, div, label, text, input, h1, p, button)
import Html.Attributes exposing (for, type_, id, class, classList, name, value)
import Html.Events exposing (onInput, onClick)
import Helper.SkeletonCss as Skeleton
import Signup.Model exposing (..)
import Signup.Message exposing (..)
import Helper.Html exposing (onKeyDown, keyCodeEnter)
import Signup.Validation exposing (validate, okValidationResult)
import Helper.Core exposing (isJust)


view : SignupPageModel -> Html Msg
view model =
    let
        validationResult =
            if model.showValidationErrors then
                validate model
            else
                okValidationResult

        signupClick =
            SignupClick { email = model.email, password = model.password }

        validationMessageBox : Maybe String -> Html Msg
        validationMessageBox result =
            case result of
                Just msg ->
                    div [ class "validation-error-text" ] [ text msg ]

                _ ->
                    text ""
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
                    [ h1 [] [ text "Sign up for elm budget." ]
                    , p [] [ text "Elm Budget Basic Plan is free forever and totally useful. No credit card required and no silly limitations. Fill in this form to sign up." ]
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
                , Skeleton.col6 []
                    [ label [ for "signup_password" ] [ text "Password" ]
                    , input
                        [ classList
                            [ ( "u-full-width", True )
                            , ( "validation-error", isJust validationResult.passwordInvalidMessage )
                            ]
                        , id "signup_password"
                        , name "signup_password"
                        , type_ "password"
                        , onInput PasswordChange
                        , value model.password
                        ]
                        []
                    , validationMessageBox validationResult.passwordInvalidMessage
                    ]
                ]
            , button [ class "button-primary", onClick <| signupClick ] [ text "Sign Up" ]
            ]
