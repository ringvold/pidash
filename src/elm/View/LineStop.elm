module View.LineStop exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (..)
import Date.Extra as Date exposing (Interval(..))
import Time exposing (Time, second)
import Types exposing (..)
import Msg exposing (..)


-- LINESTOP VIEW


view : List LineStop -> Maybe Time -> Html Msg
view lineStops currentTime =
    let
        timeList =
            List.repeat (List.length lineStops) currentTime
    in
        List.map2 viewDepartures lineStops timeList
            |> div [ class "lineStops row" ]


viewDepartures : LineStop -> Maybe Time -> Html Msg
viewDepartures lineStop currentTime =
    List.map (\departure -> viewDeparture departure currentTime) lineStop.departures
        |> List.append [ h2 [] [ text lineStop.name ] ]
        |> div [ class "departures col-sm-6" ]


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
                [ text <| departureName departure ]
            , div [] [ timeUntilArrival ]
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
