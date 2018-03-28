module Model exposing (Model, ActivePeriodStatus(..), init)

import Time exposing (Time, second)


--import Date

import RemoteData exposing (WebData, RemoteData(..))
import Data.LineStop exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture, getStops, getForecast)
import Data.Weather exposing (Forecast, Symbol)


-- MODEL


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Time
    , activePeriod : ActivePeriodStatus
    , forecasts : WebData (List Forecast)
    }


type ActivePeriodStatus
    = Inactive
    | Active Time


symbol =
    Symbol "4" "Skyet" "04"


forecasts =
    [ Forecast "-19" symbol "2018-02-23T19:00:00" "2018-02-24T00:00:00"
    , Forecast "-19" symbol "2018-02-23T19:00:00" "2018-02-24T00:00:00"
    , Forecast "-19" symbol "2018-02-23T19:00:00" "2018-02-24T00:00:00"
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
            , forecasts = Loading
            }
    in
        model ! [ getStops, getForecast ]
