# Working with date and time in Go

In Go, the `time` package from the standard library is used to work with dates, times and time intervals.

Working with time shows up in many places in backend programs. For example:

* saving when a database record was created;
* checking whether a token's validity period has expired;
* setting a timeout on an HTTP or database operation;
* showing the user a time in their time zone;
* calculating how much time has passed between two events;
* running some work after a certain time.

When working with time it is important to tell three main concepts apart:

* `time.Time` — an exact point on the timeline;
* `time.Duration` — a time interval that says how long something lasted;
* `time.Location` — determines which time zone's rules a point in time should be displayed with.

For example, one meeting may be at `14:00` in Tashkent. The same meeting appears at another local hour in London.

This does not mean two different meetings. The point on the timeline is one. Only the `Location` used to display it is different.

## Getting the current time

`time.Now()` is used to get the current time.

This function gets the current time from the operating system and returns a `time.Time` value:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()

	fmt.Println("Local time:", now)
	fmt.Println("UTC time:", now.UTC())
}
```

The result depends on when and in which environment the program was run. For example:

```text
Local time: 2026-03-15 14:30:20.123456789 +0500 +05 m=+0.000031201
UTC time: 2026-03-15 09:30:20.123456789 +0000 UTC
```

Here `now` holds the time in the server's local time zone.

`now.UTC()` returns exactly the same point in time in UTC form.

The important point is that `time.Now()` does not always return UTC. It uses the system's local `Location`.

For example, if the server is set to UTC:

```go
time.Now()
```

the result itself may also be in UTC.

If the server runs in the Tashkent time zone, the result may come out with an offset around `+05:00`.

That is why guessing in code which time zone the server runs in is not a good approach. If UTC is needed, it is better to write it explicitly:

```go
now := time.Now().UTC()
```

The standard `time.Time` text form above has several parts:

| Part                 | Meaning                                                                |
| -------------------- | ---------------------------------------------------------------------- |
| `2026-03-15`         | year, month and day                                                    |
| `14:30:20.123456789` | hour, minute, second and the fractional part of the second             |
| `+0500`              | the shift from UTC, i.e. the offset                                    |
| `+05`                | the time zone name; depending on the system it may be a different name |
| `m=+...`             | a monotonic clock reading that may be inside `time.Time`               |

The last `m=+...` part may look strange at first glance. It is not part of an ordinary date or time zone.

### What is monotonic time?

When measuring time, it is useful to separate two concepts:

* wall clock;
* monotonic clock.

The **wall clock** is the ordinary date and time the user sees.

For example:

```text
2026-03-15 14:30:20
```

This time is tied to the operating system clock.

And the system time can change. For example:

* an administrator may change the clock by hand;
* NTP may correct the time;
* the system clock may shift forward or backward.

If we calculate the duration between two events only through the wall clock, such changes may affect the result.

The **monotonic clock**, on the other hand, is meant for measuring time intervals.

Its main job:

> is not to answer "what time is it?", but to answer "how much time has passed?".

The `time.Time` value returned by `time.Now()` may also hold a monotonic reading.

For example:

```go
start := time.Now()

// Some work is done.

elapsed := time.Since(start)
```

If `start` has monotonic data, `time.Since` is less affected by corrections of the operating system's wall clock time.

Operations such as `Sub`, `Before` and `After` may also use it when both operands have monotonic data.

There is a subtle point here.

Understanding the `m=+...` value as:

> "The time passed since the program started"

is not correct.

It is an internal monotonic reading used by the runtime. It is not a permanent identifier and should not be used to save to a database or send to another service.

During formatting and serialization the monotonic part is usually removed.

For example:

```go
now.Format(time.RFC3339)
```

does not write `m=+...` in the result.

In the same way, when a `time.Time` is converted to JSON, the monotonic reading is not passed to another system.

## Getting the parts of a date and time

The year, month, day, hour and other parts can be taken separately from a `time.Time` value.

`time.Time` has methods for this:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.February, 29, 16, 45, 30, 0, time.UTC)

	fmt.Println("Year:", moment.Year())
	fmt.Println("Month:", moment.Month())
	fmt.Println("Day:", moment.Day())
	fmt.Println("Weekday:", moment.Weekday())
	fmt.Println("Hour:", moment.Hour())
	fmt.Println("Minute:", moment.Minute())
	fmt.Println("Second:", moment.Second())
}
```

Result:

```text
Year: 2024
Month: February
Day: 29
Weekday: Thursday
Hour: 16
Minute: 45
Second: 30
```

`time.Now()` is not used in this example.

The time is given exactly in advance:

