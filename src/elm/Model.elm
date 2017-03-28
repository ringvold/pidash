module Model exposing (Model, init)

import Time exposing (Time, second)
import Dict exposing (Dict)
import Types exposing (..)
import Msg exposing (..)


-- MODEL


type alias Model =
    { lineStops : Dict Int LineStop
    , currentTime : Maybe Time.Time
    , url : String
    , showForm : Bool
    , newLineStopForm : LineStop
    }


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            Dict.fromList
                [ ( 3012122, LineStop "Storo sør" 3012122 [] All )
                , ( 3010443, LineStop "Grefsenveien nord" 3010443 [] All )
                , ( 3010443, LineStop "Grefsenveien sør" 3010443 [] A )
                ]

        url =
            "http://localhost:8081/"

        newLineStopForm : LineStop
        newLineStopForm =
            LineStop "Grefsenveien sør" 3010443 [] A

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , url = url
            , showForm = False
            , newLineStopForm = newLineStopForm
            }
    in
        model ! []
