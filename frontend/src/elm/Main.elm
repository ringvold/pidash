module Main exposing (main)

import Browser
import Model exposing (Model, init)
import Msg exposing (Msg)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)



-- MAIN


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
