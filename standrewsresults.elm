module Main exposing (main)

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
        [ div [ style "background-color" "rgba(0, 175, 80, 0.3)" ]
            [ h2 styleHeading [ text (currentMonth model ++ " " ++ currentYear model) ]
            , div
                ([]
                    ++ styleGrid
                )
                ([]
                    ++ headDays
                    ++ makeEmptyDays (currentEmptyDays model)
                    ++ makeDays (currentDates model)
                )
            ]
        , div [ style "background-color" "rgba(0, 80, 175, 0.3)" ]
            [ h2 styleHeading [ text (priorMonth model ++ " " ++ priorYear model) ]
            , div
                ([]
                    ++ styleGrid
                )
                ([]
                    ++ headDays
                    ++ makeEmptyDays (priorEmptyDays model)
                    ++ makeDays (priorDates model)
                )
            ]
        ]



-- helper functions


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
    [ p styleHeadDays [ text "Su" ]
    , p styleHeadDays [ text "Mo" ]
    , p styleHeadDays [ text "Tu" ]
    , p styleHeadDays [ text "We" ]
    , p styleHeadDays [ text "Th" ]
    , p styleHeadDays [ text "Fr" ]
    , p styleHeadDays [ text "Sa" ]
    ]


styleHeadDays =
    [ style "text-align" "center"
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


someDayNextMonth : Time.Zone -> Time.Posix -> Time.Posix
someDayNextMonth zone posix =
    Time.posixToMillis posix
        + oneDay
        * 32
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


priorMonth : Model -> String
priorMonth model =
    model.now
        |> lastDayPriorMonth model.zone
        |> Time.toMonth model.zone
        |> toMonth


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


makeDays : List Int -> List (Html Msg)
makeDays list =
    list
        |> List.map
            (\x ->
                div styleMakeDays
                    [ div [] [ x |> String.fromInt |> text ]
                    , div [ style "color" "aliceblue" ] [ a [ href "E.htm", style "text-decoration" "none" ] [ "E" |> text ] ]
                    , div [ style "color" "aliceblue" ] [ a [ href "M.htm", style "text-decoration" "none" ] [ "M" |> text ] ]
                    , div [ style "color" "aliceblue" ] [ a [ href "A.htm", style "text-decoration" "none" ] [ "A" |> text ] ]
                    ]
            )


makeEmptyDays : List Int -> List (Html Msg)
makeEmptyDays list =
    list
        |> List.map (\x -> p [] [ text " " ])


styleMakeDays =
    [ style "display" "grid"
    , style "grid-template-columns" "repeat(2,1fr)"
    , style "border" "solid 1px"
    , style "background" "lightblue"
    , style "text-align" "center"
    ]



-- old stuff


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


firstDayPriorMonth model =
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


lastDayPrior : Time.Zone -> Time.Posix -> Int
lastDayPrior zone posix =
    Time.posixToMillis posix - oneDay * Time.toDay zone posix


dateList x =
    List.range 1 x


firstDay : Time.Zone -> Time.Posix -> Int
firstDay zone posix =
    lastDayPrior zone posix + oneDay


dayList y =
    List.range 0 31
        |> List.map (\x -> oneDay * x + y)


trim x y =
    List.drop
        (List.reverse y
            |> List.head
            |> extractNumber
            |> Time.millisToPosix
            |> Time.toDay x
        )
        (List.reverse y)
        |> List.reverse
        |> List.map Time.millisToPosix


dayListPrior y z =
    List.range 0 (y - 1)
        |> List.map (\x -> z - oneDay * x)
        |> List.reverse
        |> List.map Time.millisToPosix


extractNumber y =
    case y of
        Just a ->
            a

        Nothing ->
            15


extractWeekDay : Maybe Time.Weekday -> Time.Weekday
extractWeekDay y =
    case y of
        Just a ->
            a

        Nothing ->
            Time.Sun


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
