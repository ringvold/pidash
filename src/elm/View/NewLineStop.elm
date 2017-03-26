module View.NewLineStop exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (Msg(..))


-- NEW LINESTOP VIEW


view : Html Msg
view =
    Html.form [ class "form" ]
        [ h2 [] [ text "Form" ]
        , div [ class "form-group" ]
            [ label [ for "name " ] [ text "Name" ]
            , input [ id "name", name "name", class "form-control" ] []
            ]
        , div
            [ class "form-group" ]
            [ label [ for "id" ] [ text "Ruter id" ]
            , input [ name "id", class "form-control" ] []
            ]
        , div [ class "form-group" ]
            [ label [ for "direction" ] [ text "Direction" ]
            , input [ name "direction", class "form-control" ] []
            ]
        ]
