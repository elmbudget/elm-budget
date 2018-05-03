module Categories.Update exposing (..)

import Categories.Message exposing (..)
import Categories.Model exposing (..)
import Platform.Cmd exposing (Cmd)
import PersistableData exposing (..)
import ProgramData exposing (Persisters)
import Persistence.Interface exposing (..)
import Helper.Task as TaskH
import Message
import EditableGrid.Update exposing (..)
import EditableGrid.Interface exposing (..)


dict : EditableRowScheme Category EditingCategoryRow CategoryPageModel Categories.Message.Msg
dict =
    { toFromEditableDict = toFromEditable_Category
    , withStoredKeyDict = withStoredKey_Category
    , withStoredKeyEditDict = withStoredKey_EditingCategoryRow
    , identityProvider = withLocalId_CategoryPageModel
    , toFailMessage = StorageFailed
    , toSaveSuccessMessage = StorageSaveSuccess
    , updateSuccessMessage = StorageUpdateSuccess
    }


update : Persisters -> Categories.Message.Msg -> CategoryPageModel -> List Category -> List Transaction -> ( CategoryPageModel, List Category, List Transaction, Cmd Categories.Message.Msg, Message.Msg )
update persisters message model categories txns =
    case message of
        AddCategory ->
            ( { model | editingCategoryRow = Just <| { storedKey = "", name = "" } }, categories, txns, Cmd.none, Message.None )

        EditCategory storedKey ->
            ( { model | editingCategoryRow = getEditRowFromList dict storedKey categories }, categories, txns, Cmd.none, Message.None )

        SaveCategory editingCategoryRow ->
            let
                ( newCategories, cmd, nextModel ) =
                    applyEditingRow dict model persisters.categoryBaaSPersister editingCategoryRow categories
            in
                ( { nextModel | editingCategoryRow = Nothing }, newCategories, txns, cmd, Message.None )

        CancelCategory ->
            ( { model | editingCategoryRow = Nothing }, categories, txns, Cmd.none, Message.None )

        CancelDelete ->
            ( { model | confirmDeleteKey = Nothing }, categories, txns, Cmd.none, Message.None )

        DeleteCategory storedKey sure ->
            if categoryHadDependencies txns storedKey then
                ( { model | confirmDeleteKey = Nothing }, categories, txns, Cmd.none, Message.defaultShowPopupMessage "You cannot delete this category because it is used in transactions. Delete the transactions first." )
            else
                ( { model
                    | confirmDeleteKey = Nothing
                    , editingCategoryRow =
                        model.editingCategoryRow
                            |> Maybe.andThen
                                (\c ->
                                    if c.storedKey == storedKey then
                                        Nothing
                                    else
                                        Just c
                                )
                  }
                  -- Remove the category:
                , List.filter (\acc -> acc.storedKey /= storedKey) categories
                  -- Remove the transactions that depend on the category:
                , List.filter (\txn -> not (txnDependsOnAction storedKey txn)) txns
                , persisters.categoryBaaSPersister.delete storedKey
                    |> TaskH.attempt2 StorageFailed (always StorageDeleteSuccess)
                , Message.None
                )

        SetCategoryName s ->
            ( { model | editingCategoryRow = model.editingCategoryRow |> Maybe.map (\row -> { row | name = s }) }, categories, txns, Cmd.none, Message.None )

        StorageSaveSuccess localKey storedKey ->
            ( model
            , List.map
                (\category ->
                    if category.storedKey == localKey then
                        { category | storedKey = storedKey }
                    else
                        category
                )
                categories
            , txns
            , Cmd.none
            , Message.None
            )

        StorageFailed message ->
            ( model
            , categories
            , txns
            , Cmd.none
            , Message.lostConnection
            )

        _ ->
            ( model, categories, txns, Cmd.none, Message.None )


categoryHadDependencies : List Transaction -> StoredKey -> Bool
categoryHadDependencies txns catKey =
    List.any (txnDependsOnAction catKey) txns


txnDependsOnAction : StoredKey -> Transaction -> Bool
txnDependsOnAction catKey txn =
    txn.categoryKey == catKey
