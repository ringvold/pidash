module Model exposing (Model, init)

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
    , url : String
    , showForm : Bool
    , newLineStop : LineStop
    }


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            [ LineStop "Storo sør" 3012122 NotAsked B
            , LineStop "Grefsenveien nord" 3010443 NotAsked B
            , LineStop "Grefsenveien sør" 3010443 NotAsked A
            ]

        url =
            "http://localhost:8081/ruter/"

        newLineStop : LineStop
        newLineStop =
            LineStop "Grefsenveien sør" 3010443 Loading A

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , url = url
            , showForm = False
            , newLineStop = newLineStop
            }
    in
        -- Not ideal inlining Cmds but others ways make circular dependencies with this file
        ( model
        , model.lineStops
            |> List.map (\stop -> getDeparture stop model.url)
            |> List.append [ Task.perform TimeReceived Time.now ]
            |> Cmd.batch
        )
