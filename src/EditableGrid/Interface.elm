module EditableGrid.Interface exposing (..)

import Persistence.Interface exposing (StoredKey)
import PersistableData exposing (..)


type alias ToFromEditable data editable =
    { toEditable : data -> editable, toData : editable -> data }


type alias WithStoredKey a =
    { get : a -> StoredKey, set : StoredKey -> a -> a }


type alias WithLocalId a =
    { get : a -> Int, set : Int -> a -> a }


withStoredKey_Account : WithStoredKey Account
withStoredKey_Account =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }


withStoredKey_Category : WithStoredKey Category
withStoredKey_Category =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }


withStoredKey_Transaction : WithStoredKey Transaction
withStoredKey_Transaction =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }
