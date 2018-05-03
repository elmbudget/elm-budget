module Transactions.View exposing (..)

import Html exposing (Html, button, div, text, tr, td, th, table, input, span, option, select, h1, h2, label, p)
import Html.Events exposing (onClick, onInput, onBlur, on, onDoubleClick, onCheck)
import Html.Attributes exposing (placeholder, type_, value, selected, id, class, title, for, checked)
import Round exposing (round)
import Transactions.Message exposing (Msg(..))
import Helper.Html exposing (navi, onChange)
import Transactions.Model exposing (..)
import PersistableData exposing (..)
import Helper.Html exposing (..)
import Transactions.Model exposing (..)
import Persistence.Interface exposing (StoredKey)
import Helper.Core exposing (lookupWithDefault, lastElem)
import Date exposing (Date, Month(..))
import DatePicker
import DatePicker.Settings
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Config_en_au exposing (config)
import Transactions.Common as Common exposing (DateRange, columnIds, rangeFor)
import Helper.SkeletonCss as Skeleton


toTransactionView : Transaction -> TransactionView
toTransactionView t =
    { storedKey = t.storedKey
    , desc = t.desc
    , amount = t.amount
    , accountKey = t.accountKey
    , payeeAccountKey = t.payeeAccountKey
    , categoryKey = t.categoryKey
    , date = t.date
    , balance = 0
    }


toTransaction : TransactionView -> Transaction
toTransaction t =
    { storedKey = t.storedKey
    , desc = t.desc
    , amount = t.amount
    , accountKey = t.accountKey
    , payeeAccountKey = t.payeeAccountKey
    , categoryKey = t.categoryKey
    , date = t.date
    }


type alias TransactionView =
    { storedKey : StoredKey
    , desc : String
    , amount : Float
    , accountKey : StoredKey
    , payeeAccountKey : StoredKey
    , categoryKey : StoredKey
    , date : Date
    , balance : Float
    }


