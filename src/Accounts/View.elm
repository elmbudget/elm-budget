module Accounts.View exposing (..)

import Html exposing (Html, button, div, text, tr, td, th, table, input, span, option, select, h1, h2, p)
import Html.Events exposing (onClick, onInput, onBlur, on, onDoubleClick)
import Html.Attributes exposing (placeholder, type_, value, selected, id, class)
import Accounts.Model exposing (..)
import Helper.Html exposing (ViewPort, navi, onChange, EditableTableContentScheme, generateBasedOnViewPort, textHtml)
import Accounts.Message exposing (..)
import PersistableData exposing (..)
import Persistence.Interface exposing (StoredKey)


accoutContentScheme : EditableTableContentScheme Account EditingAccountRow Accounts.Message.Msg
accoutContentScheme =
    { getReadOnlyRowCells = \acc -> [ ( text acc.name, [ class columnIds.name ] ) ]
    , getEditableRowCells = \row -> [ ( input [ id columnIds.name, type_ "text", value row.name, onInput SetAccountName ] [], [ class columnIds.name ] ) ]
    , isCreatingNewRow = \row -> row.storedKey == ""
    , isRowForEdit =
        \acc row -> row.storedKey /= "" && acc.storedKey == row.storedKey
    , editMessage = \acc -> EditAccount acc.storedKey
    , saveMessage = \row -> SaveAccount row
    , cancelMessage = CancelAccount
    , deleteMessage = \acc -> DeleteAccount acc.storedKey False
    , metaData =
        [ { desktopTableWidth = 50
          , mobileTableWidth = 50
          , headingText = "Account Name"
          , isEditControl = True
          , headingClass = "name"
          }
        , { desktopTableWidth = 50
          , mobileTableWidth = 50
          , headingText = ""
          , isEditControl = False
          , headingClass = ""
          }
        ]
    , canEditDelete = \acc -> acc.storedKey /= ""
    , addItemHeading = "Add Account"
    , editItemHeading = "Edit Account"
    }


view : ViewPort -> AccountPageModel -> List Account -> Html Accounts.Message.Msg
view viewPort model accounts =
    div [] <|
        (generateBasedOnViewPort
            viewPort
            "accounts"
            accoutContentScheme
            model.editingAccountRow
            (List.sortBy (\a -> a.name) accounts)
            (button [ onClick AddAccount ] [ text "Add Account" ])
        )
            ++ [ case model.confirmDeleteKey of
                    Nothing ->
                        text ""

                    Just storedKey ->
                        deleteModal storedKey
               ]


deleteModal : StoredKey -> Html Accounts.Message.Msg
deleteModal storedKey =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ span [ class "close" ] [ textHtml "&times;" ]
            , p [] [ text "Deleting this account will delete all of the transactions. Are you sure?" ]
            , div [ class "confirmation-buttons" ]
                [ button [ onClick (DeleteAccount storedKey True) ] [ text "Delete" ]
                , button [ onClick CancelDelete ] [ text "Cancel" ]
                ]
            ]
        ]


columnIds :
    { name : String
    }
columnIds =
    { name =
        "AccountName"
    }
