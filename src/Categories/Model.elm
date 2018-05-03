module Categories.Model exposing (..)

import Persistence.Interface exposing (StoredKey)
import PersistableData exposing (..)
import EditableGrid.Interface exposing (..)


type alias EditingCategoryRow =
    { storedKey : StoredKey
    , name : String
    }


type alias CategoryPageModel =
    { editingCategoryRow : Maybe EditingCategoryRow
    , confirmDeleteKey : Maybe StoredKey
    , nextFakeId : Int
    }


withStoredKey_EditingCategoryRow : WithStoredKey EditingCategoryRow
withStoredKey_EditingCategoryRow =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }


withLocalId_CategoryPageModel : WithLocalId CategoryPageModel
withLocalId_CategoryPageModel =
    { get = .nextFakeId, set = \id model -> { model | nextFakeId = id } }


toFromEditable_Category : ToFromEditable Category EditingCategoryRow
toFromEditable_Category =
    { toEditable = \data -> { storedKey = data.storedKey, name = data.name }
    , toData = \row -> { storedKey = row.storedKey, name = row.name }
    }