```go
time.Date(2024, time.February, 29, 16, 45, 30, 0, time.UTC)
```

That is why the result is the same every time.

What the methods do:

```go
moment.Year()
```

returns the year.

```go
moment.Month()
```

returns the month as the `time.Month` type.

```go
moment.Day()
```

gives the number of the day within the month.

```go
moment.Weekday()
```

returns the day of the week.

```go
moment.Hour()
moment.Minute()
moment.Second()
```

give the corresponding parts of the time.

`Month()` returns not a plain `int` but the `time.Month` type.

When printed with `fmt.Println` it may come out as an English name like:

```text
February
```

In the same way, `Weekday()` gives an English value like:

```text
Thursday
```

If you need to show the user names in another language, for example in Uzbek:

```text
Fevral
Payshanba
```

this must be localized separately at the application level.

The `time` package does not automatically translate month and weekday names into other languages.

## Formatting time

A `time.Time` value may need to be sent to the user or another system as a string.

The `Format` method is used for this.

Go's time formatting system differs from many other programming languages.

For example, in other languages the following form may appear:

```text
YYYY-MM-DD
```

In Go such format symbols are not used.

Instead, a special **reference time**, i.e. a sample time, is used:

```text
Mon Jan 2 15:04:05 MST 2006
```

When writing a Go layout, the needed format is expressed with the parts of this sample time.

The following sequence is also used to remember it:

```text
01/02 03:04:05PM '06 -0700
```

These numbers were not chosen at random.

They are used respectively as:

```text
01 → month
02 → day
03 → 12-hour clock hour
04 → minute
05 → second
06 → the last two digits of the year
-0700 → time zone offset
```

Example:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.August, 9, 16, 7, 5, 123_000_000, time.UTC)

	fmt.Println("Date:", moment.Format("02-01-2006"))
	fmt.Println("Time:", moment.Format("15:04:05"))
	fmt.Println("API:", moment.Format(time.RFC3339Nano))
}
```

Result:

```text
Date: 09-08-2024
Time: 16:07:05
API: 2024-08-09T16:07:05.123Z
```

The first format:

```go
moment.Format("02-01-2006")
```

means the following order:

```text
day-month-year
```

That is why:

```text
09-08-2024
```

is produced.

The second format:

```go
moment.Format("15:04:05")
```

gives the 24-hour form:

```text
hour:minute:second
```

Result:

```text
16:07:05
```

When sending time between APIs and services, it is usually better to use standard formats.

For example:

```go
time.RFC3339
```

or, if nanosecond precision must be kept:

```go
time.RFC3339Nano
```

This approach is safer than arbitrarily creating a new date format in every project.

### The main layout parts

Commonly used parts of a Go layout:

| Layout part    | Meaning of the result                      |
| -------------- | ------------------------------------------ |
| `2006`         | four-digit year                            |
| `06`           | two-digit year                             |
| `01`           | two-digit month                            |
| `1`            | month without a leading zero               |
| `Jan`          | short month name                           |
| `January`      | full month name                            |
| `02`           | two-digit day                              |
| `2`            | day without a leading zero                 |
| `Mon`          | short weekday                              |
| `Monday`       | full weekday                               |
| `15`           | 24-hour clock hour                         |
| `03`           | 12-hour clock hour                         |
| `PM` or `pm`   | 12-hour period marker                      |
| `04`           | minute                                     |
| `05`           | second                                     |
| `.000`         | milliseconds, always three digits          |
| `.000000`      | microseconds, always six digits            |
| `.000000000`   | nanoseconds, always nine digits            |
| `MST`          | zone name                                  |
| `-0700`        | an offset in the `+0500` form              |
| `-07:00`       | an offset in the `+05:00` form             |
| `Z07:00`       | `Z` for UTC, a numeric offset in other zones |

You do not have to memorize this table. But recognizing main parts like `2006-01-02` and `15:04:05` is very useful.

Especially when coming to Go from other languages, the following mistake is very common:

```go
// Wrong: "YYYY" is not a Go layout symbol.
fmt.Println(moment.Format("YYYY-MM-DD"))
```

This code compiles.

The problem is that Go does not recognize `YYYY`, `MM` or `DD` as special format symbols.

It treats them as plain text.

That is why such a mistake may not be caught at compile time.

For example, for the year:

```text
2006
```

for the month:

```text
01
```

for the day:

```text
02
```

must be used:

```go
moment.Format("2006-01-02")
```

Understanding the reference time model of Go layouts is important here. Otherwise the code may seem to work but produce a wrong string.

## Converting a string to time

Sometimes time comes not as a `time.Time` but as a string.

For example, an HTTP request may send the value:

```text
2024-08-09
```

`time.Parse` is used to convert such a string to a `time.Time`:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	input := "2024-08-09"
	moment, err := time.Parse("2006-01-02", input)
	if err != nil {
		fmt.Println("Invalid date:", err)
		return
	}

	fmt.Println(moment.Format(time.RFC3339))
}
```

