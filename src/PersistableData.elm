module PersistableData exposing (..)

import Date exposing (Date)
import Persistence.Interface exposing (StoredKey)


type alias Transaction =
    { storedKey : StoredKey
    , desc : String
    , amount : Float
    , accountKey : StoredKey
    , payeeAccountKey : StoredKey
    , categoryKey : StoredKey
    , date : Date
    }


type alias Account =
    { storedKey : StoredKey
    , name : String
    }


type alias Category =
    { storedKey : StoredKey
    , name : String
    }
