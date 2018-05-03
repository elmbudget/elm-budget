module ProgramData exposing (..)

import Persistence.Interface exposing (..)
import PersistableData exposing (..)
import Persistence.ParseBaaS exposing (persister)
import Backend.ParseBaaSClient exposing (Credentials)
import Persistence.Data exposing (..)


type alias ProgramData =
    { credentials : Credentials }


type alias Persisters =
    { accountBaaSPersister : BaaSPersister Account
    , categoryBaaSPersister : BaaSPersister Category
    , transactionBaaSPersister : BaaSPersister Transaction
    }


programData : ProgramData
programData =
    { credentials = credentials }


getPersisters : Credentials -> SessionToken -> Persisters
getPersisters credentials sessionToken =
    { accountBaaSPersister = persister credentials sessionToken accountPersister
    , categoryBaaSPersister = persister credentials sessionToken categoryPersister
    , transactionBaaSPersister = persister credentials sessionToken transactionPersister
    }


getUserPersister : Credentials -> UserPersister
getUserPersister =
    Persistence.ParseBaaS.userPersister


getLogout : Credentials -> SessionToken -> LogoutUser
getLogout =
    Persistence.ParseBaaS.logoutUser


credentials : Credentials
credentials =
    { appId = "00c5fcfe-a699-4673-9801-ea79dd4d6a05"
    , apiKey = "H0eoFKs2ZvxhvUtw87TFJurckvBy0IWv"
    , url = "https://parse.buddy.com/parse"
    }
