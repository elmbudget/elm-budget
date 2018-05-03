module Categories.View exposing (..)

import Html exposing (Html, button, div, text, tr, td, th, table, input, span, option, select, h1, h2, p)
import Html.Events exposing (onClick, onInput, onBlur, on, onDoubleClick)
import Html.Attributes exposing (placeholder, type_, value, selected, id, class)
import Helper.Html exposing (ViewPort, navi, onChange, EditableTableContentScheme, generateBasedOnViewPort, textHtml)
import Categories.Message exposing (..)
import Categories.Model exposing (..)
import PersistableData exposing (..)
import Persistence.Interface exposing (StoredKey)


contentScheme : EditableTableContentScheme Category EditingCategoryRow Categories.Message.Msg
contentScheme =
    { getReadOnlyRowCells = \acc -> [ ( text acc.name, [ class columnIds.name ] ) ]
    , getEditableRowCells = \row -> [ ( input [ id columnIds.name, type_ "text", value row.name, onInput SetCategoryName ] [], [ class columnIds.name ] ) ]
    , isCreatingNewRow = \row -> row.storedKey == ""
    , isRowForEdit =
        \acc row -> row.storedKey /= "" && acc.storedKey == row.storedKey
    , editMessage = \acc -> EditCategory acc.storedKey
    , saveMessage = \row -> SaveCategory row
    , cancelMessage = CancelCategory
    , deleteMessage = \acc -> DeleteCategory acc.storedKey False
    , metaData =
        [ { desktopTableWidth = 50
          , mobileTableWidth = 50
          , headingText = "Category Name"
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
    , addItemHeading = "Add Category"
    , editItemHeading = "Edit Category"
    }


view : ViewPort -> CategoryPageModel -> List Category -> Html Categories.Message.Msg
view viewPort model categories =
    div [] <|
        (generateBasedOnViewPort viewPort
            "categories"
            contentScheme
            model.editingCategoryRow
            (List.sortBy (\c -> c.name) categories)
            (button [ onClick AddCategory ] [ text "Add Category" ])
        )
            ++ [ case model.confirmDeleteKey of
                    Nothing ->
                        text ""

                    Just id ->
                        deleteModal id
               ]


deleteModal : StoredKey -> Html Categories.Message.Msg
deleteModal key =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ span [ class "close" ] [ textHtml "&times;" ]
            , p [] [ text "Deleting this category will delete all of the transactions. Are you sure?" ]
            , div [ class "confirmation-buttons" ]
                [ button [ onClick (DeleteCategory key True) ] [ text "Delete" ]
                , button [ onClick CancelDelete ] [ text "Cancel" ]
                ]
            ]
        ]


columnIds :
    { name : String
    }
columnIds =
    { name =
        "CategoryName"
    }
