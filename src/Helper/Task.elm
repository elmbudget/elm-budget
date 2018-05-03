module Helper.Task exposing (..)

import Task exposing (Task)


attempt2 : (x -> msg) -> (a -> msg) -> Task x a -> Cmd msg
attempt2 errorMap successMap =
    Task.attempt
        (\result ->
            case result of
                Ok r ->
                    successMap r

                Err e ->
                    errorMap e
        )