makeContentScheme : Bool -> List Account -> List Category -> EditableTableContentScheme TransactionView EditingTransaction Transactions.Message.Msg
makeContentScheme showBalancesOnMobile accounts categories =
    { getReadOnlyRowCells =
        \txn ->
            let
                erow =
                    toEdit (toTransaction txn)

                elems elemId =
                    [ doubleClickHandler elemId
                    , class elemId
                    ]

                doubleClickHandler elemId =
                    onDoubleClick <| DoubleClickTransaction erow.storedKey elemId

                wrapHandler elemId str =
                    div [ class "textwrap", title str ] [ text str ]
            in
                [ ( wrapHandler columnIds.description erow.desc, elems columnIds.description )
                , ( wrapHandler columnIds.date (erow.date |> Maybe.map (format config "%Y-%m-%d") |> Maybe.withDefault ""), elems columnIds.date )
                , ( wrapHandler columnIds.payee <| lookupWithDefault accounts (\acc -> acc.storedKey) (\acc -> acc.name) "" erow.payeeAccountKey, elems columnIds.payee )
                , ( wrapHandler columnIds.category <| lookupWithDefault categories (\cat -> cat.storedKey) (\cat -> cat.name) "" erow.categoryKey, elems columnIds.category )
                , ( wrapHandler columnIds.inflow erow.inflow, elems columnIds.inflow )
                , ( wrapHandler columnIds.outflow erow.outflow, elems columnIds.outflow )
                , ( wrapHandler columnIds.outflow (Round.round 2 txn.amount), elems columnIds.outflow )
                , ( wrapHandler columnIds.balance <| Round.round 2 txn.balance, elems columnIds.balance )
                ]
    , getEditableRowCells =
        \row ->
            let
                unchosenAccount =
                    { storedKey = "", name = "" }

                unchosenCategory =
                    { storedKey = "", name = "" }
            in
                [ ( input [ id columnIds.description, id columnIds.description, type_ "text", placeholder "description", value row.desc, onInput <| \text -> SetEditingTransaction { row | desc = text } ] [], [ class columnIds.description ] )

                --, ( input [ id columnIds.date, type_ "text", placeholder "date", value row.date, onInput <| \text -> SetEditingTransaction { row | date = text } ] [], [class columnIds.date] )
                , ( div []
                        [ DatePicker.view
                            row.date
                            DatePicker.Settings.settings
                            row.datePicker
                            |> Html.map SetDatePicker
                        ]
                  , [ class columnIds.date ]
                  )
                , ( select
                        [ id columnIds.payee, onChange <| \text -> SetEditingTransaction { row | payeeAccountKey = text } ]
                        (unchosenAccount
                            :: accounts
                            |> List.filter (\acc -> acc.storedKey /= row.accountKey)
                            |> List.map (\acc -> option [ value <| acc.storedKey, selected (acc.storedKey == row.payeeAccountKey) ] [ text acc.name ])
                        )
                  , [ class columnIds.payee ]
                  )
                , ( select [ id columnIds.category, onChange <| \text -> SetEditingTransaction { row | categoryKey = text } ] (unchosenCategory :: categories |> List.map (\cat -> option [ value <| cat.storedKey, selected (cat.storedKey == row.categoryKey) ] [ text cat.name ])), [ class columnIds.category ] )
                , ( input [ id columnIds.inflow, type_ "number", placeholder "inflow", value row.inflow, onInput <| \text -> SetEditingTransaction { row | inflow = text, outflow = "" }, onBlur <| RejigTransaction row ] [], [ class columnIds.inflow ] )
                , ( input [ id columnIds.outflow, type_ "number", placeholder "outflow", value row.outflow, onInput <| \text -> SetEditingTransaction { row | outflow = text, inflow = "" }, onBlur <| RejigTransaction row ] [], [ class columnIds.outflow ] )
                , ( text "", [] )
                , ( text "", [ class columnIds.balance ] )
                ]
    , isCreatingNewRow = \row -> row.storedKey == ""
    , isRowForEdit =
        \acc row -> row.storedKey /= "" && acc.storedKey == row.storedKey
    , editMessage = \acc -> DoubleClickTransaction acc.storedKey columnIds.description
    , saveMessage = \row -> SaveTransaction row
    , cancelMessage = CancelTransaction
    , deleteMessage = \acc -> DeleteTransaction acc.storedKey False
    , metaData =
        [ { desktopTableWidth = 15
          , mobileTableWidth = 25
          , headingText = "Description"
          , isEditControl = True
          , headingClass = "description"
          }
        , { desktopTableWidth = 15
          , mobileTableWidth = 25
          , headingText = "Date"
          , isEditControl = True
          , headingClass = "date"
          }
        , { desktopTableWidth = 10
          , mobileTableWidth = 0
          , headingText = "Payee"
          , isEditControl = True
          , headingClass = "payee"
          }
        , { desktopTableWidth = 10
          , mobileTableWidth = 0
          , headingText = "Category"
          , isEditControl = True
          , headingClass = "category"
          }
        , { desktopTableWidth = 10
          , mobileTableWidth = 0
          , headingText = "Inflow"
          , isEditControl = True
          , headingClass = "inflow"
          }
        , { desktopTableWidth = 10
          , mobileTableWidth = 0
          , headingText = "Outflow"
          , isEditControl = True
          , headingClass = "outflow"
          }
        , { desktopTableWidth = 0
          , mobileTableWidth =
                if showBalancesOnMobile then
                    0
                else
                    25
          , headingText = "Flow"
          , isEditControl = False
          , headingClass = "flow"
          }
        , { desktopTableWidth = 10
          , mobileTableWidth =
                if showBalancesOnMobile then
                    25
                else
                    0
          , headingText = "Balance"
          , headingClass = "balance"
          , isEditControl = False
          }
        , { desktopTableWidth = 20
          , mobileTableWidth = 25
          , headingText = ""
          , headingClass = ""
          , isEditControl = False
          }
        ]

    -- todo classes
    , canEditDelete = \acc -> acc.storedKey /= ""
    , addItemHeading = "Add Transaction"
    , editItemHeading = "Edit Transaction"
    }


