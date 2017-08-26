module Types exposing (..)

import Date exposing (Date)
import RemoteData exposing (WebData)


-- TYPES


type alias LineStop =
    { name : String
    , id : Int
    , direction : Direction
    , departures : WebData Departures
    }


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , direction : Direction
    , expectedArrivalTime : Date
    , lineId : Int
    }


type Direction
    = A
    | B
    | Unknown


type alias Departures =
    List VehicleArrivalTime
