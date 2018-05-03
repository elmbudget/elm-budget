port module Ports exposing (onUserChange, storeUser, setTitle)

import User exposing (UserData, decoder)
import Json.Encode as E
import Json.Decode as D
import Helper.Core exposing (mapBoth)


port storeSessionRaw : Maybe String -> Cmd msg


port onUserChangeRaw : (E.Value -> msg) -> Sub msg


port setTitle : String -> Cmd a


storeUser : Maybe UserData -> Cmd mdg
storeUser maybeValue =
    storeSessionRaw
        (maybeValue
            |> Maybe.map
                (\u ->
                    E.encode 0
                        (E.object
                            [ ( "sessionToken", E.string u.sessionToken )
                            , ( "username", E.string u.username )
                            ]
                        )
                )
        )


onUserChange : (UserData -> msg) -> msg -> Sub msg
onUserChange f noop =
    onUserChangeRaw
        (\val ->
            D.decodeValue decoder val
                |> mapBoth
                    (\err -> noop)
                    (\u -> f u)
        )
