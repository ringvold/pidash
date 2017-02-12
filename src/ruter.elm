-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

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



main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }



-- MODEL


type alias Model =
  { lineIds  : List Int
  , departures : List MonitoredVehicleJourney
  , currentTime : Maybe Time.Time
  }

-- 3012122
init : (Model, Cmd Msg)
init =
  ( Model [3010443] [] Nothing
  , Cmd.none
  )



-- UPDATE


type Msg
  = NoOp
  | GetTime
  | NewTime Time
  | TriggerFetch
  | FetchDepartures (Result Http.Error Response)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    GetTime ->
      model ! [ Task.perform NewTime Time.now ]

    NewTime time ->
      { model | currentTime = Just time } ! []

    TriggerFetch ->
      ( model
      , Cmd.batch <| List.append [Task.perform NewTime Time.now] <| List.map getDeparture model.lineIds
      )

    FetchDepartures (Ok departures) ->
      Debug.log "Ok"
      ({ model | departures = departures }, Cmd.none)

    FetchDepartures (Err _) ->
      Debug.log "Error"
      (model, Cmd.none)



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [ onClick TriggerFetch ] [ text "Overskrift"]
    , lazy2 viewDepartures model.departures model.currentTime
    ]


viewDepartures : List MonitoredVehicleJourney -> Maybe Time -> Html Msg
viewDepartures departures currentTime =
  let
    timeList =
      List.repeat (List.length departures) currentTime
  in
    div [ class "departures"] <|
       List.map2 viewDeparture departures timeList


viewDeparture : MonitoredVehicleJourney -> Maybe Time -> Html Msg
viewDeparture departure currentTime =
  let
    timeUntilArrival =
      case currentTime of
        Nothing ->
          text ""

        Just theTime ->
          text
            <| getTimeUntilArrival (Date.fromTime theTime) departure.expectedArrivalTime ++ " min"
  in
    Debug.log (toString currentTime)
    div [ class "departure"]
      [ h2 []
        [ text <|
            departure.publishedLineName ++ departure.destinationName
        ]
      , div [][ timeUntilArrival ]
      ]


getTimeUntilArrival : Date -> Date -> String
getTimeUntilArrival currentTime arrivalTime =
  toString <|
    Date.diff Minute currentTime arrivalTime


-- HTTP


getDeparture : Int -> Cmd Msg
getDeparture id =
  let
    url =
      "http://localhost:8080/" ++ toString id
  in
    Http.send FetchDepartures (Http.get url decodeResponse)


decodeResponse : Json.Decoder (List MonitoredVehicleJourney)
decodeResponse =
  Json.list monitoredVehicleJourney


monitoredVehicleJourney : Json.Decoder MonitoredVehicleJourney
monitoredVehicleJourney =
  succeed MonitoredVehicleJourney
    |: (field "destinationName" string)
    |: (field "publishedLineName" string)
    |: (field "vehicleMode" int)
    |: (field "directionRef" string)
    |: (field "expectedArrivalTime" date)


type alias MonitoredVehicleJourney =
  { destinationName : String
  , publishedLineName : String
  , vehicleMode : Int
  , directionRef : String
  , expectedArrivalTime : Date
  }


type alias Response = List MonitoredVehicleJourney

