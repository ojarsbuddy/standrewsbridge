module Main exposing (main)

import Browser
import Html exposing (..)
import Task
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , now : Time.Posix
    }


init : ( Model, Cmd Msg )
init =
    ( Model Time.utc (Time.millisToPosix 0), Task.perform Zone Time.here )



-- UPDATE


type Msg
    = Zone Time.Zone
    | Now Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Zone zone ->
            ( { model | zone = zone }, Task.perform Now Time.now )

        Now now ->
            ( { model | now = now }, Cmd.none )



-- VIEW


formatTime zone posix =
    (String.padLeft 2 '0' <| String.fromInt <| Time.toHour zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toMinute zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toSecond zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| toMonth (Time.toMonth zone posix))
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toDay zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toYear zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| toWeekday (Time.toWeekday zone posix))


monthmonth zone posix =
    toMonth (Time.toMonth zone posix)


yearyear zone posix =
    String.fromInt <| Time.toYear zone posix


view : Model -> Html Msg
view model =
    let
        day =
            String.fromInt (Time.toDay model.zone model.now)

        weekday =
            toWeekday (Time.toWeekday model.zone model.now)

        month =
            toMonth (Time.toMonth model.zone model.now)

        year =
            String.fromInt (Time.toYear model.zone model.now)

        hour =
            String.fromInt (Time.toHour model.zone model.now)

        minute =
            String.fromInt (Time.toMinute model.zone model.now)

        second =
            String.fromInt (Time.toSecond model.zone model.now)
    in
    div []
        [ h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , h1 [] [ text (day ++ ":" ++ weekday ++ ":" ++ month ++ ":" ++ year) ]
        , div []
            [ text "calendar1"
            , h2 [] [ text (month ++ " " ++ year) ]
            ]
        , div []
            [ text "calendar2"
            , h2 [] [ text (month ++ " " ++ year) ]
            ]
        ]



-- Convert date element types to strings


toWeekday : Time.Weekday -> String
toWeekday weekday =
    case weekday of
        Time.Mon ->
            "Mo"

        Time.Tue ->
            "Tu"

        Time.Wed ->
            "We"

        Time.Thu ->
            "Th"

        Time.Fri ->
            "Fr"

        Time.Sat ->
            "Sa"

        Time.Sun ->
            "Su"


toMonth : Time.Month -> String
toMonth month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"
