module Persistence.Data exposing (..)

import Persistence.Interface exposing (..)
import PersistableData exposing (..)
import Json.Decode exposing (..)
import Json.Encode as JsonE
import Date


accountPersister : Persister Account
accountPersister =
    { encode =
        \acc ->
            JsonE.object
                [ ( "name", JsonE.string acc.name )
                ]
    , decoder = map2 Account (field "objectId" string) (field "name" string)
    , className = "Account"
    }


categoryPersister : Persister Category
categoryPersister =
    { encode =
        \acc ->
            JsonE.object
                [ ( "name", JsonE.string acc.name )
                ]
    , decoder = map2 Category (field "objectId" string) (field "name" string)
    , className = "Category"
    }


transactionPersister : Persister Transaction
transactionPersister =
    { encode =
        \txn ->
            JsonE.object
                [ ( "desc", JsonE.string txn.desc )
                , ( "amount", JsonE.float txn.amount )
                , ( "accountKey", JsonE.string txn.accountKey )
                , ( "payeeAccountKey", JsonE.string txn.payeeAccountKey )
                , ( "categoryKey", JsonE.string txn.categoryKey )
                , ( "date", JsonE.float <| Date.toTime txn.date )
                ]
    , decoder =
        map7
            Transaction
            (field "objectId" string)
            (field "desc" string)
            (field "amount" float)
            (field "accountKey" string)
            (field "payeeAccountKey" string)
            (field "categoryKey" string)
            (Json.Decode.map Date.fromTime <| field "date" float)
    , className = "Transaction"
    }
