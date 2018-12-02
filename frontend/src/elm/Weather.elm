module Weather exposing (Forecast, Symbol, decodeForecast)

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as JDE
import Time


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
                (Decode.field "FromTime" datetime)
                (Decode.field "ToTime" datetime)
            )
        )


datetime : Decoder Time.Posix
datetime =
    Decode.andThen
        (\dateString ->
            -- Adding offset to datetime to be valid ISO-8610 as this is missing from yr.no forecast
            case Iso8601.toTime <| dateString ++ "+02:00" of
                Ok v ->
                    Decode.succeed v

                Err _ ->
                    Decode.fail "Expecting an ISO-8601 formatted date+time string"
        )
        Decode.string


decodeTemperature : Decoder String
decodeTemperature =
    Decode.map String.fromInt (Decode.at [ "Value" ] Decode.int)


decodeSymbol : Decoder Symbol
decodeSymbol =
    Decode.map3 Symbol
        (Decode.field "Number" Decode.string)
        (Decode.field "Name" Decode.string)
        (Decode.field "Var" Decode.string)