view : ViewPort -> Date -> List Account -> List Category -> List Transaction -> TransactionsPageModel -> Html Transactions.Message.Msg
view viewPort today accounts categories txns model =
    let
        contentScheme =
            makeContentScheme model.showBalancesOnMobile accounts categories

        effectiveAccountKey =
            if List.any (\acc -> acc.storedKey == model.selectedAccountKey) accounts then
                model.selectedAccountKey
            else
                List.head accounts
                    |> Maybe.map (.storedKey)
                    |> Maybe.withDefault ""

        filterBar =
            [ Skeleton.row []
                [ Skeleton.col4 []
                    [ label [ for "accountchooser" ] [ text "Select Account" ]
                    , select
                        [ id "accountchooser"
                        , onChange ChooseAccount
                        ]
                        (accounts
                            |> List.map
                                (\acc ->
                                    option
                                        [ value acc.storedKey
                                        , selected (acc.storedKey == effectiveAccountKey)
                                        ]
                                        [ text acc.name ]
                                )
                        )
                    ]
                , Skeleton.col4 []
                    [ label [ for "daterangechooser" ] [ text "Date Range" ]
                    , select [ id "daterangechooser", onChange ChooseDateRange ]
                        ((Common.datePresets today)
                            |> List.map
                                (\preset ->
                                    option
                                        [ value preset.text
                                        , selected (model.datePreset == preset.text)
                                        ]
                                        [ text preset.text ]
                                )
                        )
                    ]
                ]
            ]
                ++ [ if viewPort == Mobile then
                        Skeleton.row [ class "switch-row" ]
                            [ Skeleton.col12 []
                                [ div [ class "switch-label" ] [ text "Show balances" ]
                                , label [ class "switch" ]
                                    [ input [ type_ "checkbox", checked model.showBalancesOnMobile, onCheck SetShowBalancesOnMobile ] []
                                    , span [ class "slider round" ] []
                                    ]
                                ]
                            ]
                     else
                        text ""
                   ]

        range =
            rangeFor model.datePreset today

        finalBalance =
            Maybe.map (\e -> e.balance) (lastElem (toTransactionViews Common.unbounded txns effectiveAccountKey))
    in
        div [] <|
            if List.isEmpty accounts then
                [ Skeleton.row []
                    [ Skeleton.col12 []
                        [ span [ class "message" ] [ text "Please add an account first, then you can add transactions" ] ]
                    ]
                ]
            else
                filterBar
                    ++ [ Maybe.map (\b -> Skeleton.row [] [ Skeleton.col12 [ class "account-latest-balance" ] [ span [] [ text ("Final balance: " ++ (Round.round 2 b)) ] ] ])
                            finalBalance
                            |> Maybe.withDefault (text "")
                       , Skeleton.row []
                            [ Skeleton.col12 [] <|
                                generateBasedOnViewPort viewPort
                                    "transaction"
                                    contentScheme
                                    model.editingTransaction
                                    (toTransactionViews range txns effectiveAccountKey)
                                    (button [ onClick (AddTransaction effectiveAccountKey) ] [ text "Add Transaction" ])
                            ]
                       , case model.confirmDeleteKey of
                            Nothing ->
                                text ""

                            Just id ->
                                deleteModal id
                       ]


deleteModal : StoredKey -> Html Transactions.Message.Msg
deleteModal key =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ span [ class "close" ] [ textHtml "&times;" ]
            , p [] [ text "Delete Transaction. Are you sure?" ]
            , div [ class "confirmation-buttons" ]
                [ button [ onClick (DeleteTransaction key True) ] [ text "Delete" ]
                , button [ onClick CancelDelete ] [ text "Cancel" ]
                ]
            ]
        ]


accountKeyIsValid : List Account -> StoredKey -> Bool
accountKeyIsValid accs key =
    if key == "" then
        False
    else
        List.any (\acc -> acc.storedKey == key) accs


toTransactionViews : DateRange -> List Transaction -> StoredKey -> List TransactionView
toTransactionViews range txns accountKey =
    let
        txnsForAccount =
            txns
                |> List.filter (\txn -> txn.accountKey == accountKey)
                |> List.sortBy (\txn -> ( (format config "%Y-%m-%d") txn.date, txn.storedKey ))

        balances =
            List.scanl (\row acc -> acc + row.amount) 0 txnsForAccount |> List.drop 1
    in
        List.map2
            (\txn bal ->
                let
                    view =
                        toTransactionView txn
                in
                    { view | balance = bal }
            )
            txnsForAccount
            balances
            |> List.filter (\txn -> Common.isDateInRange range txn.date)
