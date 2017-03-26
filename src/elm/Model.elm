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
    }


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            Dict.fromList
                [ ( 3012122, LineStop "Storo sør" 3012122 [] 0 )
                , ( 3010443, LineStop "Grefsenveien nord" 3010443 [] 0 )
                , ( 3010443, LineStop "Grefsenveien sør" 3010443 [] 1 )
                ]

        url =
            "http://localhost:8081/"

        model =
            { lineStops = lineStops
            , currentTime = Nothing
            , url = url
            , showForm = False
            }
    in
        model ! []
