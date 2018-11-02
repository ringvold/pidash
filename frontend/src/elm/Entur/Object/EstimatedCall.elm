-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Entur.Object.EstimatedCall exposing (actualArrivalTime, actualDepartureTime, aimedArrival, aimedArrivalTime, aimedDeparture, aimedDepartureTime, bookingArrangements, cancellation, date, destinationDisplay, expectedArrival, expectedArrivalTime, expectedDeparture, expectedDepartureTime, forAlighting, forBoarding, notices, quay, realtime, realtimeState, requestStop, selection, serviceJourney, situations, timingPoint)

import Entur.Enum.RealtimeState
import Entur.InputObject
import Entur.Interface
import Entur.Object
import Entur.Scalar
import Entur.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Entur.Object.EstimatedCall
selection constructor =
    Object.selection constructor


quay : SelectionSet decodesTo Entur.Object.Quay -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
quay object_ =
    Object.selectionField "quay" [] object_ (identity >> Decode.nullable)


{-| Scheduled time of arrival at quay. Not affected by read time updated
-}
aimedArrivalTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
aimedArrivalTime =
    Object.fieldDecoder "aimedArrivalTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Expected time of arrival at quay. Updated with real time information if available. Will be null if an actualArrivalTime exists
-}
expectedArrivalTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
expectedArrivalTime =
    Object.fieldDecoder "expectedArrivalTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Actual time of arrival at quay. Updated from real time information if available
-}
actualArrivalTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
actualArrivalTime =
    Object.fieldDecoder "actualArrivalTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Scheduled time of departure from quay. Not affected by read time updated
-}
aimedDepartureTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
aimedDepartureTime =
    Object.fieldDecoder "aimedDepartureTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Expected time of departure from quay. Updated with real time information if available. Will be null if an actualDepartureTime exists
-}
expectedDepartureTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
expectedDepartureTime =
    Object.fieldDecoder "expectedDepartureTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Actual time of departure from quay. Updated with real time information if available
-}
actualDepartureTime : Field (Maybe Entur.Scalar.DateTime) Entur.Object.EstimatedCall
actualDepartureTime =
    Object.fieldDecoder "actualDepartureTime" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.DateTime |> Decode.nullable)


{-| Scheduled time of arrival at quay. Not affected by read time updated
-}
aimedArrival : SelectionSet decodesTo Entur.Object.TimeAndDayOffset -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
aimedArrival object_ =
    Object.selectionField "aimedArrival" [] object_ (identity >> Decode.nullable)


{-| Expected time of arrival at quay. Updated with real time information if available
-}
expectedArrival : SelectionSet decodesTo Entur.Object.TimeAndDayOffset -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
expectedArrival object_ =
    Object.selectionField "expectedArrival" [] object_ (identity >> Decode.nullable)


{-| Scheduled time of departure from quay. Not affected by read time updated
-}
aimedDeparture : SelectionSet decodesTo Entur.Object.TimeAndDayOffset -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
aimedDeparture object_ =
    Object.selectionField "aimedDeparture" [] object_ (identity >> Decode.nullable)


{-| Expected time of departure from quay. Updated with real time information if available
-}
expectedDeparture : SelectionSet decodesTo Entur.Object.TimeAndDayOffset -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
expectedDeparture object_ =
    Object.selectionField "expectedDeparture" [] object_ (identity >> Decode.nullable)


{-| Whether this is a timing point or not. Boarding and alighting is not allowed at timing points.
-}
timingPoint : Field (Maybe Bool) Entur.Object.EstimatedCall
timingPoint =
    Object.fieldDecoder "timingPoint" [] (Decode.bool |> Decode.nullable)


{-| Whether this call has been updated with real time information.
-}
realtime : Field (Maybe Bool) Entur.Object.EstimatedCall
realtime =
    Object.fieldDecoder "realtime" [] (Decode.bool |> Decode.nullable)


realtimeState : Field (Maybe Entur.Enum.RealtimeState.RealtimeState) Entur.Object.EstimatedCall
realtimeState =
    Object.fieldDecoder "realtimeState" [] (Entur.Enum.RealtimeState.decoder |> Decode.nullable)


{-| Whether vehicle may be borded at quay.
-}
forBoarding : Field (Maybe Bool) Entur.Object.EstimatedCall
forBoarding =
    Object.fieldDecoder "forBoarding" [] (Decode.bool |> Decode.nullable)


{-| Whether vehicle may be alighted at quay.
-}
forAlighting : Field (Maybe Bool) Entur.Object.EstimatedCall
forAlighting =
    Object.fieldDecoder "forAlighting" [] (Decode.bool |> Decode.nullable)


{-| Whether vehicle will only stop on request.
-}
requestStop : Field (Maybe Bool) Entur.Object.EstimatedCall
requestStop =
    Object.fieldDecoder "requestStop" [] (Decode.bool |> Decode.nullable)


{-| Whether stop is cancellation.
-}
cancellation : Field (Maybe Bool) Entur.Object.EstimatedCall
cancellation =
    Object.fieldDecoder "cancellation" [] (Decode.bool |> Decode.nullable)


{-| The date the estimated call is valid for.
-}
date : Field (Maybe Entur.Scalar.Date) Entur.Object.EstimatedCall
date =
    Object.fieldDecoder "date" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.Date |> Decode.nullable)


serviceJourney : SelectionSet decodesTo Entur.Object.ServiceJourney -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
serviceJourney object_ =
    Object.selectionField "serviceJourney" [] object_ (identity >> Decode.nullable)


destinationDisplay : SelectionSet decodesTo Entur.Object.DestinationDisplay -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
destinationDisplay object_ =
    Object.selectionField "destinationDisplay" [] object_ (identity >> Decode.nullable)


notices : SelectionSet decodesTo Entur.Object.Notice -> Field (List (Maybe decodesTo)) Entur.Object.EstimatedCall
notices object_ =
    Object.selectionField "notices" [] object_ (identity >> Decode.nullable >> Decode.list)


{-| Get all relevant situations for this EstimatedCall.
-}
situations : SelectionSet decodesTo Entur.Object.PtSituationElement -> Field (List (Maybe decodesTo)) Entur.Object.EstimatedCall
situations object_ =
    Object.selectionField "situations" [] object_ (identity >> Decode.nullable >> Decode.list)


{-| Booking arrangements for flexible service.
-}
bookingArrangements : SelectionSet decodesTo Entur.Object.BookingArrangement -> Field (Maybe decodesTo) Entur.Object.EstimatedCall
bookingArrangements object_ =
    Object.selectionField "bookingArrangements" [] object_ (identity >> Decode.nullable)