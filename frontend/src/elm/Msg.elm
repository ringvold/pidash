module Msg exposing (Msg(..))

import Time exposing (Time, second)
import RemoteData exposing (WebData)
import Data.Stop exposing (Departures, LineStop, StopId)
import Data.Direction exposing (Direction)


-- MSG


type Msg
    = NoOp
    | HeaderTriggered
    | TimeRequested
    | TimeReceived Time
    | DeparturesRequested
    | DeparturesReceived String Direction (WebData Departures)
    | ActivePeriodStartReceived Time
    | ActivePeriodDeactivationTriggered
    | StopsRequested
    | StopsReceived (WebData (List LineStop))
