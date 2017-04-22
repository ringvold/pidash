module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)
import View.NewLineStop as NewLineStop
import Msg exposing (..)
import Model exposing (Model, init)
import View.LineStop as LineStop


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container-fluid" ]
        [ h1 [ onClick DeparturesRequested ] [ text "Avganger" ]
        , button [ onClick NewLineStopClicked, class "btn btn-primary" ] [ text "Legg til stopp" ]
        , if model.showForm then
            NewLineStop.view
          else
            text ""
        , lazy2 LineStop.view (model.lineStops) model.currentTime
        ]
