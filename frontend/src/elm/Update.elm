module Update exposing (update)

import Task exposing (perform)
import Time exposing (Time, second)
import RemoteData exposing (WebData, RemoteData(..), succeed)
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

        HeaderTriggered ->
            { model | lineStops = setLoading model |> Success }
                ! [ fetchDepartures model, Task.perform ActivePeriodStartReceived Time.now ]

        TimeRequested ->
            model ! [ Task.perform TimeReceived Time.now ]

        TimeReceived time ->
            { model | currentTime = Just time } ! []

        DeparturesRequested ->
            ( { model | lineStops = setLoading model |> Success }
            , fetchDepartures model
            )

        DeparturesReceived id direction departures ->
            case model.lineStops of
                RemoteData.Success stops ->
                    ( { model | lineStops = Success (updateLineStop id direction stops departures) }
                    , Cmd.none
                    )

                _ ->
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

        ActivePeriodStartReceived time ->
            { model | activePeriod = Active time }
                ! []

        ActivePeriodDeactivationTriggered ->
            { model | activePeriod = Inactive } ! []

        StopsRequested ->
            { model | lineStops = Loading } ! []

        StopsReceived stops ->
            { model | lineStops = stops }
                ! (stops
                    |> accessLineStop
                    |> List.map (\stop -> getDeparture stop)
                    |> List.append [ Task.perform TimeReceived Time.now ]
                    |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
                  )



-- Update functions


hideForm : Model -> Model
hideForm model =
    { model | showForm = False }


addLineStop : Model -> ( Model, Cmd Msg )
addLineStop model =
    let
        stops =
            accessLineStop model.lineStops

        newModel =
            { model | lineStops = Success ((model.newLineStop :: stops)) }
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


setLoading : Model -> List LineStop
setLoading model =
    model.lineStops
        |> accessLineStop
        |> List.map (\lineStop -> { lineStop | departures = Loading })


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    model.lineStops
        |> accessLineStop
        |> List.map (\stop -> getDeparture stop)
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch


updateLineStop : Int -> Direction -> List LineStop -> WebData Departures -> List LineStop
updateLineStop id direction lineStops departures =
    List.map (updateStop id departures direction) lineStops


updateStop : Int -> WebData Departures -> Direction -> LineStop -> LineStop
updateStop id departures direction lineStop =
    let
        departureDirection =
            directionToComparable direction

        lineStopDirection =
            directionToComparable lineStop.direction

        allDirections =
            directionToComparable Unknown
    in
        if lineStop.id == id && lineStopDirection == departureDirection then
            { lineStop | departures = departures }
        else if lineStop.id == id && lineStopDirection == allDirections then
            { lineStop | departures = departures }
        else
            lineStop


showForm : Model -> Model
showForm model =
    { model | showForm = True }


accessLineStop : RemoteData e (List a) -> List a
accessLineStop lineStops =
    case lineStops of
        RemoteData.Success stops ->
            stops

        _ ->
            []
