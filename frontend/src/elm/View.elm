module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)
import Date.Extra as DE
import Date
import RemoteData
import Msg exposing (..)
import Model exposing (Model, ActivePeriodStatus(..), init)
import View.LineStop as LineStop


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container-fluid" ]
        [ h1 [ onClick HeaderTriggered ]
            [ text "Avganger "
            , activePeriod model.activePeriod
            , lastUpdated model.activePeriod
            ]
        , viewLineStops model
        ]


viewLineStops : Model -> Html Msg
viewLineStops model =
    case model.lineStops of
        RemoteData.Success stops ->
            lazy2 LineStop.view stops model.currentTime

        RemoteData.NotAsked ->
            div [] [ text "No stops available. Have you remembered to add stops to the configuration file?" ]

        RemoteData.Loading ->
            div [] [ h2 [ class "text-center" ] [ text "LOADING STOPS!1!" ] ]

        RemoteData.Failure err ->
            div [] [ text <| toString err ]


activePeriod : ActivePeriodStatus -> Html Msg
activePeriod activePeriod =
    case activePeriod of
        Active time ->
            span [ class "label label-success" ] [ text "Aktiv" ]

        Inactive ->
            span [ class "label label-default" ] [ text "Inaktiv" ]


lastUpdated : ActivePeriodStatus -> Html Msg
lastUpdated activePeriod =
    case activePeriod of
        Active time ->
            small [ class "last-updated" ] [ Date.fromTime time |> DE.toFormattedString "EEEE, MMMM d, y 'at' H:mm" |> String.append " Sist oppdatert " |> text ]

        Inactive ->
            span [ class "last-updated" ] []
