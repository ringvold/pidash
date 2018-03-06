module View.Transit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (Date, fromTime)
import Date.Extra as Date exposing (Interval(..))
import Time exposing (Time, second)
import RemoteData exposing (RemoteData(..))
import Msg exposing (..)
import Data.VehicleArrivalTime exposing (..)
import Data.LineStop exposing (..)
import Data.Direction exposing (Direction(..), directionToComparable)


-- LINESTOP VIEW


viewStops : List LineStop -> Maybe Time -> Html Msg
viewStops lineStops currentTime =
    List.map (\ls -> viewDepartures ls currentTime) lineStops
        |> div [ class "lineStops row" ]


viewDepartures : LineStop -> Maybe Time -> Html Msg
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
                , viewMessage ("Error: " ++ toString err) "glyphicon-exclamation-sign"
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


viewMessage : String -> String -> Html Msg
viewMessage message icon =
    div [ class "message" ]
        [ div [ class "text-center loading-icon" ] [ span [ class <| "glyphicon " ++ icon ] [] ]
        , p [ class "text-center loading-text" ] [ text message ]
        ]


viewDeparture : VehicleArrivalTime -> Maybe Time -> Html Msg
viewDeparture departure currentTime =
    let
        timeUntilArrival =
            case currentTime of
                Nothing ->
                    text ""

                Just theTime ->
                    departure.expectedArrivalTime
                        |> getTimeUntilArrival (Date.fromTime theTime)
                        |> text
    in
        div
            [ class "departure" ]
            [ h3 []
                [ timeUntilArrival ]
            , div [] [ text <| departureName departure ]
            ]


getTimeUntilArrival : Date -> Date -> String
getTimeUntilArrival currentTime arrivalTime =
    let
        timeUntilArrival =
            toString <| Date.diff Minute currentTime arrivalTime
    in
        if "0" == timeUntilArrival then
            "Nå"
        else
            timeUntilArrival ++ " min"


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