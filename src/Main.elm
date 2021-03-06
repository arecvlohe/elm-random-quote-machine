module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled, class)
import Maybe exposing (withDefault)
import Http exposing (Request, request, header, emptyBody, expectJson)
import Json.Decode exposing (string, map2, at)


{- import List.Extra exposing (getAt) -}
-- REQUEST


get : Request Quote
get =
    request
        { method = "GET"
        , headers =
            [ header "X-TheySaidSo-Api-Secret" "l7GYREuEF11EJiJYl5zTCweF"
            , header "Accept" "application/json"
            ]
        , url = "http://quotes.rest/quote/random.json"
        , body = emptyBody
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }



-- DECODER


decoder : Json.Decode.Decoder Quote
decoder =
    map2 Quote (at [ "contents", "author" ] string) (at [ "contents", "quote" ] string)



-- MODEL


type alias Quote =
    { author : String
    , quote : String
    }


type alias Model =
    { content : Quote
    , fetching : Bool
    }


model : Model
model =
    { content = { author = "", quote = "" }, fetching = False }


init : ( Model, Cmd Msg )
init =
    ( { content = { author = "", quote = "" }, fetching = True }, getNewQuote )



{-
   defaultQuote : Model
   defaultQuote =
       { author = "Default author", quote = "Default quote" }


   quotes : List Model
   quotes =
       [ { author = "Adam", quote = "Some things" }
       , { author = "Joe", quote = "Some other things" }
       , { author = "John", quote = "Some other other things" }
       , { author = "Jacob", quote = "Good things" }
       ]
-}
-- UPDATE


type Msg
    = NoOp
    | FetchQuote
    | NewQuote (Result Http.Error Quote)



-- | RandomNumber Int


getNewQuote : Cmd Msg
getNewQuote =
    Http.send NewQuote get


buttonText : Bool -> Html a
buttonText bool =
    if bool then
        text "...Fetching Quote"
    else
        text "Fetch Random Quote"


spinnerWhileLoading : Model -> List (Html a)
spinnerWhileLoading model =
    if model.fetching then
        [ div [ class "o-loader" ] [ text "" ] ]
    else
        [ div [ class "quote__text--quote" ] [ text model.content.quote ]
        , div [ class "quote__text--author" ] [ text ("--" ++ model.content.author ++ "--") ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchQuote ->
            ( { model | fetching = True }, getNewQuote )

        {-
           RandomNumber int ->
               ( withDefault defaultQuote (getAt int quotes), Cmd.none )
        -}
        NewQuote (Ok response) ->
            ( { model | content = response, fetching = False }, Cmd.none )

        NewQuote (Err _) ->
            ( { model | fetching = False }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "l-container container" ]
        [ div [ class "l-quote quote" ] (spinnerWhileLoading model)
        , button [ onClick FetchQuote, disabled model.fetching, class "o-button" ] [ buttonText model.fetching ]
        ]



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