Result:

```text
2024-08-09T00:00:00Z
```

`time.Parse` takes two important pieces of information:

```go
time.Parse(layout, value)
```

The first is the layout that says what format the string is in.

The second is the value to parse.

In this example:

```go
"2006-01-02"
```

matches the following string:

```text
2024-08-09
```

The time part is not given in the string.

That is why:

```text
00:00:00
```

is used.

There is no time zone in the layout either.

In such a case `time.Parse` creates the value in UTC.

That is why the result is:

```text
2024-08-09T00:00:00Z
```

The string must match the layout.

For example:

```text
2024-02-30
```

is a date that does not exist in the calendar.

There is no 30th of February.

That is why `time.Parse` returns an error.

This is especially important when working with external data.

Writing it like this is dangerous:

```go
moment, _ := time.Parse("2006-01-02", input)
```

Here the error is completely ignored.

If the input is wrong, the following business logic may work with a wrong time.

That is why `err` must be checked when parsing time that came from outside.

### Parsing local time in a certain zone

Imagine the following value:

```text
2024-08-09 14:30
```

This string has a date and a time.

But there is no time zone.

That is why an important question arises:

> `14:30` is the local time of which region?

If it is Tashkent time, the application must know it.

In such a situation `time.ParseInLocation` is used:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	location, err := time.LoadLocation("Asia/Tashkent")
	if err != nil {
		fmt.Println("The time zone was not loaded:", err)
		return
	}

	input := "2024-08-09 14:30"
	moment, err := time.ParseInLocation("2006-01-02 15:04", input, location)
	if err != nil {
		fmt.Println("Invalid time:", err)
		return
	}

	fmt.Println("Tashkent:", moment.Format(time.RFC3339))
	fmt.Println("UTC:", moment.UTC().Format(time.RFC3339))
}
```

Result:

```text
Tashkent: 2024-08-09T14:30:00+05:00
UTC: 2024-08-09T09:30:00Z
```

Let's look at the process step by step.

First the Tashkent location is loaded:

```go
location, err := time.LoadLocation("Asia/Tashkent")
```

`Asia/Tashkent` is a name from the IANA time zone database.

Then:

```go
time.ParseInLocation("2006-01-02 15:04", input, location)
```

is called.

No time zone is written in `input`.

That is why Go interprets this time based on the rules of:

```text
Asia/Tashkent
```

The result is:

```text
2024-08-09T14:30:00+05:00
```

Then:

```go
moment.UTC()
```

is called.

Result:

```text
2024-08-09T09:30:00Z
```

Here the point in time did not change.

Only the same time was shown in another time zone.

That is:

```text
14:30 +05:00
```

and:

```text
09:30 UTC
```

are the same point in time.

`time.LoadLocation` needs IANA time zone data.

This data can be taken from the operating system's zoneinfo database.

On ordinary Linux distributions it is usually present.

But if a very minimal container image is used, the zoneinfo database may be missing entirely.

In such a case:

```go
time.LoadLocation("Asia/Tashkent")
```

may return an error.

The problem can be solved in several ways.

For example, the zoneinfo data can be installed into the container image.

Or the time zone database can be added to the Go program:

```go
import _ "time/tzdata"
```

This approach adds the time zone data inside the executable.

The advantage is that the program depends less on external zoneinfo files.

The drawback is that the executable gets bigger.

That is why which option to choose depends on the deployment requirements.

> **Attention**
>
> `time.FixedZone("UZT", 5*60*60)` creates a zone with a constant `+05:00` offset.
>
> But `FixedZone` does not know historical time zone rules or changes such as daylight saving time.
>
> If a region's time rules have changed over history or may change in the future, it is better to use `time.LoadLocation` and an IANA name like `Asia/Tashkent`.

## Creating time with `time.Date`

`time.Date` is used to create a `time.Time` from a certain year, month, day and hour.

Example:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(
		2024,
		time.August,
		9,
		14,
		30,
		0,
		0,
		time.UTC,
	)

	fmt.Println(moment.Format(time.RFC3339))
}
```

Result:

```text
2024-08-09T14:30:00Z
```

The `time.Date` arguments can be pictured in simple form as follows:

