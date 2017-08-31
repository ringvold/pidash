module Data.Stop exposing (..)

import RemoteData exposing (WebData)
import Data.VehicleArrivalTime exposing (VehicleArrivalTime, Direction)


type alias LineStop =
    { name : String
    , id : Int
    , direction : Direction
    , departures : WebData Departures
    }


type alias Departures =
    List VehicleArrivalTime
