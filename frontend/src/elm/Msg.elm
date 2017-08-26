module Msg exposing (Msg(..))

import Time exposing (Time, second)
import RemoteData exposing (WebData)
import Types exposing (..)


-- MSG


type Msg
    = NoOp
    | HeaderTriggered
    | TimeRequested
    | TimeReceived Time
    | DeparturesRequested
    | DeparturesReceived Int Direction (WebData Departures)
    | NewLineStopClicked
    | FormNameChanged String
    | FormIdChanged String
    | FormDirectionChanged String
    | FormSubmitTriggered
    | ActivePeriodStartReceived Time
    | ActivePeriodDeactivationTriggered
    | StopsRequested
    | StopsReceived (WebData (List LineStop))
