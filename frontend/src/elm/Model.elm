module Model exposing (Model, ActivePeriodStatus(..), init)

import Time exposing (Time, second)
import Task exposing (..)
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture)


-- MODEL


type alias Model =
    { lineStops : List LineStop
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
            [ LineStop "Storo sør" 3012122 Loading A
            , LineStop "Grefsenveien nord" 3010443 Loading A
            , LineStop "Grefsenveien sør" 3010443 Loading B
            ]

        newLineStop : LineStop
        newLineStop =
            LineStop "Grefsenveien sør" 3010443 Loading A

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , showForm = False
            , newLineStop = newLineStop
            , activePeriod = Inactive
            }
    in
        ( model
        , model.lineStops
            |> List.map (\stop -> getDeparture stop)
            |> List.append [ Task.perform TimeReceived Time.now ]
            |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
            |> Cmd.batch
        )
