# Goroutines and Channels

A **goroutine** is a lightweight thread managed by the Go runtime. Start one with the `go` keyword.

```go
go fmt.Println("running concurrently")
```

## Channels

Channels let goroutines communicate safely.

```go
ch := make(chan int)

go func() {
    for i := range 3 {
        ch <- i
    }
    close(ch)
}()

for v := range ch {
    fmt.Println(v)
}
```

## WaitGroup

```go
var wg sync.WaitGroup
for i := range 5 {
    wg.Add(1)
    go func() {
        defer wg.Done()
        fmt.Println("worker", i)
    }()
}
wg.Wait()
```

## select

```go
select {
case msg := <-messages:
    fmt.Println(msg)
case <-time.After(time.Second):
    fmt.Println("timeout")
}
```

> **Go proverb:** "Don't communicate by sharing memory; share memory by communicating."

## Check yourself

```quiz
What happens when you send on an unbuffered channel with no receiver?
- The value is dropped
+ The sender blocks until someone receives
- The program panics immediately
- The value is queued
> Unbuffered channels synchronize the sender and the receiver.
```

```quiz
What is `sync.WaitGroup` used for?
- Limiting CPU usage
+ Waiting for a group of goroutines to finish
- Locking shared memory
- Scheduling goroutines in order
> Call `Add` before starting, `Done` when finished, `Wait` to block.
```
