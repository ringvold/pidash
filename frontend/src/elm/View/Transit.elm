module View.Transit exposing (Milliseconds, departureName, diff, errToString, getDeparturesByDirection, getTimeUntilArrival2, hasDirection, viewDeparture, viewDepartures, viewMessage, viewStopPlaces, viewStops)

import Data.Direction exposing (Direction(..), directionToComparable)
import Data.Entur
import Data.LineStop exposing (..)
import Data.VehicleArrivalTime exposing (..)
import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Maybe.Extra
import Model exposing (GraphqlData, StopPlaces)
import Msg exposing (..)
import RemoteData exposing (RemoteData(..))
import Time exposing (Posix)



-- TRANSIT VIEW


viewStopPlaces : List ( String, GraphqlData ) -> Maybe Posix -> Html Msg
viewStopPlaces stopPlaces currentTime =
    stopPlaces
        |> List.map (\( _, res ) -> viewEnturDepartures res currentTime)
        |> div [ class "lineStops row" ]


viewEnturDepartures : Model.GraphqlData -> Maybe Posix -> Html Msg
viewEnturDepartures response currentTime =
    case response of
        Success (Data.Entur.Response stop) ->
            case stop of
                Just stopPlace ->
                    let
                        departures =
                            stopPlace.estimatedCalls
                                |> List.filterMap identity
                                |> List.map (\departure -> viewEstimatedCall departure currentTime)
                    in
                    departures
                        |> (::) (h2 [] [ text stopPlace.name ])
                        |> div [ class "departures col-sm-4" ]

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


viewEstimatedCall : Data.Entur.EstimatedCall -> Maybe Posix -> Html msg
viewEstimatedCall estimatedCall currentTime =
    let
        timeUntilArrival =
            case currentTime of
                Nothing ->
                    text ""

                Just theTime ->
                    estimatedCall.expectedArrivalTime
                        |> getTimeUntilArrival2 theTime
                        |> text
    in
    div
        [ class "departure" ]
        [ h3 []
            [ timeUntilArrival ]
        , div []
            [ text <|
                getDestinationDisplay estimatedCall.destinationDisplay
            ]
        ]


getTimeUntilArrival2 : Posix -> Maybe Posix -> String
getTimeUntilArrival2 currentTime arrivalTime =
    case arrivalTime of
        Just time ->
            let
                timeUntilArrival =
                    diff currentTime time
            in
            if 0 == timeUntilArrival then
                "Nå"

            else
                String.fromInt timeUntilArrival ++ " min"

        Nothing ->
            "Avgangstid ikke tilgjengelig"


getDestinationDisplay : Maybe Data.Entur.DestinationDisplay -> String
getDestinationDisplay destinationDisplay_ =
    case destinationDisplay_ of
        Just { frontText } ->
            Maybe.withDefault "" frontText

        Nothing ->
            ""


viewStops : List LineStop -> Maybe Posix -> Html Msg
viewStops lineStops currentTime =
    List.map (\ls -> viewDepartures ls currentTime) lineStops
        |> div [ class "lineStops row" ]


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
