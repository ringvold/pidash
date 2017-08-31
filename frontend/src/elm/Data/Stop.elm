module Data.Stop exposing (..)

import Json.Decode as Decode
import RemoteData exposing (WebData)
import Data.VehicleArrivalTime exposing (VehicleArrivalTime)
import Data.Direction exposing (Direction, decodeDirection)


type alias Departures =
    List VehicleArrivalTime


type alias LineStop =
    { name : String
    , id : Int
    , direction : Direction
    , departures : WebData Departures
    }


decodeStops : Decode.Decoder (List LineStop)
decodeStops =
    Decode.list
        (Decode.map4 LineStop
            (Decode.field "name" Decode.string)
            (Decode.field "id" Decode.int)
            (Decode.field "direction" Decode.int |> Decode.andThen decodeDirection)
            (Decode.succeed RemoteData.NotAsked)
        )
