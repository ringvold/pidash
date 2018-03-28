module Data.Weather exposing (Forecast, Symbol, decodeForecast)

import Json.Decode as Decode exposing (Decoder)


type alias Forecast =
    { temperature : String
    , symbol : Symbol
    , from : String
    , to : String
    }


type alias Symbol =
    { number : String
    , name : String
    , var : String
    }


decodeForecast : Decoder (List Forecast)
decodeForecast =
    Decode.at [ "Forecasts" ]
        (Decode.list
            (Decode.map4 Forecast
                (Decode.field "Temperature" decodeTemperature)
                (Decode.field "Symbol" decodeSymbol)
                (Decode.field "FromTime" Decode.string)
                (Decode.field "ToTime" Decode.string)
            )
        )


decodeTemperature : Decoder String
decodeTemperature =
    Decode.map toString (Decode.at [ "Value" ] Decode.int)


decodeSymbol : Decoder Symbol
decodeSymbol =
    Decode.map3 Symbol
        (Decode.field "Number" Decode.string)
        (Decode.field "Name" Decode.string)
        (Decode.field "Var" Decode.string)
