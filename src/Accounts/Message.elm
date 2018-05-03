module Accounts.Message exposing (..)

import Persistence.Interface exposing (StoredKey)
import Accounts.Model exposing (EditingAccountRow)


type
    Msg
    {--Button Actions --}
    = AddAccount
    | SaveAccount EditingAccountRow
    | CancelAccount
    | EditAccount StoredKey
    | DeleteAccount StoredKey Bool
    | CancelDelete
    | DoubleClickAccount StoredKey String
      {--Keystrokes --}
    | SetAccountName String
      {--API--}
    | StorageUpdateSuccess
    | StorageDeleteSuccess
    | StorageSaveSuccess StoredKey StoredKey
    | StorageFailed String
    | NoOp
