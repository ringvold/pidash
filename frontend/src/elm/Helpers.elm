module Helpers exposing (..)

import Types exposing (..)


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
