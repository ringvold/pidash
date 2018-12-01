module View exposing (errToString, view, viewClosestForecast)

import Data.Entur exposing (Response, StopPlace)
import Data.Weather exposing (Forecast)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy3)
import Http
import Model exposing (ActivePeriodStatus(..), Model)
import Msg exposing (..)
import RemoteData exposing (WebData)
import View.Transit as Transit
import View.Weather


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
        div []
            [ div [ class "header container-fluid" ]
                [ h1 [ class "title" ]
                    [ span [ class activeIndicator ] [ text "Avganger" ]
                    ]
                , viewClosestForecast model.forecasts
                ]
            , div
                [ class "container-fluid", onClick RefreshTriggered ]
                [ viewStopPlaces model ]
            ]


viewClosestForecast : WebData (List Forecast) -> Html Msg
viewClosestForecast forecasts =
    let
        wrapper =
            div [ class "quick-forecast", onClick ForecastRequested ]
    in
        case forecasts of
            RemoteData.Success casts ->
                List.take 2 casts
                    |> List.map View.Weather.viewForecast
                    |> wrapper

            RemoteData.Failure err ->
                case err of
                    Http.BadPayload error _ ->
                        wrapper
                            [ text error
                            ]

                    _ ->
                        wrapper
                            [ text "err"
                            ]

            _ ->
                wrapper
                    [ text "-"
                    ]


viewStopPlaces : Model -> Html Msg
viewStopPlaces model =
    case model.lineStops of
        RemoteData.Success stops ->
            lazy3 Transit.viewStopPlaces stops model.departures model.currentTime

        RemoteData.NotAsked ->
            div [] [ text "No stops available. Have you remembered to add stops to the configuration file?" ]

        RemoteData.Loading ->
            div [] [ h2 [ class "text-center" ] [ text "LOADING STOPS!1!" ] ]

        RemoteData.Failure err ->
            div [] [ text "ERROR!!!!1!!!" ]


errToString : Http.Error -> String
errToString error =
    case error of
        Http.BadUrl err ->
            "BadUrl " ++ err

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus res ->
            "BadStatus " ++ String.fromInt res.status.code ++ ": " ++ res.status.message

        Http.BadPayload string res ->
            "BadPayload " ++ string ++ ": " ++ res.body