```text
year
month
day
hour
minute
second
nanosecond
location
```

In this example:

```go
2024
```

is the year.

```go
time.August
```

is August.

```go
9
```

is the 9th day of the month.

```go
14, 30, 0
```

is `14:30:00`.

The nanosecond:

```go
0
```

And the location is given as:

```go
time.UTC
```

The month can also be written like this:

```go
time.Date(2024, 8, 9, ...)
```

This compiles.

The reason is that `time.Month` is a named type based on an integer.

But writing:

```go
time.August
```

is much clearer.

A person looking at the code does not have to remember what `8` means.

### `time.Date` normalizes values

There is an important subtlety here.

`time.Date` does not always reject out-of-range values as errors.

It may normalize them.

For example, if the 32nd of January is given, the result moves into the next month.

That is:

```text
32 January 2024
```

an invalid calendar value may turn into a date in February without giving an error directly.

That is why using `time.Date` as a validator for the question:

> "Does the date the user entered really exist?"

is not good.

If a user or an external API sends text, for example:

```text
2024-02-30
```

it is better to check it with a strict layout through:

```go
time.Parse("2006-01-02", input)
```

`Parse` returns an error for an invalid calendar date.

## `Duration`: a time interval

`time.Time` denotes a point on the timeline.

`time.Duration`, on the other hand, denotes how long something lasted.

For example:

```text
90 minutes
2 seconds
500 milliseconds
```

these are not points in time but durations.

In Go `time.Duration` is a named type based on `int64`.

The internal value is expressed in nanoseconds.

But in code you do not have to write the number of nanoseconds by hand.

There are standard constants:

```go
time.Nanosecond
time.Microsecond
time.Millisecond
time.Second
time.Minute
time.Hour
```

For example:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	start := time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
	duration := 90 * time.Minute
	end := start.Add(duration)

	fmt.Println("Start:", start.Format(time.RFC3339))
	fmt.Println("End:", end.Format(time.RFC3339))
	fmt.Println("Duration:", end.Sub(start))
}
```

Result:

```text
Start: 2024-01-01T12:00:00Z
End: 2024-01-01T13:30:00Z
Duration: 1h30m0s
```

In this example:

```go
duration := 90 * time.Minute
```

creates a 90-minute `Duration`.

Then:

```go
end := start.Add(duration)
```

adds 90 minutes to the start time.

As a result:

```text
12:00 + 90 minutes = 13:30
```

is produced.

Then:

```go
end.Sub(start)
```

returns the duration between the two times.

Result:

```text
1h30m0s
```

### Why is there no `time.Day`?

The Go standard library has:

```go
time.Hour
```

But there is no:

```go
time.Day
```

The reason is that a calendar day does not always mean exactly `24*time.Hour`.

In regions that use daylight saving time (DST), some calendar days in real time may last:

```text
23 hours
```

or:

```text
25 hours
```

That is why:

> "Exactly 24 hours"

and:

> "The next calendar day"

are two different concepts.

We will see this difference in the `Add` and `AddDate` section below.

### `ParseDuration`

In configuration, a time interval may come as text.

For example:

```text
1.5s
```

or:

```text
1h30m
```

Such values can be read with `time.ParseDuration`:

```go
timeout, err := time.ParseDuration("1.5s")
if err != nil {
	return err
}
```

Here:

```text
1.5s
```

equals the following duration:

```text
1500ms
```

`ParseDuration` returns an error for an invalid format or an unknown unit.

For example, when working with external configuration it is important to check the error.

`time.Duration` is based on `int64` internally.

That is why its range is not infinite.

When computing very large values, the possibility of `int64` overflow must also be considered.

This is rare in ordinary timeouts and service configuration, but in code that does arithmetic with very large durations this subtlety may matter.

## The difference between `Add` and `AddDate`

In Go there are at least two important ways to add something to a time:

* `Add`;
* `AddDate`.

Their meaning is not the same.

### `Add`

`Add` adds an exact `Duration`:

```go
later := moment.Add(2 * time.Hour)
earlier := moment.Add(-30 * time.Minute)
```

In the first line:

```go
2 * time.Hour
```

exactly two hours are added.

In the second line, because a negative duration is used:

```go
-30 * time.Minute
```

30 minutes are subtracted.

So `Add` works on the timeline with an exact duration.

### `AddDate`

`AddDate`, on the other hand, works with calendar units:

```go
nextMonth := moment.AddDate(0, 1, 0)
twoMonthsAgo := moment.AddDate(0, -2, 0)
nextWeek := moment.AddDate(0, 0, 7)
```

The `AddDate` arguments have the form:

```go
AddDate(years, months, days)
```

That is why:

```go
moment.AddDate(0, 1, 0)
```

adds one calendar month.

```go
moment.AddDate(0, -2, 0)
```

goes back two calendar months.

```go
moment.AddDate(0, 0, 7)
```

adds seven calendar days.

### `24*time.Hour` and one calendar day

The following two pieces of code do not always mean the same thing:

```go
moment.Add(24 * time.Hour)
```

and:

```go
moment.AddDate(0, 0, 1)
```

The first variant says:

> Add exactly 24 real hours.

The second variant says:

> Move to the next calendar day.

In a zone that uses DST, the next calendar day in local time may come after 23 or 25 real hours.

That is why the method is chosen according to the requirement.

If the requirement is:

> "Exactly 24 hours later"

then:

```go
Add(24 * time.Hour)
```

fits.

If the requirement is:

> "Tomorrow at the same local hour"

then:

```go
AddDate(0, 0, 1)
```

fits better.

### A subtle case when adding months

Calendar months are not the same length.

For example:

* some months have 31 days;
* some have 30 days;
* February has 28 or 29 days.

That is why when moving one month forward from the 31st day of a month, the 31st day may not exist in the new month.

`AddDate` computes such cases according to the `time.Date` normalization rules.

That is why if the business requirement is:

> "Exactly the last day of the next month"

simply:

```go
AddDate(0, 1, 0)
```

may not always give the needed business result.

For such a task a separate calendar rule for "the last day of the month" must be written.

## Working with time zones

It is not enough to think of `time.Time` as a plain struct that stores only the year, month and hour.

It may display a point in time with a certain `Location`.

The `Location` determines at what local hour the user sees this time.

The `In` method is used to display one point in time in another time zone:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	tashkent, err := time.LoadLocation("Asia/Tashkent")
	if err != nil {
		fmt.Println("The zone was not loaded:", err)
		return
	}

	moment := time.Date(2024, time.January, 15, 9, 0, 0, 0, time.UTC)

	fmt.Println("UTC:", moment.Format(time.RFC3339))
	fmt.Println("Tashkent:", moment.In(tashkent).Format(time.RFC3339))
}
```

