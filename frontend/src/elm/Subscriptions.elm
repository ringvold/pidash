module Subscriptions exposing (subscriptions)

import Time
import Model exposing (Model, ActivePeriodStatus(..))
import Msg exposing (Msg(..))


--  SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (15 * second) <| checkIfActivePeriod model


checkIfActivePeriod : Model -> Time.Posix -> Msg
checkIfActivePeriod model time =
    case model.activePeriod of
        Inactive ->
            NoOp

        Active startTime ->
            if (Time.posixToMillis startTime) + (5 * minute) > Time.posixToMillis time then
                DeparturesRequested
            else
                ActivePeriodDeactivationTriggered


second =
    1000


minute =
    60 * 1000
