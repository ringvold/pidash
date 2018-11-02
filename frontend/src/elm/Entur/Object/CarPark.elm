-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Entur.Object.CarPark exposing (capacity, id, latitude, longitude, name, realtimeOccupancyAvailable, selection, spacesAvailable)

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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Entur.Object.CarPark
selection constructor =
    Object.selection constructor


id : Field Entur.Scalar.Id Entur.Object.CarPark
id =
    Object.fieldDecoder "id" [] (Object.scalarDecoder |> Decode.map Entur.Scalar.Id)


name : Field String Entur.Object.CarPark
name =
    Object.fieldDecoder "name" [] Decode.string


capacity : Field (Maybe Int) Entur.Object.CarPark
capacity =
    Object.fieldDecoder "capacity" [] (Decode.int |> Decode.nullable)


spacesAvailable : Field (Maybe Int) Entur.Object.CarPark
spacesAvailable =
    Object.fieldDecoder "spacesAvailable" [] (Decode.int |> Decode.nullable)


realtimeOccupancyAvailable : Field (Maybe Bool) Entur.Object.CarPark
realtimeOccupancyAvailable =
    Object.fieldDecoder "realtimeOccupancyAvailable" [] (Decode.bool |> Decode.nullable)


longitude : Field (Maybe Float) Entur.Object.CarPark
longitude =
    Object.fieldDecoder "longitude" [] (Decode.float |> Decode.nullable)


latitude : Field (Maybe Float) Entur.Object.CarPark
latitude =
    Object.fieldDecoder "latitude" [] (Decode.float |> Decode.nullable)