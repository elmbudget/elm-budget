module Login.View exposing (..)

import Html exposing (Html, div, label, text, input, h1, p, button, a)
import Html.Attributes exposing (for, type_, id, class, classList, href, name, value)
import Html.Events exposing (onInput, onClick)
import Helper.SkeletonCss as Skeleton
import Login.Model exposing (..)
import Login.Message exposing (..)
import Helper.Html exposing (onKeyDown, keyCodeEnter)
import Login.Validation exposing (validate, okValidationResult)
import Helper.Core exposing (isJust)


view : LoginPageModel -> Html Msg
view model =
    let
        validationResult =
            if model.showValidationErrors then
                validate model
            else
                okValidationResult

        loginClick =
            LoginClick { email = model.email, password = model.password }

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
                        loginClick
                    else
                        Noop
                )
            ]
            [ Skeleton.row []
                [ Skeleton.col12 []
                    [ h1 [] [ text "Log in" ]
                    , p []
                        [ text "Please enter your username and password to log in. If you haven't signed up, "
                        , a [ href "#signup" ] [ text "click here" ]
                        , text " to sign up."
                        ]
                    ]
                ]
            , Skeleton.row []
                [ Skeleton.col6 []
                    [ label [ for "login_email" ] [ text "Email Address" ]
                    , input
                        [ classList
                            [ ( "u-full-width", True )
                            , ( "validation-error", isJust validationResult.emailInvalidMessage )
                            ]
                        , id "login_email"
                        , name "login_email"
                        , type_ "text"
                        , onInput EmailChange
                        , value model.email
                        ]
                        []
                    , validationMessageBox validationResult.emailInvalidMessage
                    ]
                , Skeleton.col6 []
                    [ label [ for "login_password" ] [ text "Password" ]
                    , input
                        [ classList
                            [ ( "u-full-width", True )
                            , ( "validation-error", isJust validationResult.passwordInvalidMessage )
                            ]
                        , id "login_password"
                        , name "login_password"
                        , type_ "password"
                        , onInput PasswordChange
                        , value model.password
                        ]
                        []
                    , validationMessageBox validationResult.passwordInvalidMessage
                    ]
                ]
            , button [ class "button-primary", onClick <| loginClick ] [ text "Log in" ]
            ]