Result:

```text
UTC: 2024-01-15T09:00:00Z
Tashkent: 2024-01-15T14:00:00+05:00
```

The initial value:

```text
2024-01-15T09:00:00Z
```

is in UTC.

Then:

```go
moment.In(tashkent)
```

is called.

Because Tashkent is `+05:00` ahead of UTC, the display is:

```text
2024-01-15T14:00:00+05:00
```

Here:

```text
09:00 UTC
```

and:

```text
14:00 +05:00
```

are not two different points in time.

They show the same point in two different time zones.

That is why `In` is not used for:

> turning the time itself into another time

It is used for:

> displaying the same point in time with the rules of another `Location`

A common approach in backend systems is as follows:

1. store points in time in UTC;
2. send UTC or a standard format with an explicit offset between services;
3. convert to the user's `Location` when displaying to them.

This approach reduces many time-zone-related bugs.

But forcibly treating all data as "a point in time" is not right either.

For example, a date of birth is often a calendar date. It does not have to be an exact UTC moment.

This difference must be considered when designing the API and database model.

### Offset and `Location` are not the same

The following value:

```text
+05:00
```

only denotes the current shift from UTC.

It does not denote the region's full historical rules.

For example:

```text
Asia/Tashkent
```

is an IANA time zone name and relies on the rules in the zoneinfo database.

If such a location is needed:

```go
time.LoadLocation("Asia/Tashkent")
```

is used.

That is why:

```text
+05:00
```

and:

```text
Asia/Tashkent
```

are not the same concept.

## Comparing times

There are special methods for comparing two `time.Time` values as points in time:

* `Before`;
* `After`;
* `Equal`.

