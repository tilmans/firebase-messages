module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)
import Firebase
import Firebase.Database
import Firebase.Database.Types


type alias Model =
    { app : Firebase.App
    , db : Firebase.Database.Types.Database
    , chat : List Chat
    , currentText : String
    }


type alias Chat =
    { time : String
    , text : String
    , user : String
    }


type alias Config =
    { apiKey : String
    , databaseURL : String
    , authDomain : String
    , storageBucket : String
    , messagingSenderId : String
    }


type Msg
    = Submit
    | TextChange String


init : Config -> ( Model, Cmd Msg )
init flags =
    let
        app : Firebase.App
        app =
            Firebase.init
                { apiKey = flags.apiKey
                , databaseURL = flags.databaseURL
                , authDomain = flags.authDomain
                , storageBucket = flags.storageBucket
                , messagingSenderId = flags.messagingSenderId
                }

        db : Firebase.Database.Types.Database
        db =
            Firebase.Database.init app

        intitialModel =
            Model app db [] ""
    in
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


main : Program Config Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
