module View.NewLineStop exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (Msg(..))


-- NEW LINESTOP VIEW


view : Html Msg
view =
    Html.form [ onSubmit FormSubmitTriggered, class "form" ]
        [ h2 [] [ text "Form" ]
        , div [ class "form-group" ]
            [ label [ for "name " ] [ text "Name" ]
            , input [ onInput FormNameChanged, id "name", name "name", class "form-control" ] []
            ]
        , div
            [ class "form-group" ]
            [ label [ for "id" ] [ text "Ruter id" ]
            , input [ onInput FormIdChanged, name "id", class "form-control" ] []
            ]
        , div [ class "form-group" ]
            [ label [ for "direction" ] [ text "Direction" ]
            , input [ onInput FormDirectionChanged, name "direction", class "form-control" ] []
            ]
        , button [ class "btn" ] [ text "Lagre" ]
        ]
