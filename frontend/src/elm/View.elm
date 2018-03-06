module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)


--import Date.Extra as DE
--import Date

import RemoteData
import Msg exposing (..)
import Model exposing (Model, ActivePeriodStatus(..), init)
import View.Transit as Transit
import Data.Weather exposing (Forecast)


-- VIEW


view : Model -> Html Msg
view model =
    let
        activeIndicator =
            case model.activePeriod of
                Active time ->
                    "label label-success"

                Inactive ->
                    "label label-default"
    in
        div [ class "container-fluid", onClick RefreshTriggered ]
            [ div []
                [ h1 [ class "title" ]
                    [ span [ class activeIndicator ] [ text "Avganger" ]
                    ]
                , viewClosestForecast <| List.head model.forecasts
                ]
            , viewLineStops model
            ]


viewClosestForecast forecast =
    case forecast of
        Just forecast ->
            div [ class "quick-forecast" ] [ img [ src <| symbolSvg forecast.symbol ] [] ]

        Nothing ->
            text ""


symbolSvg : String -> String
symbolSvg symbol =
    "/static/symbol/svg/" ++ symbol ++ ".svg"


viewLineStops : Model -> Html Msg
viewLineStops model =
    case model.lineStops of
        RemoteData.Success stops ->
            lazy2 Transit.viewStops stops model.currentTime

        RemoteData.NotAsked ->
            div [] [ text "No stops available. Have you remembered to add stops to the configuration file?" ]

        RemoteData.Loading ->
            div [] [ h2 [ class "text-center" ] [ text "LOADING STOPS!1!" ] ]

        RemoteData.Failure err ->
            div [] [ text <| toString err ]
