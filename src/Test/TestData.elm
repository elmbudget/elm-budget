module Test.TestData exposing (..)

import Model exposing (..)
import Types exposing (..)
import Message exposing (..)
import Date.Extra.Create exposing (dateFromFields)
import Date exposing (Date)


model : Model
model =
    { txns =
        [ { desc = "income", amount = 500, accountId = 1, payeeAccountId = 4, categoryId = 0, date = dateFromFields 2017 Date.Jan 20 0 0 0 0 }
        , { desc = "beer", amount = -3, accountId = 1, payeeAccountId = 3, categoryId = 1, date = dateFromFields 2017 Date.Jan 21 0 0 0 0 }
        , { desc = "more beer", amount = -6, accountId = 1, payeeAccountId = 3, categoryId = 1, date = dateFromFields 2017 Date.Jan 22 0 0 0 0 }
        , { desc = "brewery", amount = -100, accountId = 1, payeeAccountId = 3, categoryId = 1, date = dateFromFields 2017 Date.Jan 23 0 0 0 0 }
        ]
    , accounts =
        [ { id = 1, name = "Bank" }
        , { id = 2, name = "Credit Card" }
        , { id = 3, name = "Expenses" }
        , { id = 4, name = "Income" }
        ]
    , categories =
        [ { id = 1, name = "food" }
        , { id = 2, name = "going out" }
        ]
    , editRowIndex = Nothing
    , editRowData =
        { desc = "income"
        , inflow = "500.00"
        , outflow = ""
        , accountId = 0
        , payeeAccountId = 0
        , categoryId = 0
        , date = ""
        }
    , page = Accounts
    , accountPageModel =
        { editingAccountRow = Nothing
        , confirmDeleteId = Nothing
        }
    , categoryPageModel =
        { editingCategoryRow = Nothing
        , confirmDeleteId = Nothing
        }
    }
