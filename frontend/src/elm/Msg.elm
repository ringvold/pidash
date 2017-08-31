module Msg exposing (Msg(..))

import Time exposing (Time, second)
import RemoteData exposing (WebData)
import Data.Stop exposing (Departures, LineStop)
import Data.Direction exposing (Direction)


-- MSG


type Msg
    = NoOp
    | HeaderTriggered
    | TimeRequested
    | TimeReceived Time
    | DeparturesRequested
    | DeparturesReceived Int Direction (WebData Departures)
    | ActivePeriodStartReceived Time
    | ActivePeriodDeactivationTriggered
    | StopsRequested
    | StopsReceived (WebData (List LineStop))
