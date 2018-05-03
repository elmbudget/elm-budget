module Helper.Html exposing (..)

import Html exposing (Html, div, text, table, thead, tr, td, th, button, span, a, img, Attribute, hr)
import Html.Events exposing (on, onClick, keyCode)
import Html.Attributes exposing (class, classList, href, attribute, src, alt, colspan)
import Json.Decode as Json
import Json.Encode
import Message exposing (Msg)
import Dom
import Task
import Helper.Core exposing (zip, shuffle, isJust)
import Helper.SkeletonCss as Skeleton


type ViewPort
    = Mobile
    | Desktop


navi : String -> a -> (a -> String) -> (a -> String) -> List a -> Html Msg
navi className selectedItem createUrlForItem createTextForItem items =
    let
        menuEntry item menuText =
            case item == selectedItem of
                True ->
                    div [ class "menuitem selected" ] [ text menuText ]

                False ->
                    div [ class "menuitem unselected" ] [ a [ href <| createUrlForItem item ] [ text menuText ] ]
    in
        div [ class className ] <| List.map (\item -> menuEntry item (createTextForItem item)) items


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    on "change" <| Json.map handler <| Json.at [ "target", "value" ] Json.string


type alias EditableTableContentScheme a editRow msg =
    { getReadOnlyRowCells : a -> List ( Html msg, List (Html.Attribute msg) )
    , getEditableRowCells : editRow -> List ( Html msg, List (Html.Attribute msg) )
    , editMessage : a -> msg
    , saveMessage : editRow -> msg
    , canEditDelete : a -> Bool
    , cancelMessage : msg
    , deleteMessage : a -> msg
    , isRowForEdit : a -> editRow -> Bool
    , isCreatingNewRow : editRow -> Bool
    , metaData : List EditableCellMetaData
    , addItemHeading : String
    , editItemHeading : String
    }


type alias EditableCellMetaData =
    { -- % width to use in desktop mode
      desktopTableWidth : Int
    , -- % width to use in mobile view. Zero means hide
      mobileTableWidth : Int
    , headingText : String
    , isEditControl : Bool
    , headingClass : String
    }


responsiveButton : ViewPort -> String -> String -> Html msg
responsiveButton viewPort imageSrc caption =
    case viewPort of
        Mobile ->
            img [ class "mobile-button-image", src imageSrc, alt caption ] []

        Desktop ->
            text caption


isCreatingNewRow : EditableTableContentScheme a editRow msg -> Maybe editRow -> Bool
isCreatingNewRow scheme editRowMaybe =
    Maybe.map (\editRow -> scheme.isCreatingNewRow editRow) editRowMaybe |> Maybe.withDefault False


