module Types exposing (..)

import Date exposing (Date)


-- TYPES


type alias LineStop =
    { name : String
    , id : Int
    , departures : List VehicleArrivalTime
    , direction : Int
    }


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , directionRef : String
    , expectedArrivalTime : Date
    , lineId : Int
    }


type alias Response =
    List VehicleArrivalTime
