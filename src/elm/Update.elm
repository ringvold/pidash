module Update exposing (update)

import Dict exposing (Dict)
import Task exposing (perform)
import Time exposing (Time, second)
import Types exposing (..)
import Model exposing (..)
import Msg exposing (Msg(..))
import Api exposing (getDeparture)


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        TimeRequested ->
            model ! [ Task.perform TimeReceived Time.now ]

        TimeReceived time ->
            { model | currentTime = Just time } ! []

        DeparturesRequested ->
            ( model
            , fetchDepartures model
            )

        DeparturesReceived (Ok departures) ->
            ( { model | lineStops = updateLineStop model.lineStops departures }
            , Cmd.none
            )

        DeparturesReceived (Err _) ->
            model ! []

        NewLineStopClicked ->
            if model.showForm then
                { model | showForm = False } ! []
            else
                { model | showForm = True } ! []



-- Update functions


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    Dict.values model.lineStops
        |> List.map (\stop -> getDeparture stop model.url)
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch


updateLineStop : Dict Int LineStop -> Response -> Dict Int LineStop
updateLineStop lineStops departures =
    let
        lineId =
            getLineId departures
    in
        case Dict.get lineId lineStops of
            Just lineStop ->
                Dict.insert lineId ({ lineStop | departures = departures }) lineStops

            Nothing ->
                lineStops


showForm : Model -> Model
showForm model =
    { model | showForm = True }



-- Helper functions


getLineId : Response -> Int
getLineId departures =
    let
        departure : Maybe VehicleArrivalTime
        departure =
            (List.head departures)
    in
        case departure of
            Just departure ->
                departure.lineId

            Nothing ->
                -1
