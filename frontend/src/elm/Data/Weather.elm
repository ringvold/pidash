module Data.Weather exposing (Forecast, Symbol, decodeForecast)

import Time
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as JDE


type alias Forecast =
    { temperature : String
    , symbol : Symbol
    , from : Time.Posix
    , to : Time.Posix
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
                (Decode.field "FromTime" JDE.datetime)
                (Decode.field "ToTime" JDE.datetime)
            )
        )


decodeTemperature : Decoder String
decodeTemperature =
    Decode.map String.fromInt (Decode.at [ "Value" ] Decode.int)


decodeSymbol : Decoder Symbol
decodeSymbol =
    Decode.map3 Symbol
        (Decode.field "Number" Decode.string)
        (Decode.field "Name" Decode.string)
        (Decode.field "Var" Decode.string)
