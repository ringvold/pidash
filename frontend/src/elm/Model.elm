module Model exposing (ActivePeriodStatus(..), Model, init)

--import Date

import Api exposing (getDeparture, getForecast, getStops)
import Data.LineStop exposing (..)
import Data.Weather exposing (Forecast, Symbol)
import Msg exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Time



-- MODEL


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Posix
    , activePeriod : ActivePeriodStatus
    , forecasts : WebData (List Forecast)
    }


type ActivePeriodStatus
    = Inactive
    | Active Time.Posix


init : flags -> ( Model, Cmd Msg )
init flags =
    let
        lineStops =
            Loading

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , activePeriod = Inactive
            , forecasts = Loading
            }
    in
    ( model, Cmd.batch [ getStops, getForecast ] )
