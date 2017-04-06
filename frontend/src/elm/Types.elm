module Types exposing (..)

import Date exposing (Date)


-- TYPES


type alias LineStop =
    { name : String
    , id : Int
    , departures : Departures
    , direction : Direction
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
    = All
    | A
    | B


type alias Departures =
    List VehicleArrivalTime