Example:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	utc := time.Date(2024, time.January, 1, 9, 0, 0, 0, time.UTC)
	fixed := time.FixedZone("UTC+5", 5*60*60)
	local := time.Date(2024, time.January, 1, 14, 0, 0, 0, fixed)

	fmt.Println("Same point in time:", utc.Equal(local))
	fmt.Println("Is UTC earlier:", utc.Before(local))
}
```

Result:

```text
Same point in time: true
Is UTC earlier: false
```

Here the first time is:

```text
2024-01-01 09:00 UTC
```

The second time is:

```text
2024-01-01 14:00 UTC+5
```

`UTC+5` is five hours ahead of UTC.

That is why:

```text
14:00 - 5 hours = 09:00 UTC
```

So the two values express the same point in time.

That is why:

```go
utc.Equal(local)
```

returns `true`.

And `utc.Before(local)` is `false`.

Because `utc` is not before the second value. They are equal.

### Why should `==` not be used?

`time.Time` is a comparable type in Go.

So syntactically you can write:

```go
a == b
```

But this comparison may take into account not only the point on the timeline, but other parts of the internal representation of `time.Time` too.

For example:

* the `Location`;
* monotonic data.

That is why for the question:

> "Are these two values exactly the same point in time?"

it is better to use:

```go
a.Equal(b)
```

If:

```go
time.Time
```

is used as a `map` key, this subtlety is especially important.

For example, you can use:

```go
map[time.Time]string
```

But the same point in time may come with a different internal representation.

That is why before using it as a map key, you must clearly define a rule for how times are normalized.

## Unix timestamp

A Unix timestamp is a way of expressing a point in time with a single number.

The starting point is the Unix epoch:

```text
1970-01-01T00:00:00Z
```

A Unix timestamp says how many seconds or smaller time units have passed since that time.

Example:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.January, 1, 0, 0, 0, 0, time.UTC)
	seconds := moment.Unix()
	restored := time.Unix(seconds, 0).UTC()

	fmt.Println("Timestamp:", seconds)
	fmt.Println("Restored:", restored.Format(time.RFC3339))
}
```

Result:

```text
Timestamp: 1704067200
Restored: 2024-01-01T00:00:00Z
```

First:

```go
moment.Unix()
```

converts the point in time into Unix seconds.

Result:

```text
1704067200
```

Then:

```go
time.Unix(seconds, 0)
```

creates a new `time.Time` from this timestamp.

And `.UTC()` gives the result in UTC form.

### The timestamp unit must be stated explicitly

One of the most common mistakes when working with Unix timestamps is mixing up the unit.

For example:

```text
1704067200
```

may be seconds.

Another API may send the timestamp in milliseconds:

```text
1704067200000
```

If we take a millisecond value as seconds or vice versa, a completely wrong date is produced.

Go has methods that state the unit explicitly:

```go
moment.Unix()
moment.UnixMilli()
moment.UnixMicro()
moment.UnixNano()
```

Their names show which unit the value is in.

The unit must also be written clearly in the API contract.

For example, it is useful to state:

```text
created_at_unix_seconds
```

or in the documentation:

```text
Unix timestamp in milliseconds
```

### A Unix timestamp does not store a time zone

The Unix timestamp:

```text
1704067200
```

has no information such as:

```text
Asia/Tashkent
```

or:

```text
Europe/London
```

It only denotes a point in time.

Which `Location` to use when showing it to the user is chosen later.

## JSON and API formats

Go's standard `encoding/json` package usually serializes a `time.Time` value as text in RFC 3339 format.

For example:

```json
{
  "created_at": "2024-08-09T09:30:00Z"
}
```

The advantage of this form is that the time zone meaning is clear.

Here:

```text
Z
```

means UTC.

A value in another zone may look like, for example:

```text
2024-08-09T14:30:00+05:00
```

When sending time between services, it is important to use a format whose time zone or offset meaning is clear.

### A calendar date and a point in time are not the same

Sometimes an API needs to store only a date.

For example:

```text
2024-08-09
```

The Go layout for this is:

```text
2006-01-02
```

Here automatically giving the value the meaning of a point in time is not always right.

For example, a birthday:

```text
2000-05-10
```

is often just a calendar date.

If we convert it to:

```text
2000-05-10T00:00:00Z
```

and then move it to another time zone, in some zones the date may shift to:

```text
2000-05-09
```

or another calendar day.

This breaks the business meaning.

That is why do not mix the following concepts in the data model:

* an exact point in time;
* only a calendar date;
* a local calendar time.

This semantics also matters when choosing a database column.

For example, in a database:

* a point in time;
* only a date;
* a meeting tied to the user's local time

are not the same kind of data.

How the database driver and the database column type work with time zones must also be checked separately.

## `Sleep`, timer and ticker

The `time` package is not only for formatting dates.

It also gives tools to control goroutine work by time.

### `time.Sleep`

`time.Sleep` pauses the current goroutine for at least the given duration:

```go
time.Sleep(500 * time.Millisecond)
```

Here the goroutine pauses for about half a second.

The important point:

```go
time.Sleep(500 * time.Millisecond)
```

does not mean "exactly 500 milliseconds later the CPU is given to this goroutine again".

Because of the scheduler and the operating system, the goroutine may continue a bit later.

