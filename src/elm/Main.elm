module Main exposing (main)

import Html
import Msg
import Model exposing (Model, init)
import Update exposing (update)
import View exposing (view)
import Subscriptions exposing (subscriptions)
import Msg exposing (Msg)


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
