module Nav exposing (..)

import Navigation
import Model exposing (..)
import Message exposing (..)
import UrlParser
import Ports exposing (setTitle)


navigateTo : Page -> Cmd msg
navigateTo p =
    Navigation.newUrl ("#" ++ (routeGenerator p))


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    case locationToPage location of
        Nothing ->
            ( { model | page = PageNotFound }, setTitle <| pageNamer PageNotFound )

        Just p ->
            ( { model | page = p }, setTitle <| pageNamer p )


locationToPage : Navigation.Location -> Maybe Page
locationToPage location =
    UrlParser.parseHash routeParser location


routeParser : UrlParser.Parser (Page -> a) a
routeParser =
    let
        viaGen page =
            UrlParser.map page (UrlParser.s <| routeGenerator page)
    in
        UrlParser.oneOf
            [ UrlParser.map HomePage UrlParser.top
            , viaGen AccountsPage
            , viaGen CategoriesPage
            , viaGen TransactionsPage
            , viaGen SignUpPage
            , viaGen ForgotPasswordPage
            , viaGen ResendConfirmationPage
            ]


routeGenerator : Page -> String
routeGenerator page =
    case page of
        HomePage ->
            ""

        AccountsPage ->
            "accounts"

        CategoriesPage ->
            "categories"

        TransactionsPage ->
            "transactions"

        SignUpPage ->
            "signup"

        LoginPage ->
            "login"

        ForgotPasswordPage ->
            "forgotpassword"

        ResendConfirmationPage ->
            "resendconfirmation"

        _ ->
            ""
