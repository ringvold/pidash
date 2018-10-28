module Msg exposing (Msg(..))

import Data.Direction exposing (Direction)
import Data.LineStop exposing (Departures, LineStop, StopId)
import Data.Weather exposing (Forecast)
import RemoteData exposing (WebData)
import Time exposing (Posix)



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
