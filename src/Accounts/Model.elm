module Accounts.Model exposing (..)

import Persistence.Interface exposing (StoredKey)
import PersistableData exposing (..)
import EditableGrid.Interface exposing (..)


type alias EditingAccountRow =
    { storedKey : StoredKey
    , name : String
    }


type alias AccountPageModel =
    { editingAccountRow : Maybe EditingAccountRow
    , confirmDeleteKey : Maybe StoredKey
    , nextFakeId : Int
    }


withStoredKey_EditingAccountRow : WithStoredKey EditingAccountRow
withStoredKey_EditingAccountRow =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }


withLocalId_AccountPageModel : WithLocalId AccountPageModel
withLocalId_AccountPageModel =
    { get = .nextFakeId, set = \id model -> { model | nextFakeId = id } }


toFromEditable_Account : ToFromEditable Account EditingAccountRow
toFromEditable_Account =
    { toEditable = \data -> { storedKey = data.storedKey, name = data.name }
    , toData = \row -> { storedKey = row.storedKey, name = row.name }
    }
