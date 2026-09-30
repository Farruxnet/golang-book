# `context` basics

Go's `context.Context` helps manage long-running work. It mainly carries three kinds of information along the call chain:

* a signal to cancel the work;
* a `deadline` or `timeout`;
* small metadata values belonging to the request.

For example, an HTTP server received a request and accessed the database within that request. If the client drops the connection, the server no longer needs to wait for the database result. In this case the database operation can also be cancelled through `context`.

In the same way, if one goroutine starts another goroutine, it can tell it through `context` that the caller is no longer waiting for the result.

The important point is that `context` does not forcibly stop a goroutine. The running code must watch the `ctx.Done()` signal itself and finish its work when the signal arrives.

## The initial context

A new context chain usually starts from `context.Background()` or `context.TODO()`.

`context.Background()` is an empty root context that is never cancelled. It is often used:

* in the `main` function;
* in tests;
* at the top layer of a server;
* where no other parent context exists.

For example:

```go
ctx := context.Background()
```

This context itself has no `deadline`, cancellation signal or extra value. Later new contexts can be derived from it with `WithCancel`, `WithTimeout`, `WithDeadline` or `WithValue`.

`context.TODO()` is also practically an empty context. But its meaning is different. It is usually used in a temporary place where it is not yet clear which context should be passed.

For example, if you are gradually moving old code to work with `context`, you can use `context.TODO()` temporarily.

If a function takes a `context`, it is customary in Go code to give it as the first parameter:

```go
func LoadUser(ctx context.Context, id int64) error
```

In this line `ctx` is the first parameter. Then come the function's own arguments.

This order is widely used in the Go ecosystem. That is why a developer who sees the function immediately understands that it may work with cancellation or a `deadline`.

Storing a `Context` inside a struct is usually not recommended.

For example, you should avoid this approach:

```go
type Service struct {
	ctx context.Context
}
```

The reason is that a `context` is usually tied to the lifetime of a certain operation or request. A struct may live much longer than that. Storing a context inside a struct makes it unclear which request or operation it belongs to.

A better way is to pass the context to the needed method as a parameter:

```go
func (s *Service) LoadUser(ctx context.Context, id int64) error
```

Also, do not pass `nil` in place of a `context.Context`.

For example, instead of:

```go
LoadUser(nil, 10)
```

if no other suitable context exists, you should use:

```go
LoadUser(context.Background(), 10)
```

This ensures that `ctx.Done()`, `ctx.Err()` or other context methods can be called safely inside the function.

## Cancellation

Some work must be stopped when an explicit signal comes from outside. `context.WithCancel()` is used for this.

It creates a new child context from a parent context:

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel()
```

Two values are returned here:

* `ctx` — the new context;
* `cancel` — a function that cancels this context.

When `cancel()` is called, the channel obtained through `ctx.Done()` is closed.

For example, a worker function can watch for the signal like this:

```go
select {
case <-ctx.Done():
	return ctx.Err()
default:
}
```

`ctx.Done()` is not used as a channel that sends ordinary values. When the context is cancelled, this channel is closed. Closing the channel signals all watchers at the same time.

And `ctx.Err()` shows why the context ended.

If `cancel()` was called by hand:

```go
ctx.Err()
```

returns the following error:

```go
context.Canceled
```

There is an important difference here. `Done()` only gives the signal "the context has ended". To find out why it ended, `Err()` is used.

Calling `cancel()` through `defer` is widespread:

```go
ctx, cancel := context.WithCancel(parent)
defer cancel()
```

The reason is that the resources tied to the context are always cleaned up when they are no longer needed.

Even if the work finishes earlier for another reason, `defer cancel()` guarantees that `cancel()` is called when leaving the function.

## Timeout and deadline

`context` provides two main ways to work with a time limit:

* `WithTimeout`;
* `WithDeadline`.

A `timeout` says how long work may run starting from now.

For example:

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()
```

This context ends automatically after about two seconds.

The process can be pictured in simple form like this:

```text
context created
        |
        v
may work for 2 seconds
        |
        v
timeout expired
        |
        v
ctx.Done() closed
        |
        v
ctx.Err() == context.DeadlineExceeded
```

A `deadline`, on the other hand, is not a duration but an exact point in time.

For example:

```go
ctx, cancel := context.WithDeadline(parent, time.Now().Add(2*time.Second))
defer cancel()
```

In this example the deadline is set two seconds from now. As a result this code works very much like the earlier `WithTimeout` example.

The difference is in what meaning the API expresses.

If you need the rule:

> "Let this work run for at most two seconds"

`WithTimeout` is more natural.

If you need an exact time limit like:

> "This work must finish no later than 15:30"

`WithDeadline` fits.

When the time runs out, the `Done()` channel is closed.

After that:

```go
ctx.Err()
```

returns:

```go
context.DeadlineExceeded
```

This value differs from `context.Canceled`.

`context.Canceled` usually means the context was cancelled from outside.

`context.DeadlineExceeded` means the set time limit has expired.

