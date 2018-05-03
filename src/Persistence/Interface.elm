module Persistence.Interface exposing (..)

import Json.Decode exposing (..)
import Json.Encode as JsonE
import Task exposing (Task)


type alias User =
    { username : String
    , password : String
    }


type alias LoginData =
    { username : String
    , password : String
    }


type alias Persister a =
    { encode : a -> JsonE.Value
    , decoder : Decoder a
    , className : String
    }


type alias ErrorMessage =
    String


type LoginErrorMessage
    = LoginGeneralErrorMessage String
    | UserEmailNotVerified


type alias StoredKey =
    String


type alias Clause =
    { fieldName : String
    , value : JsonE.Value
    }


type alias Save a =
    a -> Task ErrorMessage StoredKey


type alias Get a =
    List Clause -> Task ErrorMessage ( List a, Bool )


type alias Update a =
    StoredKey -> a -> Task ErrorMessage ()


type alias Delete =
    StoredKey -> Task ErrorMessage ()


type alias BaaSPersister a =
    { save : Save a
    , get : Get a
    , update : Update a
    , delete : Delete
    }


type alias SaveUser =
    User -> Task ErrorMessage StoredKey


type alias LoginUser =
    LoginData -> Task LoginErrorMessage SessionToken


type alias LogoutUser =
    Task () ()


type alias UserPersister =
    { saveUser : SaveUser
    , loginUser : LoginUser
    }


type alias SessionToken =
    String
