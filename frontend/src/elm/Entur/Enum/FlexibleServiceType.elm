-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Entur.Enum.FlexibleServiceType exposing (FlexibleServiceType(..), decoder, toString)

import Json.Decode as Decode exposing (Decoder)


type FlexibleServiceType
    = DynamicPassingTimes
    | FixedHeadwayFrequency
    | FixedPassingTimes
    | NotFlexible
    | Other


decoder : Decoder FlexibleServiceType
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "dynamicPassingTimes" ->
                        Decode.succeed DynamicPassingTimes

                    "fixedHeadwayFrequency" ->
                        Decode.succeed FixedHeadwayFrequency

                    "fixedPassingTimes" ->
                        Decode.succeed FixedPassingTimes

                    "notFlexible" ->
                        Decode.succeed NotFlexible

                    "other" ->
                        Decode.succeed Other

                    _ ->
                        Decode.fail ("Invalid FlexibleServiceType type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : FlexibleServiceType -> String
toString enum =
    case enum of
        DynamicPassingTimes ->
            "dynamicPassingTimes"

        FixedHeadwayFrequency ->
            "fixedHeadwayFrequency"

        FixedPassingTimes ->
            "fixedPassingTimes"

        NotFlexible ->
            "notFlexible"

        Other ->
            "other"