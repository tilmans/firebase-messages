module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit)
import Material
import Material.List as ML
import Material.Textfield as MT
import Material.Options as Options
import Material.Layout as Layout


type alias Model =
    { mdl : Material.Model
    , chat : List Chat
    , currentText : String
    }


intitialModel : Model
intitialModel =
    Model
        Material.model
        [ { time = "", text = "One", user = "" } ]
        ""


type alias Chat =
    { time : String
    , text : String
    , user : String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | Upd0 String
    | Submit


init : ( Model, Cmd Msg )
init =
    intitialModel ! []


view : Model -> Html Msg
view model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader ]
        { header = [ text "Header" ]
        , drawer = []
        , tabs = ( [], [] )
        , main = (mainbody model)
        }


mainbody : Model -> List (Html Msg)
mainbody model =
    [ div [ class "maincontainer" ]
        [ div [ class "listview" ]
            [ ML.ul []
                (List.map renderChatItems (List.reverse model.chat))
            ]
        , div [ class "footer" ]
            [ Html.form [ onSubmit Submit ]
                [ (MT.render Mdl [ 0 ] model.mdl)
                    [ Options.onInput Upd0
                    , MT.autofocus
                    , MT.value model.currentText
                    , MT.label "Chat"
                    ]
                    []
                ]
            ]
        ]
    ]


renderChatItems : Chat -> Html Msg
renderChatItems chat =
    ML.li [] [ ML.content [] [ text chat.text ] ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Layout.subs Mdl model.mdl


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl message ->
            Material.update Mdl message model

        Upd0 string ->
            { model | currentText = string } ! []

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
