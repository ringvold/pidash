module Msg exposing (Msg(..))

import Data.Entur exposing (Response)
import Data.LineStop exposing (Departures, LineStop, StopId)
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
    | ActivePeriodStartReceived Posix
    | ActivePeriodDeactivationTriggered
    | StopsRequested
    | StopsReceived (WebData (List LineStop))
    | StopPlaceReceived String String (RemoteData (Graphql.Http.Error Response) Response)
    | ForecastRequested
    | ForecastReceived (WebData (List Forecast))
