module Helper.Http exposing (..)


isErrorStatus : Int -> Bool
isErrorStatus status =
    -- Translation of some code in https://github.com/elm-lang/http/blob/1.0.0/src/Native/Http.js
    status < 200 || 300 <= status
