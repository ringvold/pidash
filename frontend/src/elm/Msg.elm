module Msg exposing (Msg(..))

import Entur exposing (Response)
import Graphql.Http
import LineStop exposing (Departures, LineStop, StopId)
import RemoteData exposing (RemoteData, WebData)
import Time exposing (Posix)
import Weather exposing (Forecast)



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
