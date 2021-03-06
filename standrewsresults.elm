module Main exposing (Model, Msg(..), calendarOffset, currentDates, currentEmptyDays, currentMonth, currentNumberMonth, currentYear, firstDayCurrentMonth, headDays, init, lastDayPriorMonth, main, makeDays, makeEmptyDays, oneDay, priorDates, priorEmptyDays, priorMonth, priorNumberMonth, priorYear, someDayNextMonth, styleGrid, styleHeadDays, styleHeading, styleMakeDays, toMonth, toNumberMonth, toWeekday, trim2, trimInt2, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Task
import Time



-- Husker Du!


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
    ( Model Time.utc (Time.millisToPosix 1548997249991), Task.perform Zone Time.here )



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

view : Model -> Html Msg
view model =
    div []
        [ div [ backgroundCurrentMonth ]
            [ h4 styleHeading [ text (currentMonth model ++ " " ++ currentYear model) ]
            , div
                ([]
                    ++ styleGrid
                )
                ([]
                    ++ headDays
                    ++ makeEmptyDays (currentEmptyDays model)
                    ++ makeDays (currentYear model) (currentNumberMonth model) (currentDates model) (currentEmptyDays model)
                )
            ]
        , div [ backgroundPriorMonth ]
            [ h4 styleHeading [ text (priorMonth model ++ " " ++ priorYear model) ]
            , div
                ([]
                    ++ styleGrid
                )
                ([]
                    ++ headDays
                    ++ makeEmptyDays (priorEmptyDays model)
                    ++ makeDays (priorYear model) (priorNumberMonth model) (priorDates model) (priorEmptyDays model)
                )
            ]
        ]



-- helper functions


backgroundCurrentMonth =
    style "background" "linear-gradient(to  right, burlywood, ivory, burlywood)"


backgroundPriorMonth =
    style "background" "linear-gradient(to  right, burlywood, ivory, burlywood, ivory, burlywood)"


backgroundDay =
    style "background" "linear-gradient(to bottom right, wheat, ivory)"


styleGrid =
    [ style "display" "grid"
    , style "grid-template-columns" "repeat(7,1fr)"
    , style "gap" "1px 1px"
    , style "font-weight" "bold"
    ]


styleHeading =
    [ style "text-align" "center" ]


oneDay : Int
oneDay =
    24 * 60 * 60 * 1000


headDays : List (Html Msg)
headDays =
    [ h5 styleHeadDays [ text "Su" ]
    , h5 styleHeadDays [ text "Mo" ]
    , h5 styleHeadDays [ text "Tu" ]
    , h5 styleHeadDays [ text "We" ]
    , h5 styleHeadDays [ text "Th" ]
    , h5 styleHeadDays [ text "Fr" ]
    , h5 styleHeadDays [ text "Sa" ]
    ]


styleHeadDays =
    [ style "text-align" "center"
    ]
        ++ [ backgroundDay ]


styleFileLink =
    [ style "color" "rgb(131, 42, 62)"
    , style "opacity" "0.4"
    ]


lastDayPriorMonth : Time.Zone -> Time.Posix -> Time.Posix
lastDayPriorMonth zone posix =
    Time.posixToMillis posix
        - oneDay
        * Time.toDay zone posix
        |> Time.millisToPosix


firstDayCurrentMonth : Time.Zone -> Time.Posix -> Time.Posix
firstDayCurrentMonth zone posix =
    Time.posixToMillis posix
        - oneDay
        * Time.toDay zone posix
        + oneDay
        |> Time.millisToPosix

-- this offset calculation takes care of the month end bug, where calendars do not form up properly

someDayNextMonth : Time.Zone -> Time.Posix -> Time.Posix
someDayNextMonth zone posix =
    (Time.posixToMillis posix
        + (oneDay * (35 - (Time.toDay zone posix)))
    )
        |> Time.millisToPosix


currentEmptyDays : Model -> List Int
currentEmptyDays model =
    ((model.now
        |> lastDayPriorMonth model.zone
        |> Time.posixToMillis
     )
        + oneDay
    )
        |> Time.millisToPosix
        |> Time.toWeekday model.zone
        |> calendarOffset
        |> List.range 1


priorEmptyDays : Model -> List Int
priorEmptyDays model =
    ((model.now
        |> lastDayPriorMonth model.zone
        |> Time.posixToMillis
     )
        - ((model.now
                |> lastDayPriorMonth model.zone
                |> Time.toDay model.zone
           )
            - 1
          )
        * oneDay
    )
        |> Time.millisToPosix
        |> Time.toWeekday model.zone
        |> calendarOffset
        |> List.range 1


currentMonth : Model -> String
currentMonth model =
    model.now
        |> someDayNextMonth model.zone
        |> lastDayPriorMonth model.zone
        |> Time.toMonth model.zone
        |> toMonth


currentNumberMonth : Model -> String
currentNumberMonth model =
    model.now
        |> someDayNextMonth model.zone
        |> lastDayPriorMonth model.zone
        |> Time.toMonth model.zone
        |> toNumberMonth


priorMonth : Model -> String
priorMonth model =
    model.now
        |> lastDayPriorMonth model.zone
        |> Time.toMonth model.zone
        |> toMonth


priorNumberMonth : Model -> String
priorNumberMonth model =
    model.now
        |> lastDayPriorMonth model.zone
        |> Time.toMonth model.zone
        |> toNumberMonth


currentYear : Model -> String
currentYear model =
    model.now
        |> someDayNextMonth model.zone
        |> lastDayPriorMonth model.zone
        |> Time.toYear model.zone
        |> String.fromInt


priorYear : Model -> String
priorYear model =
    model.now
        |> lastDayPriorMonth model.zone
        |> Time.toYear model.zone
        |> String.fromInt


currentDates : Model -> List Int
currentDates model =
    model.now
        |> someDayNextMonth model.zone
        |> lastDayPriorMonth model.zone
        |> Time.toDay model.zone
        |> List.range 1


priorDates : Model -> List Int
priorDates model =
    model.now
        |> lastDayPriorMonth model.zone
        |> Time.toDay model.zone
        |> List.range 1


makeDays year month days emptyDays =
    days
        |> List.map
            (\x ->
                div styleMakeDays
                    (htmlMakeDays year month days emptyDays x)
            )


htmlMakeDays year month days emptyDays x =
    case modBy 7 (x - 1 + List.length emptyDays) of
        0 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "A" |> text ] ]
            ]

        1 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "A" |> text ] ]
            ]

        2 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "A" |> text ] ]
            ]

        3 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "A" |> text ] ]
            ]

        4 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "E.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "A" |> text ] ]
            ]

        5 ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "M.htm"), style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "M.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 styleFileLink [ "A" |> text ] ]
            ]

        6 ->
            [ a [ href "", style "text-decoration" "none" ] [ h6 [] [ String.fromInt x |> text ] ]
            , a [ href "", style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "E" |> text ] ]
            , a [ href "", style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "M" |> text ] ]
            , a [ href "", style "text-decoration" "none" ] [ h6 (styleFileLink ++ hideLink) [ "A" |> text ] ]
            ]

        _ ->
            [ a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ String.fromInt x |> text ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ "E" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ "M" |> text ] ]
            , a [ href ("staresults/" ++ year ++ ".all/sta" ++ trim2 year ++ trim2 month ++ trimInt2 x ++ "A.htm"), style "text-decoration" "none" ] [ h6 [] [ "A" |> text ] ]
            ]


