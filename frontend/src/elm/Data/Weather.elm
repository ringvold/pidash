module Data.Weather exposing (Forecast, Symbol, decodeForecast)

import Json.Decode as Decode exposing (Decoder)
import Date exposing (Date)


type alias Forecast =
    { temperature : String
    , symbol : Symbol
    , from : Date
    , to : Date
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
                (Decode.field "FromTime" (Decode.map toDate Decode.string))
                (Decode.field "ToTime" (Decode.map toDate Decode.string))
            )
        )


toDate : String -> Date
toDate dateTimeString =
    Date.fromString dateTimeString |> Result.withDefault (Date.fromTime 0)


decodeTemperature : Decoder String
decodeTemperature =
    Decode.map toString (Decode.at [ "Value" ] Decode.int)


decodeSymbol : Decoder Symbol
decodeSymbol =
    Decode.map3 Symbol
        (Decode.field "Number" Decode.string)
        (Decode.field "Name" Decode.string)
        (Decode.field "Var" Decode.string)
