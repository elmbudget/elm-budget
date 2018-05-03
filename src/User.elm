module User exposing (..)

import Persistence.Interface
import Json.Decode as D


type alias UserData =
    { sessionToken : Persistence.Interface.SessionToken
    , username : String
    }


decoder : D.Decoder UserData
decoder =
    D.map2 UserData (D.field "sessionToken" D.string) (D.field "username" D.string)
