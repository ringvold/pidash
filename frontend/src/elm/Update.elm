module Update exposing (update)

import Dict exposing (Dict)
import Task exposing (perform)
import Time exposing (Time, second)
import Types exposing (..)
import Model exposing (..)
import Msg exposing (Msg(..))
import Api exposing (getDeparture)
import Helpers exposing (..)


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

        FormNameChanged value ->
            { model | newLineStop = (updateNewName model.newLineStop value) } ! []

        FormIdChanged value ->
            { model | newLineStop = (updateNewId model.newLineStop value) }
                ! []

        FormDirectionChanged value ->
            { model | newLineStop = (updateNewDirection model.newLineStop value) } ! []

        FormSubmitTriggered ->
            hideForm model
                |> addLineStop



-- Update functions


hideForm : Model -> Model
hideForm model =
    { model | showForm = False }


addLineStop : Model -> ( Model, Cmd Msg )
addLineStop model =
    let
        newModel =
            { model | lineStops = Dict.insert model.newLineStop.id model.newLineStop model.lineStops }
    in
        ( newModel, fetchDepartures newModel )


updateNewName : LineStop -> String -> LineStop
updateNewName lineStop newName =
    { lineStop | name = newName }


updateNewId : LineStop -> String -> LineStop
updateNewId lineStop newId =
    { lineStop | id = convertId newId }


updateNewDirection : LineStop -> String -> LineStop
updateNewDirection lineStop newDirection =
    { lineStop | direction = stringToDirection newDirection }


convertId : String -> Int
convertId id =
    Result.withDefault 0 (String.toInt id)


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    Dict.values model.lineStops
        |> List.map (\stop -> getDeparture stop model.url)
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch


updateLineStop : Dict Int LineStop -> Departures -> Dict Int LineStop
updateLineStop lineStops departures =
    let
        lineId =
            getLineId departures
    in
        case Dict.get lineId lineStops of
            Just lineStop ->
                Dict.insert lineId
                    ({ lineStop | departures = (getLineStopByDirection lineStop.direction departures) })
                    lineStops

            Nothing ->
                lineStops


showForm : Model -> Model
showForm model =
    { model | showForm = True }



-- Helper functions


getLineStopByDirection : Direction -> Departures -> Departures
getLineStopByDirection direction departures =
    List.filterMap (hasDirection direction) departures


hasDirection : Direction -> VehicleArrivalTime -> Maybe VehicleArrivalTime
hasDirection direction departure =
    let
        departureDirection =
            directionToComparable departure.direction

        lineStopDirection =
            directionToComparable direction

        allDirections =
            directionToComparable All
    in
        if lineStopDirection == allDirections then
            Just
                departure
        else if departureDirection == lineStopDirection then
            Just
                departure
        else
            Nothing


getLineId : Departures -> Int
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
