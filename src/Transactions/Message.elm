module Transactions.Message exposing (..)

import Persistence.Interface exposing (StoredKey)
import Transactions.Model exposing (EditingTransaction)
import Date exposing (Date)
import DatePicker


type
    Msg
    {--Button Actions --}
    = AddTransaction StoredKey
    | SaveTransaction EditingTransaction
    | CancelTransaction
    | EditTransaction StoredKey
    | DeleteTransaction StoredKey Bool
    | CancelDelete
    | DoubleClickTransaction StoredKey String
      {--Keystrokes --}
    | SetEditingTransaction EditingTransaction
    | SetTransactionInflow String
    | SetTransactionOutflow String
    | SetTransactionDesc String
    | SetTransactionDate String
    | SetTransactionPayeeAccount StoredKey
    | SetTransactionCategory String
    | RejigTransaction EditingTransaction
      {--DATE PICKER--}
    | SetDatePicker DatePicker.Msg
      {--API--}
    | StorageUpdateSuccess
    | StorageDeleteSuccess
    | StorageSaveSuccess StoredKey StoredKey
    | StorageFailed String
      {--Filter Bar--}
    | ChooseAccount StoredKey
    | ChooseDateRange String
    | SetShowBalancesOnMobile Bool
      {--NO OP--}
    | None
