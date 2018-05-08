module View.Weather exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (..)
import Data.Weather exposing (Forecast)


viewForecasts : List Forecast -> List (Html Msg)
viewForecasts forecasts =
    List.map viewForecast forecasts


viewForecast : Forecast -> Html Msg
viewForecast forecast =
    div [ class "forecast" ]
        [ div [ class "col1", onClick ForecastRequested ]
            [ div [ class "temperature" ] [ text <| forecast.temperature ++ " °C" ]
            , div [ class "symbol-name" ] [ text forecast.symbol.name ]
            ]
        , img [ src <| symbolSvg forecast.symbol.var ] []
        ]


symbolSvg : String -> String
symbolSvg symbol =
    "/static/symbol/svg/" ++ symbol ++ ".svg"
