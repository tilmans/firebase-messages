module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput, onClick)
import Firebase
import Firebase.Database
import Firebase.Database.Types
import Firebase.Database.Reference
import Firebase.Database.Snapshot
import Firebase.Errors
import Json.Decode
import Json.Encode
import Task


type alias Model =
    { app : Firebase.App
    , db : Firebase.Database.Types.Database
    , chat : List Chat
    , currentText : String
    , status : Status
    }


type alias Chat =
    { time : Int
    , text : String
    }


type alias Config =
    { apiKey : String
    , databaseURL : String
    , authDomain : String
    , storageBucket : String
    , messagingSenderId : String
    }


type Status
    = Sending
    | Success
    | Failed


type Msg
    = Submit
    | TextChange String
    | ChatUpdate Firebase.Database.Types.Snapshot
    | ChatSent (Result Firebase.Errors.Error ())
    | Delete
    | Deleted (Result Firebase.Errors.Error ())


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
            Model app db [] "" Success
    in
        intitialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        ref =
            model.db |> Firebase.Database.ref (Just "messages")
    in
        Firebase.Database.Reference.on "value" ref ChatUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange text ->
            { model | currentText = text } ! []

        Submit ->
            let
                newChat =
                    { time = 0
                    , text = model.currentText
                    }

                command =
                    model.db
                        |> Firebase.Database.ref (Just "messages")
                        |> Firebase.Database.Reference.push
                        |> Firebase.Database.Reference.set (jsonEncodeChat newChat)
                        |> Task.attempt ChatSent
            in
                ( { model | status = Sending }, command )

        ChatUpdate snapshot ->
            let
                decoded =
                    Json.Decode.decodeValue jsonDecodeChatList (Firebase.Database.Snapshot.value snapshot)

                chatList =
                    case decoded of
                        Err err ->
                            []

                        Ok serverChat ->
                            List.map (\( id, c ) -> c) serverChat
            in
                { model | chat = chatList } ! []

        ChatSent (Err err) ->
            { model | status = Failed } ! []

        ChatSent (Ok ()) ->
            { model | currentText = "", status = Success } ! []

        Delete ->
            let
                command =
                    model.db
                        |> Firebase.Database.ref (Just "messages")
                        |> Firebase.Database.Reference.set Json.Encode.null
                        |> Task.attempt Deleted
            in
                model ! [ command ]

        Deleted _ ->
            model ! []


view : Model -> Html Msg
view model =
    div [ class "maincontainer" ]
        [ div [ class "header" ]
            [ div [ class "title" ] [ text "Elm Messages" ]
            , div [ class "deleteButton", onClick Delete ] [ text "remove" ]
            ]
        , div [ class "listarea" ]
            [ div [ class "listview" ]
                (List.map renderListItem (List.reverse model.chat))
            ]
        , div
            [ class "footer"
            , classList [ ( "sending", model.status == Sending ) ]
            ]
            [ Html.form [ onSubmit Submit ]
                [ input
                    [ type_ "text"
                    , onInput TextChange
                    , value model.currentText
                    , autofocus True
                    , readonly (model.status == Sending)
                    ]
                    []
                , div [ class "submitarrow", onClick Submit ] [ text "arrow_upward" ]
                ]
            ]
        ]


renderListItem : Chat -> Html Msg
renderListItem chat =
    div [] [ text chat.text ]


main : Program Config Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- JSON Utilities


jsonDecodeChatList : Json.Decode.Decoder (List ( String, Chat ))
jsonDecodeChatList =
    Json.Decode.keyValuePairs jsonDecodeChat


jsonDecodeChat : Json.Decode.Decoder Chat
jsonDecodeChat =
    Json.Decode.map2 Chat
        (Json.Decode.field "created" Json.Decode.int)
        (Json.Decode.field "text" Json.Decode.string)


jsonEncodeChat : Chat -> Json.Encode.Value
jsonEncodeChat chat =
    Json.Encode.object
        [ ( "created", Json.Encode.object [ ( ".sv", Json.Encode.string "timestamp" ) ] )
        , ( "text", Json.Encode.string chat.text )
        ]