hideLink =
    [ style "visibility" "hidden" ]


trim2 x =
    ("0" ++ x)
        |> String.right 2


trimInt2 : Int -> String
trimInt2 x =
    ("0" ++ String.fromInt x)
        |> String.right 2


makeEmptyDays : List Int -> List (Html Msg)
makeEmptyDays list =
    list
        |> List.map (\x -> p [] [ text " " ])


styleMakeDays =
    [ style "display" "grid"
    , style "grid-template-columns" "repeat(2,1fr)"
    , style "background" "linear-gradient(to bottom right, wheat, ivory)"
    , style "text-align" "center"
    ]


calendarOffset : Time.Weekday -> Int
calendarOffset weekday =
    case weekday of
        Time.Sun ->
            0

        Time.Mon ->
            1

        Time.Tue ->
            2

        Time.Wed ->
            3

        Time.Thu ->
            4

        Time.Fri ->
            5

        Time.Sat ->
            6



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


toNumberMonth : Time.Month -> String
toNumberMonth month =
    case month of
        Time.Jan ->
            "1"

        Time.Feb ->
            "2"

        Time.Mar ->
            "3"

        Time.Apr ->
            "4"

        Time.May ->
            "5"

        Time.Jun ->
            "6"

        Time.Jul ->
            "7"

        Time.Aug ->
            "8"

        Time.Sep ->
            "9"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"
