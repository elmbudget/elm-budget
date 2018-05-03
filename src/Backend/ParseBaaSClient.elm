module Backend.ParseBaaSClient
    exposing
        ( init
        , Credentials
        , ParseSdk
        , CreateResponse
        , UpdateResponse
        , CreateUser
        , ParseError(..)
        , RequestBase
        )

import Http
import Json.Encode as JsonE
import Json.Decode as JsonD
import String
import Date exposing (Date)
import Task exposing (Task)
import QueryString as QS
import Helper.Decoder exposing (dropBadDecoder)
import Helper.Core exposing (..)


-- TYPES


type alias Create =
    String -> JsonE.Value -> Task Http.Error CreateResponse


type ParseError
    = ErrorResponse { code : Int, error : String }
    | ParseErrorHttpError Http.Error


type alias CreateUser =
    JsonE.Value -> Task ParseError CreateResponse


type alias LoginData =
    { username : String
    , password : String
    }


type alias LoginUser =
    LoginData -> Task ParseError LoginSuccessResult


type alias LogoutUser =
    Task () ()


type alias LoginSuccessResult =
    { sessionToken : String
    }


type alias Query doc =
    String -> List ( String, JsonE.Value ) -> JsonD.Decoder doc -> Task Http.Error ( List doc, Bool )


type alias Get doc msg =
    String -> String -> JsonD.Decoder doc -> (Result Http.Error doc -> msg) -> Cmd msg


type alias Update =
    String -> String -> JsonE.Value -> Task Http.Error UpdateResponse


type alias Delete =
    String -> String -> Task Http.Error ()


type alias ParseSdk doc msg =
    { create : Create
    , query : Query doc
    , get : Get doc msg
    , update : Update
    , delete : Delete
    , createUser : CreateUser
    , loginUser : LoginUser
    , logoutUser : LogoutUser
    }


type alias Credentials =
    { appId : String
    , apiKey : String
    , url : String
    }


type alias RequestBase =
    { credentials : Credentials
    , maybeSession : Maybe String
    }



-- HELPERS


headers : RequestBase -> List Http.Header
headers req =
    [ Http.header "X-Parse-Application-Id" req.credentials.appId
    , Http.header "X-Parse-REST-API-Key" req.credentials.apiKey
    ]
        ++ (req.maybeSession |> Maybe.map (\session -> [ Http.header "X-Parse-Session-Token" session ]) |> Maybe.withDefault [])


removeTrailingSlash : String -> String
removeTrailingSlash url =
    if String.endsWith "/" url then
        String.slice 0 ((String.length url) - 1) url
    else
        url


trailingSlash : String -> String
trailingSlash url =
    if String.endsWith "/" url then
        url
    else
        url ++ "/"


appendToURL : String -> String -> String
appendToURL url str =
    trailingSlash <| (trailingSlash url) ++ str


pathURL : String -> List String -> String
pathURL url pathList =
    List.foldl (flip appendToURL) url pathList



-- USERS


decodeErrorMessage : JsonD.Decoder ParseError
decodeErrorMessage =
    JsonD.map2
        (\code error -> ErrorResponse { code = code, error = error })
        (JsonD.field "code" JsonD.int)
        (JsonD.field "error" JsonD.string)


logoutUser : RequestBase -> LogoutUser
logoutUser requestBase =
    Http.toTask
        (Http.request
            { method = "POST"
            , headers = headers { credentials = requestBase.credentials, maybeSession = requestBase.maybeSession }
            , expect = Http.expectStringResponse (\_ -> Ok ())
            , url = pathURL requestBase.credentials.url [ "logout" ]
            , timeout = Nothing
            , withCredentials = False
            , body = Http.emptyBody
            }
        )
        |> Task.mapError
            (\err ->
                ()
            )


loginUser : Credentials -> LoginUser
loginUser credentials login =
    let
        queryString =
            QS.empty
                |> QS.add "username" (String.toLower login.username)
                |> QS.add "password" login.password

        decodeLoginSuccessResult =
            JsonD.map LoginSuccessResult (JsonD.field "sessionToken" JsonD.string)
    in
        Http.toTask
            (Http.request
                { method = "GET"
                , headers = headers { credentials = credentials, maybeSession = Nothing }
                , expect = Http.expectJson decodeLoginSuccessResult
                , url = pathURL credentials.url [ "login" ] ++ (QS.render queryString)
                , timeout = Nothing
                , withCredentials = False
                , body = Http.emptyBody
                }
            )
            |> Task.mapError
                (\err ->
                    case err of
                        Http.BadStatus response ->
                            JsonD.decodeString decodeErrorMessage response.body
                                |> mapBoth
                                    -- If can't parse error reason then pass through as generic Http Error
                                    (always <| ParseErrorHttpError err)
                                    identity

                        _ ->
                            ParseErrorHttpError err
                )


