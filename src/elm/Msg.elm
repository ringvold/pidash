module Msg exposing (Msg(..))

import Time exposing (Time, second)
import Http
import Types exposing (..)


-- MSG


type Msg
    = NoOp
    | TimeRequested
    | TimeReceived Time
    | DeparturesRequested
    | DeparturesReceived (Result Http.Error Departures)
    | NewLineStopClicked
