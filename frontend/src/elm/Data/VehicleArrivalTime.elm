module Data.VehicleArrivalTime exposing (..)

import Time
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Pipeline as JDP
import Json.Decode.Extra as JDE
import Data.Direction exposing (Direction, decodeDirection)


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , direction : Direction
    , expectedArrivalTime : Time.Posix
    , lineId : String
    }


decodeArrivals : Decode.Decoder (List VehicleArrivalTime)
decodeArrivals =
    Decode.list vehicleArrivalTime


vehicleArrivalTime : Decode.Decoder VehicleArrivalTime
vehicleArrivalTime =
    Decode.succeed VehicleArrivalTime
        |> JDP.required "destinationName" string
        |> JDP.required "publishedLineName" string
        |> JDP.required "vehicleMode" int
        |> JDP.required "directionRef" direction
        |> JDP.required "expectedArrivalTime" JDE.datetime
        |> JDP.required "lineId" string


direction : Decoder Direction
direction =
    Decode.int |> Decode.andThen decodeDirection
