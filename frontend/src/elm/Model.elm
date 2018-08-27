module Model exposing (Model, ActivePeriodStatus(..), init)

import Time


--import Date

import RemoteData exposing (WebData, RemoteData(..))
import Data.LineStop exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture, getStops, getForecast)
import Data.Weather exposing (Forecast, Symbol)


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
