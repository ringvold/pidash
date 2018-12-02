module Entur exposing (DestinationDisplay, EstimatedCall, Response, StopPlace, estimatedCallByQuay, query)

import EnturApi.Object as EO
import EnturApi.Object.DestinationDisplay as EOD
import EnturApi.Object.EstimatedCall as EOE
import EnturApi.Object.Quay as EOQ
import EnturApi.Object.StopPlace as EOS
import EnturApi.Query
import EnturApi.Scalar exposing (DateTime(..), Id(..))
import Graphql.Field as Field exposing (Field)
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet, fieldSelection, with)
import Iso8601
import Time exposing (Posix)


type alias Response =
    Maybe StopPlace


type alias StopPlace =
    { id : String
    , name : String
    , estimatedCalls : List EstimatedCall
    }


type alias EstimatedCall =
    { expectedArrivalTime : Maybe Posix
    , destinationDisplay : Maybe DestinationDisplay
    , realtime : Maybe Bool
    , quay : Maybe String
    }


type alias DestinationDisplay =
    { frontText : Maybe String }


query : String -> SelectionSet Response RootQuery
query id =
    EnturApi.Query.selection identity
        |> with
            (EnturApi.Query.stopPlace { id = id }
                stopPlaceSelection
            )


stopPlaceSelection : SelectionSet StopPlace EO.StopPlace
stopPlaceSelection =
    EOS.selection StopPlace
        |> with (EOS.id |> Field.map scalarIdToString)
        |> with EOS.name
        |> with (estimatedCalls |> Field.map (List.filterMap identity))



-- EstimatedCall


estimatedCalls : Field (List (Maybe EstimatedCall)) EO.StopPlace
estimatedCalls =
    EOS.estimatedCalls
        (\optionals ->
            { optionals
                | numberOfDeparturesPerLineAndDestinationDisplay = Present 2
                , numberOfDepartures = Present 10
                , timeRange = Present 7200
            }
        )
        estimatedCallSelection


estimatedCallSelection : SelectionSet EstimatedCall EO.EstimatedCall
estimatedCallSelection =
    EOE.selection EstimatedCall
        |> with (EOE.expectedArrivalTime |> Field.map mapDateTime)
        |> with (EOE.destinationDisplay destinationDisplaySelection)
        |> with EOE.realtime
        |> with (EOE.quay quaySelection)


estimatedCallByQuay : String -> EstimatedCall -> Bool
estimatedCallByQuay quay estimatedCall =
    case estimatedCall.quay of
        Just q ->
            q == quay

        Nothing ->
            False



-- Quay


quaySelection : SelectionSet String EO.Quay
quaySelection =
    EOQ.selection identity
        |> with (EOQ.id |> Field.map scalarIdToString)



-- DestinationDisplay


destinationDisplaySelection =
    EOD.selection DestinationDisplay
        |> with EOD.frontText



-- Helpers


scalarIdToString : EnturApi.Scalar.Id -> String
scalarIdToString scalarId =
    case scalarId of
        Id id ->
            id


mapDateTime : Maybe EnturApi.Scalar.DateTime -> Maybe Posix
mapDateTime datetime =
    datetime
        |> Maybe.map
            (\(DateTime value) ->
                Iso8601.toTime value
                    |> Result.toMaybe
            )
        |> Maybe.withDefault Nothing
