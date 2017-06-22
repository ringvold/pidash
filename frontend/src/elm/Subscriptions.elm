module Subscriptions exposing (subscriptions)

import Time
import Model exposing (Model, ActivePeriodStatus(..))
import Msg exposing (Msg(..))


--  SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (15 * Time.second) <| checkIfActivePeriod model


checkIfActivePeriod : Model -> Time.Time -> Msg
checkIfActivePeriod model time =
    case model.activePeriod of
        Inactive ->
            NoOp

        Active startTime ->
            if startTime + (5 * Time.minute) > time then
                DeparturesRequested
            else
                ActivePeriodDeactivationTriggered
