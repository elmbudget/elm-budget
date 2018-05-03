module Accounts.Update exposing (..)

import Accounts.Message exposing (..)
import Accounts.Model exposing (..)
import Platform.Cmd exposing (Cmd)
import PersistableData exposing (..)
import ProgramData exposing (Persisters)
import Persistence.Interface exposing (..)
import Helper.Task as TaskH
import Message
import EditableGrid.Update exposing (..)
import EditableGrid.Interface exposing (..)


dict : EditableRowScheme Account EditingAccountRow AccountPageModel Accounts.Message.Msg
dict =
    { toFromEditableDict = toFromEditable_Account
    , withStoredKeyDict = withStoredKey_Account
    , withStoredKeyEditDict = withStoredKey_EditingAccountRow
    , identityProvider = withLocalId_AccountPageModel
    , toFailMessage = StorageFailed
    , toSaveSuccessMessage = StorageSaveSuccess
    , updateSuccessMessage = StorageUpdateSuccess
    }


update : Persisters -> Accounts.Message.Msg -> AccountPageModel -> List Account -> List Transaction -> ( AccountPageModel, List Account, List Transaction, Cmd Accounts.Message.Msg, Message.Msg )
update persisters message model accounts txns =
    case message of
        AddAccount ->
            ( { model | editingAccountRow = Just <| { storedKey = "", name = "" } }, accounts, txns, Cmd.none, Message.None )

        EditAccount storedKey ->
            ( { model | editingAccountRow = getEditRowFromList dict storedKey accounts }, accounts, txns, Cmd.none, Message.None )

        SaveAccount editingAccountRow ->
            let
                ( newAccounts, cmd, nextModel ) =
                    applyEditingRow dict model persisters.accountBaaSPersister editingAccountRow accounts
            in
                ( { nextModel | editingAccountRow = Nothing }, newAccounts, txns, cmd, Message.None )

        CancelAccount ->
            ( { model | editingAccountRow = Nothing }, accounts, txns, Cmd.none, Message.None )

        CancelDelete ->
            ( { model | confirmDeleteKey = Nothing }, accounts, txns, Cmd.none, Message.None )

        DeleteAccount storedKey sure ->
            if accountHadDependencies txns storedKey then
                ( { model | confirmDeleteKey = Nothing }, accounts, txns, Cmd.none, Message.defaultShowPopupMessage "You cannot delete this account because it has transactions. Delete the transactions first." )
            else
                ( { model
                    | confirmDeleteKey = Nothing
                    , editingAccountRow =
                        model.editingAccountRow
                            |> Maybe.andThen
                                (\a ->
                                    if a.storedKey == storedKey then
                                        Nothing
                                    else
                                        Just a
                                )
                  }
                  -- Remove the account:
                , List.filter (\acc -> acc.storedKey /= storedKey) accounts
                , txns
                , persisters.accountBaaSPersister.delete storedKey
                    |> TaskH.attempt2 StorageFailed (always StorageDeleteSuccess)
                , Message.None
                )

        SetAccountName s ->
            ( { model | editingAccountRow = model.editingAccountRow |> Maybe.map (\row -> { row | name = s }) }, accounts, txns, Cmd.none, Message.None )

        StorageSaveSuccess localKey storedKey ->
            ( model
            , List.map
                (\account ->
                    if account.storedKey == localKey then
                        { account | storedKey = storedKey }
                    else
                        account
                )
                accounts
            , txns
            , Cmd.none
            , Message.None
            )

        StorageFailed message ->
            ( model
            , accounts
            , txns
            , Cmd.none
            , Message.lostConnection
            )

        _ ->
            ( model, accounts, txns, Cmd.none, Message.None )


accountHadDependencies : List Transaction -> StoredKey -> Bool
accountHadDependencies txns storedKey =
    not <| List.isEmpty <| accountDependencies txns storedKey


accountDependencies : List Transaction -> StoredKey -> List Transaction
accountDependencies txns storedKey =
    List.filter (txnDependsOnAction storedKey) txns


txnDependsOnAction : StoredKey -> Transaction -> Bool
txnDependsOnAction storedKey txn =
    txn.accountKey == storedKey || txn.payeeAccountKey == storedKey