Even if the work finishes before the deadline, `cancel()` must be called:

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()
```

The reason is not only cancellation. `WithTimeout` and `WithDeadline` may manage an internal timer and other resources. If `cancel()` is called, they can be released earlier without waiting for the deadline.

## A cancellable worker function

The following program shows how a timeout and `ctx.Done()` work together:

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func work(ctx context.Context) error {
	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()

	for step := 1; step <= 10; step++ {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			fmt.Println("Step:", step)
		}
	}
	return nil
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 250*time.Millisecond)
	defer cancel()

	if err := work(ctx); err != nil {
		fmt.Println("The work ended:", err)
	}
}
```

In this example `work()` tries to perform 10 steps.

A `ticker` is created to wait `100ms` between each step:

```go
ticker := time.NewTicker(100 * time.Millisecond)
defer ticker.Stop()
```

`time.NewTicker()` sends a signal to the `ticker.C` channel every `100ms`.

`ticker.Stop()` stops the ticker when the function finishes. Calling it with `defer` is needed so the ticker's resources do not keep working unnecessarily.

Then the loop starts:

```go
for step := 1; step <= 10; step++ {
```

Theoretically the function should perform 10 steps.

But on each iteration `select` waits for one of two events:

```go
select {
case <-ctx.Done():
	return ctx.Err()
case <-ticker.C:
	fmt.Println("Step:", step)
}
```

The first `case`:

```go
case <-ctx.Done():
	return ctx.Err()
```

waits for the context to end.

If the timeout expires or the context is cancelled by hand, `ctx.Done()` is closed. Then the function immediately returns with `ctx.Err()`.

The second `case`:

```go
case <-ticker.C:
	fmt.Println("Step:", step)
```

waits for the next `100ms` interval. When the signal arrives, the next step is printed.

Inside `main()` a `250ms` timeout is given for the context:

```go
ctx, cancel := context.WithTimeout(context.Background(), 250*time.Millisecond)
defer cancel()
```

Looking at the approximate timeline of the work:

```text
0ms
context created

100ms
Step: 1

200ms
Step: 2

250ms
context timed out
ctx.Done() closed
work() finished with ctx.Err()
```

That is why the function usually does not perform all 10 steps.

If `work()` returns an error, `main()` prints it:

```go
if err := work(ctx); err != nil {
	fmt.Println("The work ended:", err)
}
```

Because of the timeout, a result roughly like this is printed:

```text
Step: 1
Step: 2
The work ended: context deadline exceeded
```

Because of exact scheduling, in cases very close to the time limit it is not guaranteed which `select` branch is chosen. But the main goal of this example does not change: the worker function watches the cancellation signal together with the timer.

This pattern is especially useful:

* in HTTP requests;
* in database queries;
* in external API calls;
* in background workers;
* in long-running loops.

The important rule is that creating a context by itself does not stop the work automatically. Code like `work()` must check `ctx.Done()`.

## When is `WithValue()` used?

`context.WithValue()` is used to pass small, request-scoped values along the context chain.

For example:

* a request ID;
* a trace ID;
* authentication-related data;
* metadata that should travel with the request.

It is used like this:

```go
ctx := context.WithValue(parent, key, value)
```

Then code in a lower layer can get the value:

```go
value := ctx.Value(key)
```

But `WithValue()` is not a universal replacement for an ordinary function parameter.

For example, if `userID` is mandatory for the function, writing it like this is usually better:

```go
func LoadUser(ctx context.Context, userID int64) error
```

Hiding `userID` inside the context:

```go
func LoadUser(ctx context.Context) error
```

and then getting it inside through `ctx.Value()` makes the API less clear.

In the same way, putting configuration or mandatory dependencies inside the context is not recommended.

For example, if a database connection:

```go
*sql.DB
```

or a logger is a permanent dependency of the service, giving it through a struct or an explicit parameter is usually more correct.

`WithValue()` is meant more for extra metadata that travels along with the request flow.

There is another important issue when working with context keys: keys can collide.

For example, if two packages use the same string key:

```go
"requestID"
```

they may accidentally see each other's values.

That is why creating a separate, unexported type inside the package is good practice:

```go
type contextKey string

const requestIDKey contextKey = "requestID"
```

Then the value is written:

```go
ctx := context.WithValue(parent, requestIDKey, "abc-123")
```

And read:

```go
requestID, ok := ctx.Value(requestIDKey).(string)
if !ok {
	// the value is missing or not of the expected type
}
```

A type assertion is used here:

```go
.(string)
```

`ctx.Value()` returns `any`. That is why you must check that the value obtained really is a `string`.

A blind type assertion without checking `ok` can be dangerous.

For example:

```go
requestID := ctx.Value(requestIDKey).(string)
```

if the value is missing or of another type, a panic happens at runtime.

The safer variant:

```go
requestID, ok := ctx.Value(requestIDKey).(string)
if !ok {
	// the value was not found or is of the wrong type
}
```

That is why two rules matter when working with `WithValue()`:

* put only request-scoped metadata inside the context;
* when reading a value, check that it exists and has the right type.
