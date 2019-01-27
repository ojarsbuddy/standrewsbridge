# standrewsbridge
Converting at long last a production calendar widget to Elm 0.19 from Elm 0.18.
# the algorithm
The fundamental idea is to leverage the single piece of state mentioned above. The current day of the month can start as anything. From that calculate the last day of the prior month, a day in the next month and the last day of the current month. To get the last day of the prior month, just subtract one day times the current date. To get a day in the next month add 32 days to the last day of the prior month insofar as no month has more than 31 days. From that day in the next month find the last day of the current month.

Each day has 86400 seconds so our only problem will be when a leap second is introduced. This will be ignored by this program with the idea that we will have roughhly a 1/86400 chance of encountering a leap second. Good odds so keep your fingers crossed.

Knowing the last day of the current month and the last day of the prior month we can produce with a common function a list of all the days of each month easily with `List.range`. The last day of a month is enough for us to produce the number of the month, the name of the month and the year for that month. That is everything we need to generate visual for the calendar and the links for each day.

