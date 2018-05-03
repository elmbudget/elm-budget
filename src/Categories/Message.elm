module Categories.Message exposing (..)

import Persistence.Interface exposing (StoredKey)
import Categories.Model exposing (EditingCategoryRow)


type
    Msg
    {--Button Actions --}
    = AddCategory
    | SaveCategory EditingCategoryRow
    | CancelCategory
    | EditCategory StoredKey
    | DeleteCategory StoredKey Bool
    | CancelDelete
    | DoubleClickCategory StoredKey String
      {--Keystrokes --}
    | SetCategoryName String
      {--API--}
    | StorageUpdateSuccess
    | StorageDeleteSuccess
    | StorageSaveSuccess StoredKey StoredKey
    | StorageFailed String
