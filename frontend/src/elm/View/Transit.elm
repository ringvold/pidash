module View.Transit exposing (Milliseconds, diff, errToString, getTimeUntilArrival2, viewMessage, viewStopPlaces)

import Date exposing (Date)
import Dict exposing (Dict)
import Entur
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import LineStop exposing (..)
import Maybe.Extra
import Msg exposing (..)
import RemoteData exposing (RemoteData(..))
import Time exposing (Posix)



-- TRANSIT VIEW


viewStopPlaces : List LineStop -> Dict String Departures -> Maybe Posix -> Html Msg
viewStopPlaces lineStops departuresDict currentTime =
    lineStops
        |> List.map (viewDepartures currentTime departuresDict)
        |> div [ class "lineStops row" ]


viewDepartures : Maybe Posix -> Dict String Departures -> LineStop -> Html Msg
viewDepartures currentTime departuresDict lineStop =
    let
        maybeDepartures =
            Dict.get lineStop.quay departuresDict
    in
    case maybeDepartures of
        Just deps ->
            let
                markup : Html msg -> Html msg
                markup content =
                    div [ class "departures col-sm-4" ]
                        [ h2 [] [ text lineStop.name ]
                        , content
                        ]
            in
            case deps of
                Success departures ->
                    let
                        estimatedCallViews =
                            List.map (\departure -> viewEstimatedCall departure currentTime) departures

                        view =
                            if List.isEmpty estimatedCallViews then
                                div [] estimatedCallViews

                            else
                                text "Ingen avganger akkurat nå"
                    in
                    List.map (\departure -> viewEstimatedCall departure currentTime) departures
                        |> div []
                        |> markup

                NotAsked ->
                    markup <| viewMessage "Loading" "glyphicon-refresh spinning"

                Loading ->
                    markup <| viewMessage "Loading" "glyphicon-refresh spinning"

                Failure err ->
                    markup <| text "error"

        --, viewMessage ("Error: " ++ errToString err) "glyphicon-exclamation-sign"
        Nothing ->
            text ""


viewEstimatedCall : Entur.EstimatedCall -> Maybe Posix -> Html msg
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


getDestinationDisplay : Maybe Entur.DestinationDisplay -> String
getDestinationDisplay destinationDisplay_ =
    case destinationDisplay_ of
        Just { frontText } ->
            Maybe.withDefault "" frontText

        Nothing ->
            ""


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