That is, `Sleep` denotes a minimum waiting duration.

If a zero or negative duration is given:

```go
time.Sleep(0)
```

or:

```go
time.Sleep(-1 * time.Second)
```

`Sleep` returns immediately.

### Timer

If a single signal after a certain time is needed, `time.NewTimer` is used:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	timer := time.NewTimer(20 * time.Millisecond)
	defer timer.Stop()

	<-timer.C
	fmt.Println("The timer fired")
}
```

Result:

```text
The timer fired
```

Here:

```go
timer := time.NewTimer(20 * time.Millisecond)
```

creates a 20-millisecond timer.

Inside the timer there is a channel:

```go
timer.C
```

Then:

```go
<-timer.C
```

waits for a signal to come from this channel.

When the timer expires, the goroutine continues and:

```text
The timer fired
```

is printed.

### `Stop`

In the following line:

```go
defer timer.Stop()
```

the timer is stopped when it is no longer needed.

If the timer has already fired, `Stop` may have no practical effect.

But if a still-active timer or ticker is no longer needed, stopping it is important so resources are not used unnecessarily.

### Ticker

If a periodic signal is needed, `time.NewTicker` is used.

For example, a ticker is convenient for doing some work every second.

But there is an important subtlety about tickers.

If the consumer is slow, the assumption that the ticker:

> collects every missed tick into an unlimited queue

is wrong.

That is why code should not blindly rely on the requirement:

> "Exactly one event is processed for every interval"

If accounting for every time interval separately matters for the business, a different design may be required.

### Do not synchronize with `Sleep`

An approach like the following is not good:

```go
go doWork()

time.Sleep(time.Second)

// assume doWork has finished
```

Here the program assumes:

> "One second should be enough"

But `doWork` may finish faster or slower.

To wait for a goroutine to finish, you should use:

* `sync.WaitGroup`;
* a channel;
* another explicit synchronization tool.

For backend operations that need timeouts and cancellation:

```go
context.WithTimeout
```

often fits.

## Measuring elapsed time

To measure how long an operation lasted, `time.Now()` and `time.Since()` can be used:

```go
start := time.Now()

// The work to measure.

elapsed := time.Since(start)
fmt.Println(elapsed)
```

The process is very simple:

1. the time is taken before the work starts;
2. the operation runs;
3. `time.Since(start)` calculates how much time has passed.

For example:

```go
start := time.Now()

doWork()

fmt.Println("Duration:", time.Since(start))
```

If the `start` value has monotonic clock data, `time.Since` may use it.

This reduces the effect of wall clock changes on the duration measurement.

But for performance analysis one such measurement is not enough.

For example, getting:

```text
12ms
```

once does not mean the function always runs in 12 milliseconds.

The result may be affected by:

* the scheduler;
* the garbage collector;
* CPU load;
* the cache;
* the operating system;
* other processes.

For repeatable and more stable performance measurement, it is better to use Go benchmarks.

## Testing time-dependent code

When testing time-dependent business logic, calling `time.Now()` directly inside the function may cause problems.

For example:

```go
func expired(deadline time.Time) bool {
	return !time.Now().Before(deadline)
}
```

The result of this function depends on when the test runs.

To make the test more stable, the current time can be passed in from outside:

```go
package main

import (
	"fmt"
	"time"
)

func expired(now, deadline time.Time) bool {
	return !now.Before(deadline)
}

