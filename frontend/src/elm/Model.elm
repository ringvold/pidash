module Model exposing (Model, init)

import Time exposing (Time, second)
import Task exposing (..)
import Dict exposing (Dict)
import Types exposing (..)
import Msg exposing (..)
import Api exposing (getDeparture)


-- MODEL


type alias Model =
    { lineStops : Dict Int LineStop
    , currentTime : Maybe Time.Time
    , url : String
    , showForm : Bool
    , newLineStop : LineStop
    }


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            Dict.fromList
                [ ( 3012122, LineStop "Storo sør" 3012122 [] B )
                , ( 3010443, LineStop "Grefsenveien nord" 3010443 [] A )
                ]

        url =
            "http://localhost:8081/ruter/"

        newLineStop : LineStop
        newLineStop =
            LineStop "Grefsenveien sør" 3010443 [] A

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
        , Dict.values model.lineStops
            |> List.map (\stop -> getDeparture stop model.url)
            |> List.append [ Task.perform TimeReceived Time.now ]
            |> Cmd.batch
        )
