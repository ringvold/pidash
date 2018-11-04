module Model exposing (ActivePeriodStatus(..), EnturResponse, Model, StopPlaces, init)

--import Date

import Api
import Data.LineStop exposing (..)
import Data.StopPlace exposing (Response)
import Data.Weather exposing (Forecast, Symbol)
import Dict exposing (Dict)
import Graphql.Http
import Msg exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Time


-- MODEL


type alias EnturResponse =
    RemoteData (Graphql.Http.Error Response) Response


type alias StopPlaces =
    Dict String EnturResponse


type ActivePeriodStatus
    = Inactive
    | Active Time.Posix


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Posix
    , activePeriod : ActivePeriodStatus
    , forecasts : WebData (List Forecast)
    , stopPlaces : WebData StopPlaces
    }


init : flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { lineStops = Loading
            , currentTime = Nothing
            , activePeriod = Inactive
            , forecasts = Loading
            , stopPlaces = Success Dict.empty
            }
    in
        ( model
        , Cmd.batch
            [ Api.getStops
            , Api.getForecast
            , Api.getStopPlaces [ "NSR:StopPlace:58196", "NSR:StopPlace:58195", "Finnesikke" ]
            ]
        )
