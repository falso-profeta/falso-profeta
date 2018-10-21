module Style exposing (fabButton, headerFont, textFont)

import Css exposing (..)
import Html.Styled exposing (Attribute)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)



--- GENERIC STYLES -------------------------------------------------------------
-- Fonts


headerFont =
    fontFamilies [ "Zilla Slab", "sans" ]


textFont =
    fontFamilies [ "Roboto", "sans" ]


fabButton : Attribute msg
fabButton =
    class "btn"
