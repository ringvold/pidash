module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)
import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)
import Json.Decode
import Date exposing (..)
import Time exposing (Time)
import Date.Extra as Date exposing (Interval(..))
import Task exposing (perform)
import Time exposing (Time, second)
import Dict exposing (Dict)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (60 * Time.second) (\_ -> DeparturesRequested) ]



-- MODEL


type alias Model =
    { lineStops : Dict Int LineStop
    , currentTime : Maybe Time.Time
    , url : String
    }


type alias LineStop =
    { name : String
    , id : Int
    , departures : List VehicleArrivalTime
    , direction : Int
    }



-- 3012122, 3010443


init : ( Model, Cmd Msg )
init =
    let
        lineStops =
            Dict.fromList
                [ ( 3012122, LineStop "Storo sør" 3012122 [] 0 )
                , ( 3010443, LineStop "Grefsenveien nord" 3010443 [] 0 )
                ]

        url =
            "http://localhost:8081/"

        model =
            Model lineStops Nothing url
    in
        ( model
        , fetchDepartures model
        )



-- UPDATE


type Msg
    = NoOp
    | TimeRequested
    | TimeReceived Time
    | DeparturesRequested
    | DeparturesReceived (Result Http.Error Response)
    | NewLineStopClicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        TimeRequested ->
            model
                ! [ Task.perform TimeReceived Time.now ]

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
            ( model, Cmd.none )

        NewLineStopClicked ->
            model ! []


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    Cmd.batch <|
        List.append
            [ Task.perform TimeReceived Time.now ]
        <|
            List.map (\stop -> getDeparture stop model.url) (Dict.values model.lineStops)


updateLineStop : Dict Int LineStop -> List VehicleArrivalTime -> Dict Int LineStop
updateLineStop lineStops departures =
    let
        departure : Maybe VehicleArrivalTime
        departure =
            (List.head departures)

        lineId : Int
        lineId =
            case departure of
                Just departure ->
                    departure.lineId

                Nothing ->
                    -1

        lineStop =
            Dict.get lineId lineStops
    in
        case Dict.get lineId lineStops of
            Just m ->
                Dict.insert lineId ({ m | departures = departures }) lineStops

            Nothing ->
                lineStops



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container-fluid" ]
        [ h1 [ onClick DeparturesRequested ] [ text "Avganger" ]
        , button [ class "btn btn-primary" ] [ text "Legg til stopp" ]
        , lazy2 viewLineStop (Dict.values model.lineStops) model.currentTime
        ]


viewLineStop : List LineStop -> Maybe Time -> Html Msg
viewLineStop lineStops currentTime =
    let
        timeList =
            List.repeat (List.length lineStops) currentTime
    in
        div
            [ class "lineStops row" ]
        <|
            List.map2 viewDepartures lineStops timeList


viewDepartures : LineStop -> Maybe Time -> Html Msg
viewDepartures lineStop currentTime =
    div [ class "departures col-sm-6" ] <|
        List.append
            [ h2 [] [ text lineStop.name ]
            ]
        <|
            List.map (\departure -> viewDeparture departure currentTime) lineStop.departures


viewDeparture : VehicleArrivalTime -> Maybe Time -> Html Msg
viewDeparture departure currentTime =
    let
        timeUntilArrival =
            case currentTime of
                Nothing ->
                    text ""

                Just theTime ->
                    text <|
                        getTimeUntilArrival (Date.fromTime theTime) departure.expectedArrivalTime
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



-- HTTP


getDeparture : LineStop -> String -> Cmd Msg
getDeparture stop baseUrl =
    let
        url =
            baseUrl ++ toString stop.id
    in
        Http.send
            DeparturesReceived
            (Http.get url decodeResponse)


decodeResponse : Json.Decoder (List VehicleArrivalTime)
decodeResponse =
    Json.list vehicleArrivalTime


vehicleArrivalTime : Json.Decoder VehicleArrivalTime
vehicleArrivalTime =
    succeed VehicleArrivalTime
        |: (field "destinationName" string)
        |: (field "publishedLineName" string)
        |: (field "vehicleMode" int)
        |: (field "directionRef" string)
        |: (field "expectedArrivalTime" date)
        |: (field "lineId" int)


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , directionRef : String
    , expectedArrivalTime : Date
    , lineId : Int
    }


type alias Response =
    List VehicleArrivalTime
