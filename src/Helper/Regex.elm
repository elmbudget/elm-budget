module Helper.Regex exposing (..)

import Regex exposing (..)


email : Regex
email =
    regex "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
