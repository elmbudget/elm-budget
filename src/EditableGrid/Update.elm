module EditableGrid.Update exposing (..)

import Platform.Cmd exposing (Cmd)
import Persistence.Interface exposing (..)
import Helper.Task as TaskH
import EditableGrid.Interface exposing (..)


{-| Represents and editable row scheme in this application to help with external and internal persistance of data in editable grids. This ensures there is a
uniform way to deal with this across the application.
-}
type alias EditableRowScheme dataRow editRow identityProvider message =
    { toFromEditableDict : ToFromEditable dataRow editRow
    , withStoredKeyDict : WithStoredKey dataRow
    , withStoredKeyEditDict : WithStoredKey editRow
    , identityProvider : WithLocalId identityProvider
    , toFailMessage : String -> message
    , toSaveSuccessMessage : StoredKey -> StoredKey -> message
    , updateSuccessMessage : message
    }


{-| Helper function to get a value from the list of data and convert it to an editable row
-}
getEditRowFromList : EditableRowScheme dataRow editRow id message -> StoredKey -> List dataRow -> Maybe editRow
getEditRowFromList sc storedKey list =
    List.filter (\item -> (sc.withStoredKeyDict.get item) == storedKey) list
        |> List.head
        |> Maybe.map sc.toFromEditableDict.toEditable


{-| Helper function to apply data from the "editing row" to the data row, deciding if this is an update or a save, and producing a command that
will store the update/save in the BaaS
-}
applyEditingRow : EditableRowScheme dataRow editRow id message -> id -> BaaSPersister dataRow -> editRow -> List dataRow -> ( List dataRow, Cmd message, id )
applyEditingRow sc identityProvider persister editRow dataRows =
    let
        editRowStoredKey =
            sc.withStoredKeyEditDict.get editRow
    in
        if editRowStoredKey /= "" then
            let
                updatedDataRow =
                    sc.toFromEditableDict.toData editRow
            in
                ( updateItemWithKey sc.withStoredKeyDict editRowStoredKey updatedDataRow dataRows
                , persister.update editRowStoredKey updatedDataRow
                    |> TaskH.attempt2 sc.toFailMessage (always sc.updateSuccessMessage)
                , identityProvider
                )
        else
            let
                ( nextModel, dataRow ) =
                    setFake sc.identityProvider sc.withStoredKeyDict identityProvider (sc.toFromEditableDict.toData editRow)
            in
                ( dataRows ++ [ dataRow ]
                , persister.save dataRow
                    |> TaskH.attempt2 sc.toFailMessage (sc.toSaveSuccessMessage (sc.withStoredKeyDict.get dataRow))
                , nextModel
                )


setFake : WithLocalId model -> WithStoredKey record -> model -> record -> ( model, record )
setFake localIdDic storedKeyDic model record =
    let
        localId =
            localIdDic.get model
    in
        ( localIdDic.set (localId + 1) model, storedKeyDic.set ("localid_" ++ (toString localId)) record )


updateItemWithKey : WithStoredKey a -> StoredKey -> a -> List a -> List a
updateItemWithKey dict key newItem list =
    List.map
        (\item ->
            if dict.get item == key then
                newItem
            else
                item
        )
        list
