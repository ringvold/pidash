module Data.StopPlace exposing (Response, StopPlace, query)

import Entur.Object as EO
import Entur.Object.StopPlace as EOS
import Entur.Query
import Entur.Scalar exposing (Id(..))
import Graphql.Field as Field exposing (Field)
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet, with)


type alias Response =
    { data : Maybe StopPlace }


type alias StopPlace =
    { id : String
    , name : String
    }


query : String -> SelectionSet Response RootQuery
query id =
    Entur.Query.selection Response
        |> with
            (Entur.Query.stopPlace { id = id }
                stopPlaceSelection
            )


stopPlaceSelection : SelectionSet StopPlace EO.StopPlace
stopPlaceSelection =
    EOS.selection StopPlace
        |> with (EOS.id |> Field.map scalarIdToString)
        |> with EOS.name


scalarIdToString : Entur.Scalar.Id -> String
scalarIdToString scalarId =
    case scalarId of
        Id id ->
            id
