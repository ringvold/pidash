module View.NewLineStop exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (Msg(..))
import Helpers exposing (directionToComparable)
import Types exposing (Direction(..))


-- NEW LINESTOP VIEW


view : Html Msg
view =
    Html.form [ onSubmit FormSubmitTriggered, class "form" ]
        [ h2 [] [ text "Form" ]
        , div [ class "form-group" ]
            [ label [ for "name " ] [ text "Name" ]
            , input [ onInput FormNameChanged, id "name", name "name", class "form-control" ] []
            ]
        , div
            [ class "form-group" ]
            [ label [ for "id" ] [ text "Ruter id" ]
            , input [ onInput FormIdChanged, name "id", class "form-control" ] []
            ]
        , div [ class "form-group" ]
            [ label [ for "direction" ] [ text "Direction" ]
            , select [ onInput FormDirectionChanged, name "direction", class "form-control" ] <|
                options
            ]
        , button [ class "btn" ] [ text "Lagre" ]
        ]


options : List (Html Msg)
options =
    [ option [ value (directionToComparable A) ] [ text (directionToComparable A) ]
    , option [ value (directionToComparable B) ] [ text (directionToComparable B) ]
    ]
