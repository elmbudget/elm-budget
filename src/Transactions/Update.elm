module Transactions.Update exposing (..)

import Date exposing (Date)
import Transactions.Message exposing (Msg(..))
import Transactions.Model exposing (..)
import PersistableData exposing (..)
import EditableGrid.Update exposing (..)
import EditableGrid.Interface exposing (..)
import ProgramData exposing (Persisters)
import Helper.Task as TaskH
import DatePicker
import DatePicker.Settings
import Message
import Transactions.Common exposing (columnIds, datePresets, rangeFor, isDateInRange)
import Helper.Html exposing (focus)


dict : EditableRowScheme Transaction EditingTransaction TransactionsPageModel Transactions.Message.Msg
dict =
    { toFromEditableDict = toFromEditable_Transaction
    , withStoredKeyDict = withStoredKey_Transaction
    , withStoredKeyEditDict = withStoredKey_EditingTransaction
    , identityProvider = withLocalId_TransactionPageModel
    , toFailMessage = StorageFailed
    , toSaveSuccessMessage = StorageSaveSuccess
    , updateSuccessMessage = StorageUpdateSuccess
    }


update : Date -> Persisters -> Transactions.Message.Msg -> TransactionsPageModel -> List Transaction -> ( TransactionsPageModel, List Transaction, Cmd Transactions.Message.Msg, Message.Msg )
update today persisters msg model txns =
    let
        editTransaction storedKey =
            { model | editingTransaction = getEditRowFromList dict storedKey txns }

        range =
            rangeFor model.datePreset today
    in
        case msg of
            AddTransaction accountKey ->
                let
                    date =
                        if isDateInRange range today then
                            today
                        else
                            range.from |> Maybe.withDefault (range.to |> Maybe.withDefault today)

                    newTxn =
                        { storedKey = "", desc = "", amount = 0, accountKey = accountKey, payeeAccountKey = "", categoryKey = "", date = date }
                in
                    ( { model | editingTransaction = Just <| toEdit newTxn }, txns, focus columnIds.description Transactions.Message.None, Message.None )

            EditTransaction storedKey ->
                ( editTransaction storedKey, txns, Cmd.none, Message.None )

            DeleteTransaction storedKey sure ->
                if sure then
                    ( { model
                        | confirmDeleteKey = Nothing
                        , editingTransaction =
                            model.editingTransaction
                                |> Maybe.andThen
                                    (\txn ->
                                        if txn.storedKey == storedKey then
                                            Nothing
                                        else
                                            Just txn
                                    )
                      }
                      -- Remove the transaction  :
                    , List.filter (\txn -> txn.storedKey /= storedKey) txns
                    , persisters.transactionBaaSPersister.delete storedKey
                        |> TaskH.attempt2 StorageFailed (always StorageDeleteSuccess)
                    , Message.None
                    )
                else
                    ( { model | confirmDeleteKey = Just storedKey }, txns, Cmd.none, Message.None )

            CancelDelete ->
                ( { model | confirmDeleteKey = Nothing }, txns, Cmd.none, Message.None )

            DoubleClickTransaction storedKey elId ->
                ( editTransaction storedKey, txns, focus elId Transactions.Message.None, Message.None )

            SaveTransaction editingTransaction ->
                let
                    ( newTransactions, cmd, nextModel ) =
                        applyEditingRow dict model persisters.transactionBaaSPersister editingTransaction txns

                    popup =
                        if Maybe.map (\d -> isDateInRange range d) editingTransaction.date |> Maybe.withDefault False then
                            Message.None
                        else
                            Message.defaultShowPopupMessage "This transaction is out of the current date range so it wont appear. Change the date range to view it."
                in
                    ( { nextModel | editingTransaction = Nothing }, newTransactions, cmd, popup )

            CancelTransaction ->
                ( { model | editingTransaction = Nothing }, txns, Cmd.none, Message.None )

            SetEditingTransaction newRow ->
                ( { model | editingTransaction = Just newRow }, txns, Cmd.none, Message.None )

            RejigTransaction editRow ->
                ( { model | editingTransaction = Just <| toEdit (fromEdit editRow) }, txns, Cmd.none, Message.None )

            SetDatePicker msg ->
                model.editingTransaction
                    |> Maybe.map
                        (\editingTransaction ->
                            let
                                ( newDatePicker, datePickerCmd, dateEvent ) =
                                    DatePicker.update DatePicker.Settings.settings msg editingTransaction.datePicker

                                date =
                                    case dateEvent of
                                        DatePicker.NoChange ->
                                            editingTransaction.date

                                        DatePicker.Changed newDate ->
                                            newDate

                                newEditingTransaction =
                                    Just
                                        { editingTransaction
                                            | date = date
                                            , datePicker = newDatePicker
                                        }
                            in
                                ( { model | editingTransaction = newEditingTransaction }
                                , txns
                                , Cmd.map SetDatePicker datePickerCmd
                                , Message.None
                                )
                        )
                    |> Maybe.withDefault
                        ( model, txns, Cmd.none, Message.None )

            StorageFailed s ->
                ( model, txns, Cmd.none, Message.lostConnection )

            ChooseAccount key ->
                ( { model | selectedAccountKey = key }, txns, Cmd.none, Message.None )

            ChooseDateRange text ->
                let
                    newDatePreset =
                        (datePresets today)
                            |> List.filter (\p -> p.text == text)
                            |> List.head
                            |> Maybe.map (\p -> p.text)
                            |> Maybe.withDefault ""
                in
                    ( { model | datePreset = newDatePreset }, txns, Cmd.none, Message.None )
 
            SetShowBalancesOnMobile value ->
                ( { model | showBalancesOnMobile = value }, txns, Cmd.none, Message.None )

            _ ->
                ( model, txns, Cmd.none, Message.None )
