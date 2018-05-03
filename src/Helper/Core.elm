module Helper.Core exposing (..)

import Time
import Process
import Task


functionOrDefault : Maybe a -> result -> (a -> result) -> result
functionOrDefault original default fn =
    original |> Maybe.map fn |> Maybe.withDefault default


roundFloat2dp : Float -> Float
roundFloat2dp f =
    (toFloat <| Basics.round (f * 100)) / 100


isNothing : Maybe a -> Bool
isNothing v =
    case v of
        Nothing ->
            True

        _ ->
            False


isJust : Maybe a -> Bool
isJust =
    not << isNothing


isErr : Result e a -> Bool
isErr v =
    case v of
        Result.Err s ->
            True

        _ ->
            False


mapBoth : (e -> b) -> (a -> b) -> Result e a -> b
mapBoth fromError fromOK result =
    case result of
        Err err ->
            fromError err

        Ok ok ->
            fromOK ok


lookupWithDefault : List a -> (a -> k) -> (a -> v) -> v -> k -> v
lookupWithDefault list getKey getValue defaultValue lookupKey =
    List.filter (\item -> (getKey item) == lookupKey) list
        |> List.map getValue
        |> List.head
        |> Maybe.withDefault defaultValue


withIndexes : List a -> List ( Int, a )
withIndexes =
    let
        withIndexesR idx list =
            case list of
                x :: xs ->
                    ( idx, x ) :: withIndexesR (idx + 1) xs

                _ ->
                    []
    in
        withIndexesR 0


delay : Time.Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)


shuffle : List a -> List a -> List a
shuffle l1 l2 =
    case l1 of
        [] ->
            l2

        x :: xs ->
            x :: shuffle l2 xs


{-| The zip function takes in two lists and returns a combined
list. It combines the elements of each list pairwise until one
of the lists runs out of elements.
zip [1,2,3]['a','b','c'] == [(1,'a'), (2,'b'), (3,'c')]
-}
zip : List a -> List b -> List ( a, b )
zip xs ys =
    case ( xs, ys ) of
        ( x :: xBack, y :: yBack ) ->
            ( x, y ) :: zip xBack yBack

        ( _, _ ) ->
            []


lastElem : List a -> Maybe a
lastElem =
    List.foldl (Just >> always) Nothing
