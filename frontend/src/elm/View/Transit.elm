module View.Transit exposing (Milliseconds, viewStopPlaces, departureName, diff, errToString, getDeparturesByDirection, getTimeUntilArrival, hasDirection, viewDeparture, viewDepartures, viewMessage, viewStops)

import Data.Direction exposing (Direction(..), directionToComparable)
import Data.LineStop exposing (..)
import Data.VehicleArrivalTime exposing (..)
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Msg exposing (..)
import RemoteData exposing (RemoteData(..))
import Time exposing (Posix)
import Model exposing (StopPlaces, EnturResponse)
import Dict


-- LINESTOP VIEW


viewStopPlaces : List ( String, EnturResponse ) -> Maybe Posix -> Html Msg
viewStopPlaces stopPlaces currentTime =
    stopPlaces
        |> List.map (\( _, res ) -> viewDepartures2 res currentTime)
        |> div [ class "lineStops row" ]


viewStops : List LineStop -> Maybe Posix -> Html Msg
viewStops lineStops currentTime =
    List.map (\ls -> viewDepartures ls currentTime) lineStops
        |> div [ class "lineStops row" ]


viewDepartures2 : Model.EnturResponse -> Maybe Posix -> Html Msg
viewDepartures2 response currentTime =
    case response of
        Success res ->
            case res.data of
                Just stopPlace ->
                    --|> getDeparturesByDirection lineStop.direction
                    --|> List.map (\departure -> viewDeparture departure currentTime)
                    --|> List.append [ h2 [] [ text stopPlace.name ] ]
                    div [ class "departures col-sm-4" ] [ h2 [] [ text stopPlace.name ] ]

                Nothing ->
                    --div [ class "departures col-sm-4" ]
                    --    [ h2 [] [ text stopPlace.name ]
                    --    , text "Ingen avganger akkurat nå"
                    --    ]
                    text ""

        NotAsked ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text "lineStop.name" ]
                , viewMessage "Loading" "glyphicon-refresh spinning"
                ]

        Loading ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text "lineStop.name" ]
                , viewMessage "Loading" "glyphicon-refresh spinning"
                ]

        Failure err ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text "lineStop.name" ]
                , text "error"

                --, viewMessage ("Error: " ++ errToString err) "glyphicon-exclamation-sign"
                ]


viewDepartures : LineStop -> Maybe Posix -> Html Msg
viewDepartures lineStop currentTime =
    case lineStop.departures of
        NotAsked ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text lineStop.name ]
                , viewMessage "Loading" "glyphicon-refresh spinning"
                ]

        Loading ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text lineStop.name ]
                , viewMessage "Loading" "glyphicon-refresh spinning"
                ]

        Failure err ->
            div [ class "departures col-sm-4" ]
                [ h2 [] [ text lineStop.name ]
                , viewMessage ("Error: " ++ errToString err) "glyphicon-exclamation-sign"
                ]

        Success departures ->
            if List.isEmpty departures then
                div [ class "departures col-sm-4" ]
                    [ h2 [] [ text lineStop.name ]
                    , text "Ingen avganger akkurat nå"
                    ]
            else
                departures
                    |> getDeparturesByDirection lineStop.direction
                    |> List.map (\departure -> viewDeparture departure currentTime)
                    |> List.append [ h2 [] [ text lineStop.name ] ]
                    |> div [ class "departures col-sm-4" ]


errToString : Http.Error -> String
errToString error =
    case error of
        Http.BadUrl err ->
            "BadUrl " ++ err

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus res ->
            "BadStatus " ++ String.fromInt res.status.code ++ ": " ++ res.status.message

        Http.BadPayload string res ->
            "BadPayload " ++ string ++ ": " ++ res.body


viewMessage : String -> String -> Html Msg
viewMessage message icon =
    div [ class "message" ]
        [ div [ class "text-center loading-icon" ] [ span [ class <| "glyphicon " ++ icon ] [] ]
        , p [ class "text-center loading-text" ] [ text message ]
        ]


viewDeparture : VehicleArrivalTime -> Maybe Posix -> Html Msg
viewDeparture departure currentTime =
    let
        timeUntilArrival =
            case currentTime of
                Nothing ->
                    text ""

                Just theTime ->
                    departure.expectedArrivalTime
                        |> getTimeUntilArrival theTime
                        |> text
    in
        div
            [ class "departure" ]
            [ h3 []
                [ timeUntilArrival ]
            , div [] [ text <| departureName departure ]
            ]


getTimeUntilArrival : Posix -> Posix -> String
getTimeUntilArrival currentTime arrivalTime =
    let
        timeUntilArrival =
            diff currentTime arrivalTime
    in
        if 0 == timeUntilArrival then
            "Nå"
        else
            String.fromInt timeUntilArrival ++ " min"


type alias Milliseconds =
    Int


diff : Posix -> Posix -> Milliseconds
diff time1 time2 =
    Time.posixToMillis time2 // 60 // 1000 - Time.posixToMillis time1 // 60 // 1000


departureName : VehicleArrivalTime -> String
departureName departure =
    departure.publishedLineName ++ " " ++ departure.destinationName


getDeparturesByDirection : Direction -> Departures -> Departures
getDeparturesByDirection direction departures =
    departures
        |> List.filter (hasDirection direction)
        |> List.take 3


hasDirection : Direction -> VehicleArrivalTime -> Bool
hasDirection direction departure =
    let
        departureDirection =
            directionToComparable departure.direction

        lineStopDirection =
            directionToComparable direction

        unknownDirections =
            directionToComparable Unknown
    in
        departureDirection == unknownDirections || departureDirection == lineStopDirection
