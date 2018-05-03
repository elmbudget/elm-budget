module Transactions.Model exposing (..)

import Persistence.Interface exposing (StoredKey)
import PersistableData exposing (..)
import EditableGrid.Interface exposing (..)
import Round exposing (round)
import Date
import Helper.Core exposing (..)
import DatePicker
import Date exposing (Date)


type alias EditingTransaction =
    { storedKey : StoredKey
    , desc : String
    , inflow : String
    , outflow : String
    , accountKey : String
    , payeeAccountKey : String
    , categoryKey : StoredKey
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }


type alias TransactionsPageModel =
    { editingTransaction : Maybe EditingTransaction
    , confirmDeleteKey : Maybe StoredKey
    , nextFakeId : Int
    , selectedAccountKey : StoredKey
    , datePreset : String
    , showBalancesOnMobile : Bool
    }


withStoredKey_EditingTransaction : WithStoredKey EditingTransaction
withStoredKey_EditingTransaction =
    { get = .storedKey, set = \key acc -> { acc | storedKey = key } }


withLocalId_TransactionPageModel : WithLocalId TransactionsPageModel
withLocalId_TransactionPageModel =
    { get = .nextFakeId, set = \id model -> { model | nextFakeId = id } }


toFromEditable_Transaction : ToFromEditable Transaction EditingTransaction
toFromEditable_Transaction =
    { toEditable = toEdit
    , toData = fromEdit
    }


fromEdit : EditingTransaction -> Transaction
fromEdit editData =
    let
        parseFloat str =
            String.toFloat str |> Result.withDefault 0 |> roundFloat2dp
    in
        { storedKey = editData.storedKey
        , desc = editData.desc
        , amount = (parseFloat editData.inflow) - (parseFloat editData.outflow)
        , accountKey = editData.accountKey
        , payeeAccountKey = editData.payeeAccountKey
        , categoryKey = editData.categoryKey
        , date = Maybe.withDefault (Date.fromTime 0) editData.date --Date.fromString editData.date |> Result.withDefault (Date.fromTime 0)
        }


toEdit : Transaction -> EditingTransaction
toEdit row =
    { storedKey = row.storedKey
    , desc = row.desc
    , inflow = formatFlow True row.amount
    , outflow = formatFlow False row.amount
    , accountKey = row.accountKey
    , payeeAccountKey = row.payeeAccountKey
    , categoryKey = row.categoryKey
    , date = Just row.date --format config "%Y-%m-%d" row.date
    , datePicker = DatePicker.initFromDate row.date
    }


formatFlow : Bool -> Float -> String
formatFlow isInflow amount =
    let
        adjAmount =
            if isInflow then
                amount
            else
                -amount
    in
        if adjAmount <= 0 then
            ""
        else
            Round.round 2 adjAmount
