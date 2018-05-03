module DatePicker.Settings exposing (..)

import DatePicker exposing (defaultSettings)


settings : DatePicker.Settings
settings =
    { defaultSettings
        | inputClassList = [ ( "form-control", True ) ]
        , inputId = Just "datepicker"
    }
