module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy2)
import Http
import Json.Decode as Json
import Json.Decode.Extra exposing ((|:), date)
import Json.Decode exposing (Decoder, decodeValue, succeed, string, int, field)
import Date exposing (..)
import Time exposing (Time)
import Date.Extra as Date exposing (Interval(..))
import Task exposing (perform)
import List.Extra exposing (elemIndex, setAt, find)
import Time exposing (Time, second)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscription
        }


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (10 * Time.second) (\_ -> DeparturesRequested) ]



-- MODEL


type alias Model =
    { lineStops : List LineStop
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
            [ LineStop "Storo sør" 3012122 [] 0
            , LineStop "Grefsenveien nord" 3010443 [] 0
            ]

        url =
            "http://localhost:8080/"

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


fetchDepartures : Model -> Cmd Msg
fetchDepartures model =
    Cmd.batch <|
        List.append
            [ Task.perform TimeReceived Time.now ]
        <|
            List.map (\stop -> getDeparture stop model.url) model.lineStops


updateLineStop : List LineStop -> List VehicleArrivalTime -> List LineStop
updateLineStop lineStops departures =
    let
        aStop : Maybe VehicleArrivalTime
        aStop =
            (List.head departures)

        lineId : Int
        lineId =
            case aStop of
                Just theStop ->
                    theStop.lineId

                Nothing ->
                    -1

        lineStop : LineStop
        lineStop =
            case getLineStopById lineStops lineId of
                Nothing ->
                    LineStop "" 0 [] 0

                Just ls ->
                    ls

        elementIndex : Int
        elementIndex =
            case List.Extra.elemIndex lineStop lineStops of
                Nothing ->
                    -1

                Just idx ->
                    idx

        updated =
            { lineStop | departures = departures }

        newLineStops =
            List.Extra.setAt elementIndex updated lineStops
    in
        case newLineStops of
            Nothing ->
                lineStops

            Just upatedLineStop ->
                upatedLineStop


getLineStopById : List LineStop -> Int -> Maybe LineStop
getLineStopById lineStops lineId =
    List.Extra.find (\ls -> ls.id == lineId) lineStops



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [ onClick DeparturesRequested ] [ text "Avganger" ]
        , lazy2 viewLineStop model.lineStops model.currentTime
        ]


viewLineStop : List LineStop -> Maybe Time -> Html Msg
viewLineStop lineStops currentTime =
    let
        timeList =
            List.repeat (List.length lineStops) currentTime
    in
        div
            [ class "lineStops" ]
        <|
            List.map2 viewDepartures lineStops timeList


viewDepartures : LineStop -> Maybe Time -> Html Msg
viewDepartures lineStop currentTime =
    div [ class "departures" ] <|
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