func main() {
	now := time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
	deadline := now.Add(30 * time.Minute)

	fmt.Println(expired(now, deadline))
	fmt.Println(expired(deadline, deadline))
}
```

Result:

```text
false
true
```

For the first call:

```go
expired(now, deadline)
```

`now` is 30 minutes before the deadline.

That is why:

```go
now.Before(deadline)
```

is `true`.

And the function returns:

```go
!now.Before(deadline)
```

Result:

```text
false
```

that is, the period has not expired yet.

In the second call:

```go
expired(deadline, deadline)
```

`now` and `deadline` are equal.

`Before` returns `true` only if the first time is before the second.

If they are equal:

```go
deadline.Before(deadline)
```

is `false`.

That is why:

```go
!false
```

is `true`.

The result is:

```text
true
```

So the business rule in this code is:

> Even if `now` equals the deadline, the period counts as expired.

This is a very important edge case.

In real projects the following difference must be chosen consciously:

```text
now > deadline
```

or:

```text
now >= deadline
```

This is not just a technical detail. It is a business decision.

That is why such edge cases must be pinned down with tests.

### Passing a clock function

In a bigger service the time source can be given as a function:

```go
type Clock func() time.Time
```

In production code:

```go
time.Now
```

is passed.

In a test, a function that always returns a predetermined time can be given.

For example:

```go
fixedNow := func() time.Time {
	return time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
}
```

The benefit is that the test does not depend on real time.

The result is the same every time.

In tests that work with timers, using a real `time.Sleep` is often not a good approach either.

For example:

```go
time.Sleep(2 * time.Second)
```

slows the test down.

Besides that, timing-dependent tests may be unstable in a heavily loaded CI environment.

Where possible, it is better to use approaches such as:

* signals;
* channels;
* a clock given as a dependency;
* a controllable timer abstraction.

## Common mistakes

The following mistakes are frequent when working with time.

* Thinking `time.Now()` always returns UTC.

  `time.Now()` uses the system's local `Location`.

  If UTC is definitely needed, write:

  ```go
  time.Now().UTC()
  ```

* Using `YYYY-MM-DD` in a layout.

  Go does not use the `YYYY`, `MM`, `DD` format symbols of many other languages.

  The correct Go layout:

  ```text
  2006-01-02
  ```

* Not checking the `time.Parse` error.

  External input may be in the wrong format or express a date that does not exist.

  That is why, after:

  ```go
  moment, err := time.Parse(...)
  ```

  check `err`.

* Parsing a zoneless string in the wrong zone.

  If a zoneless time must be interpreted as UTC:

  ```go
  time.Parse
  ```

  can be used.

  If it belongs to a certain local time zone:

  ```go
  time.ParseInLocation
  ```

  may be needed.

* Treating offset and `Location` as the same.

  ```text
  +05:00
  ```

  only denotes a shift from UTC.

  ```text
  Asia/Tashkent
  ```

  relies on the region rules in the zoneinfo database.

* Assuming a calendar day is always 24 hours.

  For "exactly 24 hours":

  ```go
  Add(24 * time.Hour)
  ```

  and for "the next calendar day":

  ```go
  AddDate(0, 0, 1)
  ```

  may be needed.

* Comparing points in time through formatted strings.

  For example:

  ```go
  a.Format(...) == b.Format(...)
  ```

  is not a good approach for checking time equality.

  Use the `Before`, `After` and `Equal` methods.

* Comparing `time.Time` with `==` for time equality.

  `==` may also take other parts of the internal representation into account.

  For equality of points in time, use:

  ```go
  a.Equal(b)
  ```

* Not stating the Unix timestamp unit.

  Write clearly in the API contract whether the timestamp is:

  ```text
  seconds
  ```

  or:

  ```text
  milliseconds
  ```

* Synchronizing goroutines with `time.Sleep`.

  `Sleep` does not guarantee:

  > "The goroutine will definitely finish within this time"

  Use a `WaitGroup`, a channel or another synchronization tool.

* Relying too much on `Sleep` in tests.

  Such tests become slow and timing-dependent.

* Thinking the monotonic value inside `time.Time` is kept in serialization.

  Monotonic clock data is used for duration calculations inside a process.

  It is not kept in JSON, ordinary formatting or transfer between services.

## What is looked at in interviews?

In questions about date and time in Go, knowing only `time.Now()` is often not enough.

It is important to understand the following differences:

* A Go layout works based on a special reference time:

  ```text
  Mon Jan 2 15:04:05 MST 2006
  ```

  For example, the standard date layout:

  ```text
  2006-01-02
  ```

* `time.Time` and `time.Duration` express different concepts.

  `time.Time`:

  > an exact point on the timeline.

  `time.Duration`:

  > the duration between two times.

* You should know the difference between `time.Parse` and `time.ParseInLocation`.

  If `time.Parse` parses a zoneless value, the time is created in UTC.

  `time.ParseInLocation` interprets a zoneless value based on the given `Location`.

* `Add` and `AddDate` have different meanings.

  `Add` works with an exact duration.

  `AddDate` works with calendar years, months and days.

* The same point in time may come out with a different hour in different time zones.

  For example:

  ```text
  09:00 UTC
  ```

  and:

  ```text
  14:00 +05:00
  ```

  may be the same point in time.

* To check equality of points in time:

  ```go
  Equal
  ```

  should be used.

* `time.Now()` may also hold monotonic clock data.

  This data is useful in duration calculations like `Sub` and `Since`.

  But it is not passed to another system through formatting and serialization.

* In backend services, storing points in time in UTC and sending UTC or a format with an explicit offset between services is often convenient.

  When showing it to the user, it can be converted to their `Location`.

  But values that are only calendar dates, such as a birthday, should not be forcibly turned into a UTC point in time.
