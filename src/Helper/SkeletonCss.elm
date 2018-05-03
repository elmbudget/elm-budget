module Helper.SkeletonCss exposing (row, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, container)

import Html exposing (div)
import Html.Attributes exposing (class)


classer : String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
classer cls attributes content =
    div (class cls :: attributes) content


container : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
container =
    classer "container"


row : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
row =
    classer "row"


col1 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col1 =
    classer "one column"


col2 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col2 =
    classer "two columns"


col3 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col3 =
    classer "three columns"


col4 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col4 =
    classer "four columns"


col5 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col5 =
    classer "five columns"


col6 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col6 =
    classer "six columns"


col7 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col7 =
    classer "seven columns"


col8 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col8 =
    classer "eight columns"


col9 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col9 =
    classer "nine columns"


col10 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col10 =
    classer "ten columns"


col11 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col11 =
    classer "eleven columns"


col12 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col12 =
    classer "twelve columns"
