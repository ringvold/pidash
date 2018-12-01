module Model exposing (ActivePeriodStatus(..), GraphqlData, Model, init)

--import Date

import Api
import Data.Entur exposing (EstimatedCall, Response)
import Data.LineStop exposing (..)
import Data.Weather exposing (Forecast, Symbol)
import Dict exposing (Dict)
import Graphql.Http
import Msg exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Time



-- MODEL


type alias GraphqlData =
    RemoteData (Graphql.Http.Error Response) Response


type ActivePeriodStatus
    = Inactive
    | Active Time.Posix


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Posix
    , activePeriod : ActivePeriodStatus
    , forecasts : WebData (List Forecast)
    , departures : Dict String Departures
    }


init : flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { lineStops = Loading
            , currentTime = Nothing
            , activePeriod = Inactive
            , forecasts = Loading
            , departures = Dict.empty
            }
    in
    ( model
    , Cmd.batch
        [ Api.getStops
        , Api.getForecast
        ]
    )
