module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)


type alias Model =
    { chat : List Chat
    , currentText : String
    }


intitialModel : Model
intitialModel =
    Model
        [ { time = "", text = "One", user = "" } ]
        ""


type alias Chat =
    { time : String
    , text : String
    , user : String
    }


type Msg
    = Submit
    | TextChange String


init : ( Model, Cmd Msg )
init =
    intitialModel ! []


view : Model -> Html Msg
view model =
    div [ class "maincontainer" ]
        [ div [ class "header" ] []
        , div [ class "listview" ]
            (List.map renderListItem model.chat)
        , div [ class "footer" ]
            [ Html.form [ onSubmit Submit ]
                [ input
                    [ type_ "text"
                    , onInput TextChange
                    , value model.currentText
                    , autofocus True
                    ]
                    []
                ]
            ]
        ]


renderListItem : Chat -> Html Msg
renderListItem chat =
    div [] [ text chat.text ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange text ->
            { model | currentText = text } ! []

        Submit ->
            let
                newChat =
                    { time = ""
                    , text = model.currentText
                    , user = ""
                    }
            in
                { model | chat = newChat :: model.chat, currentText = "" } ! []


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
