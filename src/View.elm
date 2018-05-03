module View exposing (..)

import Alert
import Html exposing (Html, div, h1, h2, text, p, button, span, img, a, figure, figcaption)
import Helper.Html exposing (textHtml)
import Html.Attributes exposing (class, id, href, alt, src)
import Html.Events exposing (onClick)
import Model exposing (..)
import Message exposing (..)
import Helper.Html exposing (navi, onChange)
import Transactions.View
import Accounts.View
import Categories.View
import Nav exposing (routeGenerator)
import Helper.SkeletonCss as Skeleton
import Signup.View
import Helper.Core exposing (isJust)
import Login.View
import ForgotPassword.View
import ForgotPassword.Model

introText : Html Msg
introText =
    Skeleton.row [ class "intro" ]
        [ Skeleton.col12 []
            [ img [ src "img/hero.jpg", alt "banner image", class "hero" ] []
            , h1 [] [ text "Free Budgeting Online" ]
            , p [] [ text "Elm Budget is an easy to use money management tool that lets you record transactions and categorise what you spend. You can use it on desktop, laptop and mobile devices." ]
            , p [] [ text "I am working on adding new features and plan to add budgeting, expense reports and bank imports soon." ]
            , p [] [ text "Elm Budget is currently free to use (up to 5000 transactions). There is no premium plan yet, but I'll consider adding one in the future." ]
            , p []
                [ a [ href "#signup" ] [ text "Click here to Sign Up" ]
                , text ", or if you already have an account, "
                , a [ href "#login" ] [ text "click here to Log In." ]
                ]
            , h2 [] [ text "Screenshots" ]
            , p []
                [ figure [ class "screenshot1" ]
                    [ img [ src "img/home-screenshot-1.png", alt "Screenshot of transactions page on a mobile device" ] []
                    , figcaption [] [ text "Mobile Transactions Screenshot" ]
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    let
        isLoggedIn =
            isJust model.userData

        notLoggedInMessage =
            p []
                [ text "You need to log in to view this page. "
                , a [ href "#login" ] [ text "Click here" ]
                , text " to log in."
                ]

        requiresLogin inner =
            if isLoggedIn then
                inner
            else
                notLoggedInMessage

        viewPort =
            if model.windowSize.width < 1300 then
                Helper.Html.Mobile
            else
                Helper.Html.Desktop
    in
        Skeleton.container [] <|
            [ img [ src "img/logo.png", alt "logo image", class "logo" ] []
            , Html.map AlertMsg <| Alert.view model.alerts
            , (case model.userData of
                Nothing ->
                    text ""

                Just user ->
                    div [ class "loginarea" ] [ text <| "Logged in as " ++ user.username, button [ onClick Logout ] [ text "Log Out" ] ]
              )
            , topNavigation isLoggedIn model
            ]
                ++ (case model.page of
                        HomePage ->
                            if isLoggedIn then
                                [ text "This is home page" ]
                            else
                                [ introText ]

                        AccountsPage ->
                            [ requiresLogin <| Html.map Message.Account (Accounts.View.view viewPort model.accountPageModel model.accounts) ]

                        CategoriesPage ->
                            [ requiresLogin <| Html.map Message.Category (Categories.View.view viewPort model.categoryPageModel model.categories) ]

                        TransactionsPage ->
                            [ requiresLogin <| Html.map Message.Transaction (Transactions.View.view viewPort model.today model.accounts model.categories model.txns model.transactionsPageModel) ]

                        SignUpPage ->
                            [ Html.map Message.Signup (Signup.View.view model.signupPageModel) ]

                        LoginPage ->
                            [ Html.map Message.Login (Login.View.view model.loginPageModel) ]

                        ForgotPasswordPage ->
                            [ Html.map Message.ForgotPassword (ForgotPassword.View.view ForgotPassword.Model.ForgotPasswordMode model.forgotPasswordModel) ]

                        ResendConfirmationPage ->
                            [ Html.map Message.ForgotPassword (ForgotPassword.View.view ForgotPassword.Model.ResendConfirmationMode model.resendConfirmationModel) ]

                        PageNotFound ->
                            [ text "Page Not Found" ]
                   )
                ++ [ case model.popupMessage of
                        Just ( text, msg ) ->
                            popupMessageModal text msg

                        Nothing ->
                            text ""
                   , case model.loadingModal of
                        NotLoading ->
                            text ""

                        Loading loadData ->
                            loadingModal loadData.message loadData.isFading
                   ]


topNavigation : Bool -> Model -> Html Msg
topNavigation isLoggedIn m =
    navi "navigation"
        m.page
        (\page -> "#" ++ (routeGenerator page))
        pageNamer
        (if isLoggedIn then
            [ HomePage, AccountsPage, CategoriesPage, TransactionsPage ]
         else
            [ HomePage, SignUpPage, LoginPage ]
        )


loadingModal : LoadingMessage -> Bool -> Html Msg
loadingModal loadingMessage fade =
    let
        message =
            case loadingMessage of
                LoadingTransactionData ->
                    "Please wait, loading transaction data..."

                SigningUp ->
                    "Please wait, signing up..."

                LoggingIn ->
                    "Please wait, logging in..."
    in
        modal fade <| div [] [ p [] [ text message ], div [ class "loader" ] [] ]


modal : Bool -> Html Msg -> Html Msg
modal fade h =
    div
        [ class <|
            "modal"
                ++ (if fade then
                        " fadeout"
                    else
                        ""
                   )
        ]
        [ div [ class "modal-content", id "modal" ]
            [ h
            ]
        ]


popupMessageModal : String -> Msg -> Html Msg
popupMessageModal textToShow msg =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ span [ class "close" ] [ textHtml "&times;" ]
            , p [] [ text textToShow ]
            , div [ class "confirmation-buttons" ]
                [ button [ onClick msg, id "modal-ok" ] [ text "OK" ]
                ]
            ]
        ]
