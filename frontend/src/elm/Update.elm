module Update exposing (update)

import Api exposing (getForecast, getStopPlace)
import Data.Entur exposing (EstimatedCall, Response, StopPlace)
import Data.LineStop exposing (Departures, LineStop)
import Dict exposing (Dict)
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
            ( { newModel | departures = setLoadingDepartures model }
            , Cmd.batch [ Task.perform ActivePeriodStartReceived Time.now, fetchDepartures model, getForecast ]
            )

        TimeRequested ->
            ( model, Cmd.batch [ Task.perform TimeReceived Time.now ] )

        TimeReceived time ->
            ( { model | currentTime = Just time }, Cmd.none )

        DeparturesRequested ->
            ( { model | departures = setLoadingDepartures model }
            , Cmd.batch [ fetchDepartures model ]
            )

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
                    |> RemoteData.withDefault []
                    |> List.map getStopPlace
                    |> List.append [ Task.perform TimeReceived Time.now ]
                    |> List.append [ Task.perform ActivePeriodStartReceived Time.now ]
                )
            )

        StopPlaceReceived stopId quay response ->
            let
                departures =
                    response
                        |> RemoteData.withDefault Nothing
                        |> Maybe.map .estimatedCalls
                        |> Maybe.withDefault []
            in
            ( { model | departures = updateDepartures quay model departures }, Cmd.none )

        ForecastRequested ->
            ( setForecastLoading model, Cmd.batch [ getForecast ] )

        ForecastReceived forecasts ->
            ( { model | forecasts = forecasts }, Cmd.none )



-- Update functions


updateDepartures : String -> Model -> List EstimatedCall -> Dict String Departures
updateDepartures quay model departures =
    let
        departuresForQuay =
            departures
                |> List.filter (Data.Entur.estimatedCallByQuay quay)
                |> Success
    in
    Dict.insert quay departuresForQuay model.departures


isJust : Maybe a -> Bool
isJust a =
    case a of
        Just _ ->
            True

        Nothing ->
            False


setForecastLoading : Model -> Model
setForecastLoading model =
    { model | forecasts = Loading }


setLoadingDepartures : Model -> Dict String Departures
setLoadingDepartures model =
    Dict.keys model.departures
        |> List.foldl (\key acc -> Dict.insert key Loading acc) model.departures


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    model.lineStops
        |> RemoteData.withDefault []
        |> List.map getStopPlace
        |> List.append [ Task.perform TimeReceived Time.now ]
        |> Cmd.batch