generateBasedOnViewPort : ViewPort -> String -> EditableTableContentScheme a editRow msg -> Maybe editRow -> List a -> Html msg -> List (Html msg)
generateBasedOnViewPort viewPort className scheme editRowMaybe datums addItemView =
    let
        showOnlyEditBox =
            viewPort == Mobile && isJust editRowMaybe

        metaDataForViewPort =
            List.map
                (\m ->
                    { width =
                        case viewPort of
                            Mobile ->
                                m.mobileTableWidth

                            Desktop ->
                                m.desktopTableWidth
                    , headingText = m.headingText
                    , isEditControl = m.isEditControl
                    , headingClass = m.headingClass
                    }
                )
                scheme.metaData

        hider list =
            zip list metaDataForViewPort
                |> List.filter (\( d, m ) -> m.width > 0)
                |> List.map (\( d, _ ) -> d)

        mobileHider list =
            zip list metaDataForViewPort
                |> List.filter (\( d, m ) -> m.isEditControl)
                |> List.map (\( d, _ ) -> d)

        headerItems =
            List.filterMap
                (\m ->
                    if m.width > 0 then
                        Just <| th [ class m.headingClass, attribute "width" ((toString m.width) ++ "%") ] [ text m.headingText ]
                    else
                        Nothing
                )
                metaDataForViewPort

        saveButton =
            case editRowMaybe of
                Just editRow ->
                    button [ onClick (scheme.saveMessage editRow) ] [ responsiveButton viewPort "img/check.svg" "Save" ]

                _ ->
                    text ""

        cancelButton =
            button [ onClick (scheme.cancelMessage) ] [ responsiveButton viewPort "img/arrow-left.svg" "Cancel" ]

        isCreatingNewRowResult =
            isCreatingNewRow scheme editRowMaybe

        tdWrap ( cell, attrs ) =
            td attrs [ cell ]

        wrapedEditableRowCells maybeDeleteMessage =
            case editRowMaybe of
                Just editRow ->
                    let
                        cells =
                            scheme.getEditableRowCells editRow
                    in
                        case viewPort of
                            Mobile ->
                                [ td [ colspan <| List.length headerItems ] <|
                                    [ div [] <|
                                        Skeleton.row []
                                            [ Skeleton.col12 [ class "edit-mobile-header-label" ]
                                                [ text <|
                                                    if isCreatingNewRowResult then
                                                        scheme.addItemHeading
                                                    else
                                                        scheme.editItemHeading
                                                ]
                                            ]
                                            :: (shuffle
                                                    (List.map
                                                        (\m -> Skeleton.row [] [ Skeleton.col12 [] [ text m.headingText ] ])
                                                        (mobileHider scheme.metaData)
                                                    )
                                                    (List.map
                                                        (\( cell, attrs ) -> Skeleton.row [] [ Skeleton.col12 attrs [ cell ] ])
                                                        (mobileHider cells)
                                                    )
                                               )
                                            ++ [ Skeleton.row []
                                                    [ Skeleton.col12 [ class "buttons" ]
                                                        [ saveButton
                                                        , cancelButton
                                                        , maybeDeleteMessage
                                                            |> Maybe.map (\m -> button [ onClick m ] [ responsiveButton viewPort "img/minus-circle-red.svg" "Delete" ])
                                                            |> Maybe.withDefault (text "")
                                                        ]
                                                    ]
                                               ]
                                    ]
                                ]

                            Desktop ->
                                hider <|
                                    List.map
                                        tdWrap
                                        (cells
                                            ++ ([ ( div [ class "buttons" ] [ saveButton, text " ", cancelButton ]
                                                  , []
                                                  )
                                                ]
                                               )
                                        )

                _ ->
                    []

        rows : List (Html msg)
        rows =
            (List.filterMap
                (\datum ->
                    -- Create cells
                    (if Maybe.map (\editRow -> scheme.isRowForEdit datum editRow) editRowMaybe |> Maybe.withDefault False then
                        Just <| tr [] <| wrapedEditableRowCells (Just <| scheme.deleteMessage datum)
                     else if showOnlyEditBox then
                        Nothing
                     else
                        Just <|
                            tr [] <|
                                hider <|
                                    List.map
                                        tdWrap
                                        (scheme.getReadOnlyRowCells datum
                                            ++ [ ( if scheme.canEditDelete datum then
                                                    div [ class "buttons" ]
                                                        [ button [ onClick (scheme.editMessage datum) ] [ responsiveButton viewPort "img/edit.svg" "Edit" ]
                                                        , text " "
                                                        , case viewPort of
                                                            Mobile ->
                                                                text ""

                                                            Desktop ->
                                                                button [ onClick (scheme.deleteMessage datum) ] [ responsiveButton viewPort "img/minus-circle-red.svg" "Delete" ]
                                                        ]
                                                   else
                                                    text "Saving..."
                                                 , []
                                                 )
                                               ]
                                        )
                    )
                )
                datums
            )
    in
        [ table [ classList [ ( className, True ), ( "edit-table", True ) ] ] <|
            (if showOnlyEditBox then
                []
             else
                [ thead []
                    [ tr [] headerItems
                    ]
                ]
            )
                ++ rows
                ++ if isCreatingNewRowResult then
                    [ tr [] <| wrapedEditableRowCells Nothing ]
                   else
                    []
        , if isCreatingNewRowResult || (viewPort == Mobile && isJust editRowMaybe) then
            text ""
          else
            addItemView
        ]


textHtml : String -> Html msg
textHtml t =
    span
        [ Json.Encode.string t
            |> Html.Attributes.property "innerHTML"
        ]
        []


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)


keyCodeEnter : Int
keyCodeEnter =
    13


focus : Dom.Id -> msg -> Cmd msg
focus id noop =
    Task.attempt (always noop) (Dom.focus id |> Task.map (always noop))
