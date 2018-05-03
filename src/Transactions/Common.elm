module Transactions.Common exposing (..)

import Date exposing (Date)
import Transactions.Model exposing (..)
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Duration as Duration
import Date.Extra.Field as Field
import Date.Extra.Compare as Compare
import Date exposing (Date, Month(..))


type alias ValidationResult =
    { dateInvalid : Bool
    }


columnIds :
    { category : String
    , date : String
    , description : String
    , inflow : String
    , outflow : String
    , payee : String
    , balance : String
    }
columnIds =
    { description = "description"
    , date = "date"
    , payee = "payee"
    , category = "category"
    , inflow = "inflow"
    , outflow = "outflow"
    , balance = "balance"
    }


type alias DateRange =
    { from : Maybe Date
    , to : Maybe Date
    }


definiteRange : Date -> Date -> DateRange
definiteRange f t =
    { from = Just f, to = Just t }


unbounded : DateRange
unbounded =
    { from = Nothing, to = Nothing }


type alias DatePresetDict =
    { text : String
    , range : DateRange
    }



{--# Check if date is in range (ignoring time parts)
--}


isDateInRange : DateRange -> Date -> Bool
isDateInRange range date =
    (range.from |> Maybe.map (\from -> Compare.is Compare.Before from date) |> Maybe.withDefault True)
        && (range.to |> Maybe.map (\to -> Compare.is Compare.Before date to) |> Maybe.withDefault True)


defaultPreset : Date -> String
defaultPreset today = format config "%B %y" today

datePresets : Date -> List DatePresetDict
datePresets today =
    let
        monthsAgoRange n =
            let
                adjustedDate =
                    Duration.add Duration.Month -n today
            in
                { text = format config "%B %y" adjustedDate
                , range = definiteRange (firstDayOfMonth adjustedDate) (lastDayOfMonth adjustedDate)
                }
    in
        { text = "All"
        , range = unbounded
        }
            :: List.map monthsAgoRange (List.range 0 11)


firstDayOfMonth : Date -> Date
firstDayOfMonth d =
    Field.fieldToDate (Field.DayOfMonth 1) d |> Maybe.withDefault d


lastDayOfMonth : Date -> Date
lastDayOfMonth d =
    let
        firstDayOfNextMonth =
            Field.fieldToDate (Field.DayOfMonth 1) (Duration.add Duration.Month 1 d) |> Maybe.withDefault d
    in
        Duration.add Duration.Day -1 firstDayOfNextMonth


rangeFor : String -> Date -> DateRange
rangeFor presetName date =
    datePresets date
        |> List.filter (\p -> presetName == p.text)
        |> List.head
        |> Maybe.map (\p -> p.range)
        |> Maybe.withDefault
            -- Pick a sensible default to match UI (first in list). If for some weird
            -- reason there is nothing in the list fallback to unbounded
            (List.head (datePresets date)
                |> Maybe.map (.range)
                |> Maybe.withDefault unbounded
            )