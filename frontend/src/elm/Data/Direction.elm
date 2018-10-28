module Data.Direction exposing (Direction(..), convertDirection, decodeDirection, directionToComparable, stringToDirection)

import Json.Decode as Decode


type Direction
    = A
    | B
    | Unknown


decodeDirection : Int -> Decode.Decoder Direction
decodeDirection direction =
    Decode.succeed (convertDirection direction)


convertDirection : Int -> Direction
convertDirection directionString =
    case directionString of
        1 ->
            A

        2 ->
            B

        _ ->
            Unknown


directionToComparable : Direction -> String
directionToComparable direction =
    case direction of
        A ->
            "A"

        B ->
            "B"

        _ ->
            "Unknown"


stringToDirection : String -> Direction
stringToDirection directionString =
    case directionString of
        "A" ->
            A

        "B" ->
            B

        _ ->
            Unknown
