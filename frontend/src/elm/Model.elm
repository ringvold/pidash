module Model exposing (Model, ActivePeriodStatus(..), init)

import Time exposing (Time, second)
import Task exposing (..)
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture, getStops)


-- MODEL


type alias Model =
    { lineStops : WebData (List LineStop)
    , currentTime : Maybe Time.Time
    , showForm : Bool
    , newLineStop : LineStop
    , activePeriod : ActivePeriodStatus
    }


type ActivePeriodStatus
    = Inactive
    | Active Time


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            NotAsked

        newLineStop : LineStop
        newLineStop =
            LineStop "Grefsenveien sør" 3010443 A Loading

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , showForm = False
            , newLineStop = newLineStop
            , activePeriod = Inactive
            }
    in
        ( model
        , (initCmds model.lineStops)
        )


initCmds : RemoteData e (List LineStop) -> Cmd Msg
initCmds lineStops =
    case lineStops of
        Success stops ->
            stops
                |> List.map (\stop -> getDeparture stop)
                |> List.append [ Task.perform TimeReceived Time.now ]
                |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
                |> Cmd.batch

        NotAsked ->
            getStops

        _ ->
            Cmd.none
