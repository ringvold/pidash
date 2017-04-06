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
            "ALL"


convertDirection : String -> Direction
convertDirection directionString =
    case directionString of
        "1" ->
            A

        "2" ->
            B

        _ ->
            All
