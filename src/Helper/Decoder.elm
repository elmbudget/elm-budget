module Helper.Decoder exposing (..)

import Json.Decode exposing (..)
import List exposing (foldr)


{-| Runs the decoder on a list, ignoring any errors on individual items,
returning the filtered list and a flag to identify if any errors have
occurred
-}
dropBadDecoder : Decoder a -> Decoder ( List a, Bool )
dropBadDecoder decoder =
    let
        filter : List (Maybe a) -> ( List a, Bool )
        filter xs =
            let
                func mx ( xs, hasError ) =
                    case mx of
                        Just x ->
                            ( x :: xs, hasError )

                        Nothing ->
                            ( xs, True )
            in
                foldr func ( [], False ) xs
    in
        list (maybe decoder) |> map filter
