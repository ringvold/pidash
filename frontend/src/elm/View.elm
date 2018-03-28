module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)


--import Date.Extra as DE
--import Date

import RemoteData exposing (WebData)
import Http
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
        div []
            [ div [ class "header container-fluid" ]
                [ h1 [ class "title" ]
                    [ span [ class activeIndicator ] [ text "Avganger" ]
                    ]
                , viewClosestForecast model.forecasts
                ]
            , div [ class "container-fluid", onClick RefreshTriggered ] [ viewLineStops model ]
            ]


viewClosestForecast : WebData (List Forecast) -> Html Msg
viewClosestForecast forecasts =
    let
        wrapper =
            div [ class "quick-forecast", onClick ForecastRequested ]
    in
        case forecasts of
            RemoteData.Success casts ->
                case List.head casts of
                    Just forecast ->
                        wrapper
                            [ div [ class "col1" ]
                                [ div [ class "temperature" ] [ text <| forecast.temperature ++ " °C" ]
                                , div [ class "symbol-name" ] [ text forecast.symbol.name ]
                                ]
                            , img [ src <| symbolSvg forecast.symbol.var ] []
                            ]

                    Nothing ->
                        wrapper
                            [ text "-"
                            ]

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
