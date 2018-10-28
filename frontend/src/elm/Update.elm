module Update exposing (update)

import Api exposing (getDeparture, getForecast)
import Data.Direction exposing (Direction(..), directionToComparable)
import Data.LineStop exposing (Departures, LineStop)
import Model exposing (..)
import Msg exposing (Msg(..))
import RemoteData exposing (RemoteData(..), WebData, succeed)
import Task exposing (perform)
import Time



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RefreshTriggered ->
            let
                newModel =
                    setForecastLoading model
            in
            ( { newModel | lineStops = setLoading model |> Success }
            , Cmd.batch [ Task.perform ActivePeriodStartReceived Time.now, fetchDepartures model, getForecast ]
            )

        TimeRequested ->
            ( model, Cmd.batch [ Task.perform TimeReceived Time.now ] )

        TimeReceived time ->
            ( { model | currentTime = Just time }, Cmd.none )

        DeparturesRequested ->
            ( { model | lineStops = setLoading model |> Success }
            , Cmd.batch [ fetchDepartures model ]
            )

        DeparturesReceived id direction departures ->
            ( updateLineStops model id direction departures, Cmd.none )

        ActivePeriodStartReceived time ->
            ( { model | activePeriod = Active time }, Cmd.none )

        ActivePeriodDeactivationTriggered ->
            ( { model | activePeriod = Inactive }, Cmd.none )

        StopsRequested ->
            ( { model | lineStops = Loading }, Cmd.none )

        StopsReceived stops ->
            ( { model | lineStops = stops }
            , Cmd.batch
                (stops
                    |> unwrapLineStop
                    |> List.map getDeparture
                    |> List.append [ Task.perform TimeReceived Time.now ]
                    |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
                )
            )

        ForecastRequested ->
            ( setForecastLoading model, Cmd.batch [ getForecast ] )

        ForecastReceived forecasts ->
            ( { model | forecasts = forecasts }, Cmd.none )



-- Update functions


setForecastLoading : Model -> Model
setForecastLoading model =
    { model | forecasts = Loading }


updateLineStops : Model -> String -> Direction -> WebData Departures -> Model
updateLineStops model id direction departures =
    case model.lineStops of
        RemoteData.Success stops ->
            { model | lineStops = updateLineStop id direction stops departures |> Success }

        _ ->
            model


updateLineStop : String -> Direction -> List LineStop -> WebData Departures -> List LineStop
updateLineStop id direction lineStops departures =
    List.map (updateStop id departures direction) lineStops


updateStop : String -> WebData Departures -> Direction -> LineStop -> LineStop
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


setLoading : Model -> List LineStop
setLoading model =
    model.lineStops
        |> unwrapLineStop
        |> List.map (\lineStop -> { lineStop | departures = Loading })


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    model.lineStops
        |> unwrapLineStop
        |> List.map getDeparture
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch


unwrapLineStop : RemoteData e (List a) -> List a
unwrapLineStop lineStops =
    case lineStops of
        RemoteData.Success stops ->
            stops

        _ ->
            []
