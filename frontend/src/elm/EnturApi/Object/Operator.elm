-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module EnturApi.Object.Operator exposing (branding, id, lines, name, phone, selection, serviceJourney, url)

import EnturApi.InputObject
import EnturApi.Interface
import EnturApi.Object
import EnturApi.Scalar
import EnturApi.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) EnturApi.Object.Operator
selection constructor =
    Object.selection constructor


{-| Operator id
-}
id : Field EnturApi.Scalar.Id EnturApi.Object.Operator
id =
    Object.fieldDecoder "id" [] (Object.scalarDecoder |> Decode.map EnturApi.Scalar.Id)


name : Field String EnturApi.Object.Operator
name =
    Object.fieldDecoder "name" [] Decode.string


url : Field (Maybe String) EnturApi.Object.Operator
url =
    Object.fieldDecoder "url" [] (Decode.string |> Decode.nullable)


phone : Field (Maybe String) EnturApi.Object.Operator
phone =
    Object.fieldDecoder "phone" [] (Decode.string |> Decode.nullable)


{-| Branding for operator.
-}
branding : SelectionSet decodesTo EnturApi.Object.Branding -> Field (Maybe decodesTo) EnturApi.Object.Operator
branding object_ =
    Object.selectionField "branding" [] object_ (identity >> Decode.nullable)


lines : SelectionSet decodesTo EnturApi.Object.Line -> Field (List (Maybe decodesTo)) EnturApi.Object.Operator
lines object_ =
    Object.selectionField "lines" [] object_ (identity >> Decode.nullable >> Decode.list)


serviceJourney : SelectionSet decodesTo EnturApi.Object.ServiceJourney -> Field (List (Maybe decodesTo)) EnturApi.Object.Operator
serviceJourney object_ =
    Object.selectionField "serviceJourney" [] object_ (identity >> Decode.nullable >> Decode.list)
