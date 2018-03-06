module Model exposing (Model, ActivePeriodStatus(..), init)

import Time exposing (Time, second)


--import Date

import RemoteData exposing (WebData, RemoteData(..))
import Data.LineStop exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture, getStops)
import Data.Weather exposing (Forecast)


-- MODEL


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Time
    , activePeriod : ActivePeriodStatus
    , forecasts : List Forecast
    }


type ActivePeriodStatus
    = Inactive
    | Active Time


forecasts =
    [ Forecast "-19" "01d" "2018-02-23T19:00:00" "2018-02-24T00:00:00"
    , Forecast "-19" "03d" "2018-02-23T19:00:00" "2018-02-24T00:00:00"
    , Forecast "-19" "23" "2018-02-23T19:00:00" "2018-02-24T00:00:00"
    ]


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            Loading

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , activePeriod = Inactive
            , forecasts = forecasts
            }
    in
        model ! [ getStops ]
