module View.Weather exposing (symbolSvg, timePeriod, viewForecast, viewForecasts)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (..)
import Time
import Weather exposing (Forecast)


viewForecasts : List Forecast -> List (Html Msg)
viewForecasts forecasts =
    List.map viewForecast forecasts


viewForecast : Forecast -> Html Msg
viewForecast forecast =
    div [ class "forecast" ]
        [ div [ class "col1", onClick ForecastRequested ]
            [ div [ class "temperature" ] [ text <| forecast.temperature ++ " °C" ]
            , div [ class "img-wrapper" ] [ img [ src <| symbolSvg forecast.symbol.var ] [] ]
            ]
        , div [ class "symbol-name" ]
            [ span [ class "periode" ] [ text <| timePeriod forecast ]
            , span [ class "tekst-status" ] [ text forecast.symbol.name ]
            ]
        ]


timePeriod : Forecast -> String
timePeriod forecast =
    let
        from =
            String.padLeft 2 '0' <| String.fromInt <| Time.toHour Time.utc forecast.from

        to =
            String.padLeft 2 '0' <| String.fromInt <| Time.toHour Time.utc forecast.to
    in
    "kl. " ++ from ++ "-" ++ to ++ ": "


symbolSvg : String -> String
symbolSvg symbol =
    "/static/symbol/svg/" ++ symbol ++ ".svg"
