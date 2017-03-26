module Subscriptions exposing (subscriptions)

import Time
import Model exposing (Model)
import Msg exposing (Msg(..))


--  SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (10 * Time.second) (\_ -> DeparturesRequested) ]
