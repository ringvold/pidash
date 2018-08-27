module Msg exposing (Msg(..))

import Time exposing (Posix)
import RemoteData exposing (WebData)
import Data.LineStop exposing (Departures, LineStop, StopId)
import Data.Direction exposing (Direction)
import Data.Weather exposing (Forecast)


-- MSG


type Msg
    = NoOp
    | RefreshTriggered
    | TimeRequested
    | TimeReceived Posix
    | DeparturesRequested
    | DeparturesReceived String Direction (WebData Departures)
    | ActivePeriodStartReceived Posix
    | ActivePeriodDeactivationTriggered
    | StopsRequested
    | StopsReceived (WebData (List LineStop))
    | ForecastRequested
    | ForecastReceived (WebData (List Forecast))
