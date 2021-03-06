# Husker Du

## standrewsbridge

Converting at long last a production calendar widget to Elm 0.19 from Elm 0.18.

## Fix the calendar bug around midnight

The planned algorithm features one piece of state: the time and date when the instance of the website starts. Deriving everything else from that one immutable state should make the responding views stable, which is not the case with the website now in the wild. So let's make sure it does not change! Perhaps that will fix the instability of the website now in production.

Why does the current program fail? The bug has happened again. Time for some serious debugging in Pharo. The offset calculation was incorrect for all cases. The solution is embodied in the second line of the code below. Pharo is very easy to use.

```smalltalk
aDayThisMonth := Date year: 2019 month: 5 day: 30 .
offset := 35-(aDayThisMonth dayOfMonth).
aDayNextMonth := aDayThisMonth addDays: offset.

lastDayOfCurrentMonth := aDayNextMonth subtractDays: aDayNextMonth dayOfMonth .
lastDayOfPriorMonth := aDayThisMonth subtractDays: aDayThisMonth dayOfMonth.

firstDayOfCurrentMonth := (lastDayOfCurrentMonth subtractDays: lastDayOfCurrentMonth dayOfMonth) addDays: 1.
firstDayOfPriorMonth := (lastDayOfPriorMonth subtractDays: lastDayOfPriorMonth dayOfMonth) addDays: 1.

Transcript clear ;
  show: 'Get the date for today' ; cr ;
  show: aDayThisMonth  ; cr ; cr ;
  show: 'Catch a day next month' ; cr ;
  show: aDayNextMonth ; cr ; cr ;
  show: 'Get first day of current month' ; cr ;
  show: firstDayOfCurrentMonth ; cr ; cr ;
  show: 'Get last day of current month' ; cr ;
  show: lastDayOfCurrentMonth ; cr ; cr ;
  show: 'Get first day of prior month' ; cr ;
  show: firstDayOfPriorMonth ; cr ; cr ;
  show: 'Get last day of prior month' ; cr ;
  show: lastDayOfPriorMonth ; cr

```

```smalltalk
Get the date for today
30 May 2019

Catch a day next month
4 June 2019

Get first day of current month
1 May 2019

Get last day of current month
31 May 2019

Get first day of prior month
1 April 2019

Get last day of prior month
30 April 2019
```

Here is a bit of code that instantiates the heart of this algorithm: `div [] [ 35-(Time.toDay model.zone model.now)|> Debug.toString |> text ]`.

## Just the current date

Found a way to get the current date. This deserves some explanation as it is somewhat obscure. But there is not a `Maybe` in sight! You have to install the package: `elm install elm\time`. Use the functions `Time.now` and `Time.zone` wrapped in a `Task.perform` to get something useful which might resemble the record `{ now = Posix 1546098529771, zone = Zone -300 [] }`, where `now` and `zone` are named keys. In Elm 0.19 we get zone information and POSIX time information. POSIX is short for Portable Operating System Interface. This is much nicer than what I did in Elm 0.18 to calculate dates.

## The algorithm

The fundamental idea is to leverage the single piece of state mentioned above. The current day of the month can start as anything. From that calculate the last day of the prior month, a day in the next month and the last day of the current month. To get the last day of the prior month, just subtract one day times the current date. To get a day in the next month add 32 days to the last day of the prior month insofar as no month has more than 31 days. From that day in the next month find the last day of the current month. This is cleaner than what I did the first time around.

Each POSIX day has 86400 seconds so our only problem may be when a leap second is introduced. Leap seconds are used to compensate for the slowing down of the Earth's rate of rotation and the irregularities in that rate of rotation. This will be ignored by this program because we can be a few seconds off without a loss of intended functionality.

Knowing the last day of the current month and the last day of the prior month we can produce with a common function a list of all the days of each month easily with `List.range`. The last day of a month is enough for us to produce the number of the month, the name of the month and the year for that month. That is everything we need to generate visual for the calendar and the links for each day.

To vary format by the day we had used the time functions in Elm 0.18 but here we will use the offset and the day modulo 7 to trigger format changes.

## Embedding

From 0.18 to 0.19 embedding changed. See `https://guide.elm-lang.org/interop/`.

```elm
            <!-- elm-lang -->
            <div id="newstandrewscalendar19" style="display:grid"></div>
            <script type="text/javascript" src="js/newstandrewscalendar19.js"></script>
            <script>
            var app = Elm.Main.init({
                node: document.getElementById('newstandrewscalendar19')
            });
            </script>
```

## Other matters

When I want to see the changes I run `elm reactor` in the terminal and look at the results on `http://localhost:8000`.

Here is how the JavaScript module is created: `elm make src/standrewsresults.elm --output=newstandrewscalendar19.js`.

Using `Debug.toString` a lot to help see what my functions produce, _e.g._, `div [] [ model |> Debug.toString |> text ]`.