createUser : Credentials -> CreateUser
createUser credentials value =
    Http.toTask
        (Http.request
            { method = "POST"
            , headers = headers { credentials = credentials, maybeSession = Nothing }
            , expect = Http.expectJson createResponseDecoder
            , url = pathURL credentials.url [ "users" ]
            , timeout = Nothing
            , withCredentials = False
            , body = Http.stringBody "application/json" <| JsonE.encode 0 value
            }
        )
        |> Task.mapError
            (\err ->
                case err of
                    Http.BadStatus response ->
                        JsonD.decodeString decodeErrorMessage response.body
                            |> mapBoth
                                -- If can't parse error reason then pass through as generic Http Error
                                (always <| ParseErrorHttpError err)
                                identity

                    _ ->
                        ParseErrorHttpError err
            )



-- OBJECTS


type alias CreateResponse =
    { createdAt : Date, objectId : String }


createResponseDecoder : JsonD.Decoder CreateResponse
createResponseDecoder =
    JsonD.map2 CreateResponse (JsonD.field "createdAt" JsonD.string |> JsonD.map (\s -> Date.fromTime 0)) (JsonD.field "objectId" JsonD.string)


create : RequestBase -> Create
create requestBase class value =
    Http.toTask
        (Http.request
            { method = "POST"
            , headers = headers requestBase
            , expect = Http.expectJson createResponseDecoder
            , url = pathURL requestBase.credentials.url [ "classes", class ]
            , timeout = Nothing
            , withCredentials = False
            , body = Http.stringBody "application/json" <| JsonE.encode 0 value
            }
        )


type alias UpdateResponse =
    { updatedAt : Date }


updateResponseDecoder : JsonD.Decoder UpdateResponse
updateResponseDecoder =
    JsonD.map UpdateResponse (JsonD.field "updatedAt" JsonD.string |> JsonD.map (\s -> Date.fromTime 0))


update : RequestBase -> Update
update requestBase class key value =
    Http.toTask
        (Http.request
            { method = "PUT"
            , headers = headers requestBase
            , expect = Http.expectJson updateResponseDecoder
            , url = (pathURL requestBase.credentials.url [ "classes", class, key ])
            , timeout = Nothing
            , withCredentials = False
            , body = Http.stringBody "application/json" <| JsonE.encode 0 value
            }
        )


delete : RequestBase -> Delete
delete requestBase class key =
    Http.toTask
        (Http.request
            { method = "DELETE"
            , headers = headers requestBase
            , expect = Http.expectStringResponse (\_ -> Ok ())
            , url = (removeTrailingSlash <| pathURL requestBase.credentials.url [ "classes", class, key ])
            , timeout = Nothing
            , withCredentials = False
            , body = Http.emptyBody
            }
        )


{-| <http://parse.com/docs/rest/guide#queries-query-constraints>
NOTE: Not used yet
-}
type alias Options =
    { order : Maybe (List String)
    , limit : Maybe Int
    , skip : Maybe Int
    , keys : Maybe (List String)
    , include : Maybe (List String)
    , count : Bool
    }


query : RequestBase -> Query doc
query requestBase class query decoder =
    let
        queryString =
            List.foldl (\( key, value ) queryString -> queryString |> QS.add key (JsonE.encode 0 value)) QS.empty query
    in
        Http.toTask
            (Http.request
                { method = "GET"
                , headers = Http.header "Content-Type" "application/json" :: headers requestBase
                , expect = Http.expectJson <| JsonD.field "results" (dropBadDecoder decoder)
                , url = pathURL requestBase.credentials.url [ "classes", class ] ++ (QS.render queryString)
                , timeout = Nothing
                , withCredentials = False
                , body = Http.emptyBody
                }
            )


get : RequestBase -> Get doc msg
get requestBase class objectId decoder onResult =
    Http.send
        onResult
        (Http.request
            { method = "GET"
            , headers = Http.header "Content-Type" "application/json" :: headers requestBase
            , expect = Http.expectJson decoder
            , url = pathURL requestBase.credentials.url [ "classes", class ]
            , timeout = Nothing
            , withCredentials = False
            , body = Http.emptyBody
            }
        )


init : RequestBase -> ParseSdk doc msg
init requestBase =
    { create = create requestBase
    , query = query requestBase
    , get = get requestBase
    , update = update requestBase
    , delete = delete requestBase
    , createUser = createUser requestBase.credentials
    , loginUser = loginUser requestBase.credentials
    , logoutUser = logoutUser requestBase
    }
