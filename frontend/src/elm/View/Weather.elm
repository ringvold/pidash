module View.Weather exposing (..)


viewForecasts : List Forecast -> List (Html msg)
viewForecasts forecasts =
    List.map viewForecast forecasts


viewForecast : Forecast -> Html msg
viewForecast forecast =
    div [ class "forecast col-sm-4" ]
        [ img [ src <| "/static/symbol/svg/" ++ forecast.symbol ++ ".svg" ] []
        , h1 [] [ text forecast.temperature ]
        ]
