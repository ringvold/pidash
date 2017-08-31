module Update exposing (update)

import Task exposing (perform)
import Time exposing (Time, second)
import RemoteData exposing (WebData, RemoteData(..), succeed)
import Model exposing (..)
import Msg exposing (Msg(..))
import Api exposing (getDeparture)
import Data.VehicleArrivalTime exposing (..)
import Data.Stop exposing (..)


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
            { model | lineStops = setLoading model |> Success }
                ! [ fetchDepartures model ]

        DeparturesReceived id direction departures ->
            updateLineStops model id direction departures ! []

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
                    |> unwrapLineStop
                    |> List.map (\stop -> getDeparture stop)
                    |> List.append [ Task.perform TimeReceived Time.now ]
                    |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
                  )



-- Update functions


setLoading : Model -> List LineStop
setLoading model =
    model.lineStops
        |> unwrapLineStop
        |> List.map (\lineStop -> { lineStop | departures = Loading })


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    model.lineStops
        |> unwrapLineStop
        |> List.map (\stop -> getDeparture stop)
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch


updateLineStops : Model -> Int -> Direction -> WebData Departures -> Model
updateLineStops model id direction departures =
    case model.lineStops of
        RemoteData.Success stops ->
            { model | lineStops = updateLineStop id direction stops departures |> Success }

        _ ->
            model


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


unwrapLineStop : RemoteData e (List a) -> List a
unwrapLineStop lineStops =
    case lineStops of
        RemoteData.Success stops ->
            stops

        _ ->
            []
