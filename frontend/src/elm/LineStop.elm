module LineStop exposing (Departures, LineStop, StopId, decodeStops)

import Entur exposing (EstimatedCall, Response)
import Graphql.Http
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..), WebData)


type alias Departures =
    RemoteData String (List EstimatedCall)


type alias StopId =
    Int


type alias LineStop =
    { name : String
    , id : String
    , quay : String
    }


decodeStops : Decode.Decoder (List LineStop)
decodeStops =
    Decode.list
        (Decode.map3 LineStop
            (Decode.field "name" Decode.string)
            (Decode.field "id" Decode.string)
            (Decode.field "quay" Decode.string)
        )
