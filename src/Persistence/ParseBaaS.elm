module Persistence.ParseBaaS exposing (persister, userPersister, logoutUser)

import Backend.ParseBaaSClient exposing (Credentials, RequestBase, init, ParseError(..))
import Persistence.Interface exposing (SessionToken, Persister, BaaSPersister, UserPersister, Save, Get, Update, Delete, SaveUser, LoginUser, LogoutUser, LoginErrorMessage(..))
import Task exposing (Task)
import Http
import Json.Encode as JsonE


persister : Credentials -> SessionToken -> Persister a -> BaaSPersister a
persister creds sessionToken persister =
    let
        requestBase =
            { credentials = creds, maybeSession = Just sessionToken }
    in
        { save = save requestBase persister
        , get = get requestBase persister
        , update = update requestBase persister
        , delete = delete requestBase persister
        }


userPersister : Credentials -> UserPersister
userPersister creds =
    { saveUser = saveUser creds
    , loginUser = loginUser creds
    }


httpErrorMapper : Http.Error -> String
httpErrorMapper err =
    let
        logger =
            Debug.log "application" (toString err)
    in
        "An error occurred communicating with the server. Please check your internet connection."


save : RequestBase -> Persister a -> Save a
save credentials persister object =
    let
        sdk =
            init credentials
    in
        sdk.create
            persister.className
            (persister.encode object)
            |> Task.map (\result -> result.objectId)
            |> Task.mapError httpErrorMapper


logoutUser : Credentials -> SessionToken -> LogoutUser
logoutUser creds sessionToken =
    let
        sdk =
            init { credentials = creds, maybeSession = Just sessionToken }
    in
        sdk.logoutUser


loginUser : Credentials -> LoginUser
loginUser credentials login =
    let
        sdk =
            init { credentials = credentials, maybeSession = Nothing }

        encode l =
            JsonE.object
                [ ( "username", JsonE.string l.username )
                , ( "password", JsonE.string l.password )
                ]
    in
        sdk.loginUser
            login
            |> Task.map (\result -> result.sessionToken)
            |> Task.mapError
                (\err ->
                    case err of
                        ErrorResponse errorMessage ->
                            if errorMessage.code == 205 && errorMessage.error == "User email is not verified." then
                                -- 205 might be overloaded so we check the error message too
                                UserEmailNotVerified
                            else
                                LoginGeneralErrorMessage errorMessage.error

                        ParseErrorHttpError httpError ->
                            LoginGeneralErrorMessage <| httpErrorMapper httpError
                )


saveUser : Credentials -> SaveUser
saveUser credentials user =
    let
        sdk =
            init { credentials = credentials, maybeSession = Nothing }

        encodeUser u =
            JsonE.object
                [ ( "username", JsonE.string (String.toLower u.username) )
                , ( "password", JsonE.string u.password )
                , ( "email", JsonE.string (String.toLower u.username) )
                ]
    in
        sdk.createUser
            (encodeUser user)
            |> Task.map (\result -> result.objectId)
            |> Task.mapError
                (\err ->
                    case err of
                        ErrorResponse errorMessage ->
                            errorMessage.error

                        ParseErrorHttpError httpError ->
                            httpErrorMapper httpError
                )


update : RequestBase -> Persister a -> Update a
update credentials persister key object =
    let
        sdk =
            init credentials
    in
        sdk.update
            persister.className
            key
            (persister.encode object)
            |> Task.map (\result -> ())
            |> Task.mapError httpErrorMapper


get : RequestBase -> Persister a -> Get a
get credentials persister clauses =
    let
        sdk =
            init credentials

        queryJson =
            JsonE.object (List.map (\clause -> ( clause.fieldName, clause.value )) clauses)
    in
        sdk.query
            persister.className
            [ ( "where", queryJson ) ]
            persister.decoder
            |> Task.mapError httpErrorMapper


delete : RequestBase -> Persister a -> Delete
delete credentials persister key =
    let
        sdk =
            init credentials
    in
        sdk.delete
            persister.className
            key
            |> Task.mapError httpErrorMapper
