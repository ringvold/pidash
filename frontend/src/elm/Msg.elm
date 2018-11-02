module Msg exposing (Msg(..))

import Data.Direction exposing (Direction)
import Data.LineStop exposing (Departures, LineStop, StopId)
import Data.StopPlace exposing (Response)
import Data.Weather exposing (Forecast)
import Graphql.Http
import RemoteData exposing (RemoteData, WebData)
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
    | StopReceived String (RemoteData (Graphql.Http.Error Response) Response)
    | ForecastRequested
    | ForecastReceived (WebData (List Forecast))
