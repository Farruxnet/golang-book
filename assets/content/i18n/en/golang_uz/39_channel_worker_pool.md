# Worker pool

A worker pool is a way of doing many tasks with a limited number of worker goroutines.

In this approach not all tasks are started in separate goroutines at once. Instead, a number of worker goroutines known in advance is created. Tasks are put into a queue. Whichever worker becomes free takes the next task.

For example, suppose 1000 files need to be processed. In the simplest variant, one goroutine can be created for each file. But this is not always a good solution.

If too many goroutines start working at the same time:

* too many files may be opened at once;
* memory usage may grow;
* the database connection pool limit may run out;
* an external API's rate limit may be exceeded;
* excessive load may fall on the server or another external resource.

A worker pool limits how many tasks run at the same time.

For example, if there are 1000 tasks but only 10 workers running, at most 10 tasks run at a time. When a worker finishes one, it takes the next task.

You can picture this as a taxi service. Customers are the tasks to be done. Drivers are the workers.

There may be more customers than drivers. But one driver serves only one customer at a time. When a driver becomes free, they take the next customer.

The main idea of a worker pool is exactly the same.

## The main parts of the structure

A simple worker pool usually consists of four main parts:

* the producer creates tasks and sends them to the `jobs` channel;
* several workers take tasks from the `jobs` channel;
* the workers send the results of their work to the `results` channel;
* the coordinator waits for all workers to finish and closes the `results` channel.

Let's look at the job of each part separately.

The **producer** creates new work. For example, file names, URLs, database records or values to be computed can be sent to the `jobs` channel by the producer.

A **worker** takes one task from the `jobs` channel, does it and, if needed, sends the result to the `results` channel.

The **coordinator** tracks when all workers have finished. `sync.WaitGroup` is often used for this.

Who closes the channel also matters here.

The `jobs` channel should be closed by the side that knows for sure no more tasks will be sent. Usually this is the producer.

The `results` channel should be closed by the side that knows for sure all workers have finished. Usually this is the coordinator waiting on the `WaitGroup`.

Individual workers should not try to close the `results` channel themselves.

The reason is that after one worker closes the channel, another worker may still try to send a result:

```go
results <- result
```

And sending to a closed channel causes a panic:

```text
send on closed channel
```

That is why in a worker pool the owner of each channel and the closing order must be clear in advance.

## The first working example

In the following example there are 5 jobs and 3 workers:

```go
package main

import (
	"fmt"
	"sync"
)

type Result struct {
	JobID  int
	Worker int
	Value  int
}

func worker(id int, jobs <-chan int, results chan<- Result, wg *sync.WaitGroup) {
	defer wg.Done()

	for job := range jobs {
		results <- Result{
			JobID:  job,
			Worker: id,
			Value:  job * 2,
		}
	}
}

func main() {
	const jobCount = 5
	const workerCount = 3

	jobs := make(chan int, jobCount)
	results := make(chan Result, jobCount)

	var wg sync.WaitGroup
	wg.Add(workerCount)

	for id := 1; id <= workerCount; id++ {
		go worker(id, jobs, results, &wg)
	}

	go func() {
		for job := 1; job <= jobCount; job++ {
			jobs <- job
		}
		close(jobs)
	}()

	go func() {
		wg.Wait()
		close(results)
	}()

	for result := range results {
		fmt.Printf(
			"job=%d worker=%d result=%d\n",
			result.JobID,
			result.Worker,
			result.Value,
		)
	}
}
```

A possible output:

```text
job=1 worker=1 result=2
job=2 worker=2 result=4
job=3 worker=3 result=6
job=4 worker=1 result=8
job=5 worker=2 result=10
```

This output is only one of the possible variants.

The workers run concurrently. That is why which worker takes which job is not known in advance.

For example, another run may produce output like this:

```text
job=2 worker=2 result=4
job=1 worker=1 result=2
job=4 worker=2 result=8
job=3 worker=3 result=6
job=5 worker=1 result=10
```

This is not a bug.

What matters is not the order of the results. The important guarantee is that every job sent to the `jobs` channel is taken by one worker and, if there is no other error in the worker code, its result is sent to the `results` channel.

Now let's look at the main parts of the code.

### Directional channels

The signature of the worker function:

```go
func worker(
	id int,
	jobs <-chan int,
	results chan<- Result,
	wg *sync.WaitGroup,
)
```

Here:

```go
jobs <-chan int
```

means the `jobs` channel can only be read from.

The worker can do:

```go
job := <-jobs
```

But it cannot do:

```go
jobs <- 10
```

Because `jobs` is a receive-only channel for the worker.

The results channel is given in the form:

```go
results chan<- Result
```

This is a send-only channel. The worker can send values to it:

```go
results <- result
```

But it cannot read values from it.

Directional channels are useful not for runtime optimization, but for API and compile-time safety.

What a function can do with which channel is visible from its signature. If the worker accidentally does something wrong, the compiler catches the error.

### The worker's loop

Inside the worker:

```go
for job := range jobs {
	// ...
}
```

is used.

`range` over a channel means receiving values until the channel is closed.

When the producer does:

```go
close(jobs)
```

the worker does not leave the loop immediately.

If there are still tasks in the channel buffer, they are taken first. Once the buffer is empty and it is certain no other value will come, `range` finishes.

So the old values in a closed channel are not lost.

### Why is a `WaitGroup` needed?

At the start of each worker we wrote:

```go
defer wg.Done()
```

And `main`, before starting the workers, calls:

```go
wg.Add(workerCount)
```

If `workerCount == 3`, the `WaitGroup` counter is set to 3.

When each worker finishes:

```go
wg.Done()
```

decreases the counter by one.

The process is as follows:

```text
Start:
WaitGroup = 3

worker 1 finished:
WaitGroup = 2

worker 2 finished:
WaitGroup = 1

worker 3 finished:
WaitGroup = 0
```

`wg.Wait()` waits until the counter becomes `0`.

The coordinator, through:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

waits for all workers to finish.

Only after that is:

```go
close(results)
```

done.

This is very important. Because if the `results` channel is closed while workers are still sending values to it, a `send on closed channel` panic occurs.

### Receiving the results

`main` collects the results with the following loop:

```go
for result := range results {
	fmt.Printf(
		"job=%d worker=%d result=%d\n",
		result.JobID,
		result.Worker,
		result.Value,
	)
}
```

This loop runs until the `results` channel is closed.

The flow is as follows:

```text
producer
   |
   v
jobs
   |
   +------> worker 1 ----+
   +------> worker 2 ----+----> results ----> main
   +------> worker 3 ----+
              |
              v
          WaitGroup
              |
              v
       close(results)
```

This flow prevents several common problems:

* workers do not wait forever on the `jobs` channel;
* `results` is not closed before the workers finish;
* `main` leaves the `range` loop once the channel is closed;
* workers do not get stuck because results are left unreceived.

## Buffers and backpressure

In the example above the channels are created like this:

```go
jobs := make(chan int, jobCount)
results := make(chan Result, jobCount)
```

If `jobCount == 5`, both channels can hold 5 values.

In a small example this makes the code easier to understand. But in a real project creating a very large buffer that can fit all tasks is not always good.

For example, if a million tasks may come into the system:

```go
jobs := make(chan Job, 1_000_000)
```

can lead to keeping a huge queue in memory.

If the workers cannot keep up with the tasks, the queue grows even more.

That is why a buffer is often of limited size.

For example:

```go
jobs := make(chan Job, 100)
```

In this case the producer can put up to 100 tasks in the queue. When the buffer is full, the next send blocks:

```go
jobs <- job
```

The producer waits on this line until one of the workers takes a value from the channel.

This is called **backpressure**.

Put simply, if the consumers cannot do the tasks fast enough, the producer is also forced to slow down.

This is a very useful property.

Otherwise the producer could create new work at unlimited speed and pile it up in memory.

### Unbuffered channel

If you write:

```go
jobs := make(chan Job)
```

the channel is unbuffered.

When the producer does:

```go
jobs <- job
```

the send does not complete until a worker is ready to receive the value.

That is, the producer and the worker synchronize directly.

### Buffered channel

If you write:

```go
jobs := make(chan Job, 100)
```

the producer can continue as long as there is free space in the buffer, even if no worker takes the value right away.

For example:

```text
buffer capacity = 3

producer -> job1
producer -> job2
producer -> job3
```

Now the buffer is full.

If the producer wants to send `job4`:

```text
producer -> job4
```

the producer blocks until a worker takes at least one earlier job from the channel.

### The buffer size does not have to equal the number of workers

For example, if there are 10 workers:

```go
const workerCount = 10
```

the channel buffer does not have to be exactly `10` either.

All of the following variants are technically possible:

```go
jobs := make(chan Job)
```

```go
jobs := make(chan Job, 10)
```

```go
jobs := make(chan Job, 100)
```

```go
jobs := make(chan Job, 1000)
```

Which value is right cannot be determined just from the number of workers.

When choosing the buffer size, you should take into account:

* how fast tasks arrive;
* how long one task takes;
* whether there are temporary load spikes;
* how much work can be held in the queue;
* how much memory may be used;
* whether it is acceptable for an old task to wait long in the queue.

So the number of workers controls concurrency. The channel buffer controls the queue capacity.

These two are not the same concept.

## Handling errors and cancellation

In a real system not every task finishes successfully.

For example:

* an HTTP request may return an error;
* a file may fail to open;
* a database query may fail;
* an input value may be invalid.

That is why it helps to pass the error together with the value inside the result.

For example:

```go
type Result struct {
	JobID int
	Value int
	Err   error
}
```

This struct stores three important parts of a result:

* `JobID` — which job was done;
* `Value` — the successful result;
* `Err` — the error that occurred during execution.

In some systems the remaining tasks must continue even if one job fails.

In other systems the whole pool must be stopped after the first serious error.

In the second case `context.Context` helps.

The following example cancels the worker pool when a negative value is encountered:

```go
package main

import (
	"context"
	"errors"
	"fmt"
	"sync"
)

type Job struct {
	ID    int
	Value int
}

type Result struct {
	JobID int
	Value int
	Err   error
}

func process(job Job) (int, error) {
	if job.Value < 0 {
		return 0, errors.New("negative values are not allowed")
	}

	return job.Value * job.Value, nil
}

func worker(
	ctx context.Context,
	jobs <-chan Job,
	results chan<- Result,
	wg *sync.WaitGroup,
) {
	defer wg.Done()

	for {
		select {
		case <-ctx.Done():
			return

		case job, ok := <-jobs:
			if !ok {
				return
			}

			value, err := process(job)

			result := Result{
				JobID: job.ID,
				Value: value,
				Err:   err,
			}

			select {
			case results <- result:
			case <-ctx.Done():
				return
			}
		}
	}
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	jobs := make(chan Job)
	results := make(chan Result)

	var wg sync.WaitGroup

	const workerCount = 2

	wg.Add(workerCount)

	for id := 1; id <= workerCount; id++ {
		go worker(ctx, jobs, results, &wg)
	}

	go func() {
		defer close(jobs)

		input := []int{2, 3, -1, 4, 5}

		for id, value := range input {
			select {
			case jobs <- Job{
				ID:    id + 1,
				Value: value,
			}:
			case <-ctx.Done():
				return
			}
		}
	}()

	go func() {
		wg.Wait()
		close(results)
	}()

	for result := range results {
		if result.Err != nil {
			fmt.Printf(
				"job=%d error: %v\n",
				result.JobID,
				result.Err,
			)

			cancel()
			continue
		}

		fmt.Printf(
			"job=%d result=%d\n",
			result.JobID,
			result.Value,
		)
	}
}
```

The order of the output is not guaranteed in advance.

For example, the following error definitely occurs:

```text
job=3 error: negative values are not allowed
```

But which other results are printed before or after this error depends on scheduling.

For example, it may look like this:

```text
job=1 result=4
job=2 result=9
job=3 error: negative values are not allowed
```

Or, if another worker has already managed to take job `4`, its result may be printed too.

### How does a worker watch for cancellation?

Inside the worker there is:

```go
select {
case <-ctx.Done():
	return

case job, ok := <-jobs:
	// ...
}
```

So the worker is waiting for two events at the same time:

* a new job arriving;
* the context being cancelled.

If:

```go
cancel()
```

is called, the `ctx.Done()` channel becomes ready.

The worker can receive the signal from it and:

```go
return
```

### Why is `ok` checked?

The channel is read like this:

```go
job, ok := <-jobs
```

If `jobs` is open and a value arrives:

```text
ok == true
```

If the channel is closed and no other values remain in it:

```text
ok == false
```

That is why:

```go
if !ok {
	return
}
```

tells the worker there is no more work.

### The context is also checked when sending a result

In the code the result is not simply sent with:

```go
results <- result
```

Instead:

```go
select {
case results <- result:
case <-ctx.Done():
	return
}
```

is used.

This matters.

Imagine the consumer has stopped receiving results. And `results` is unbuffered or its buffer is full.

If the worker is stuck on the line:

```go
results <- result
```

it blocks until the other side receives the result.

Even if the context has been cancelled, an ordinary send operation does not notice it automatically.

When `select` is used, the worker has two options:

* send the result;
* leave if the context has been cancelled.

That is why the cancellation signal should be checked not only while waiting on `jobs`, but in other potentially blocking places too.

### The producer also watches the context

The producer does:

```go
select {
case jobs <- Job{
	ID:    id + 1,
	Value: value,
}:
case <-ctx.Done():
	return
}
```

This is needed for the same reason.

If the workers have stopped because of cancellation, the producer must not wait forever on an ordinary:

```go
jobs <- job
```

line.

### `cancel()` does not stop everything immediately

There is an important subtlety here.

Context cancellation is a signal.

It is not a command that forcibly stops a running goroutine at the operating system level.

For example, let:

```go
value, err := process(job)
```

be called.

If `process` runs for a long time:

```go
func process(job Job) (int, error) {
	// 30 seconds of work
}
```

even if another goroutine did:

```go
cancel()
```

at that moment, `process` does not stop on its own.

If a long-running operation must also be cancelled, the `context` must be passed to it as well:

```go
func process(ctx context.Context, job Job) (int, error) {
	// check ctx.Done() in the necessary places
}
```

Methods that take a context in HTTP, database and many other standard APIs are used exactly for this purpose.

### The `select` choice is not deterministic either

If at the same time:

```go
ctx.Done()
```

is ready and the:

```go
jobs
```

channel also has a value, `select` chooses one of the ready cases.

That is why you cannot strictly guarantee that no new job starts after `cancel()` is called.

Some workers may already have managed to take a ready task.

It is more correct to understand cancellation as "stop as soon as possible".

## Preserving the order of results

A worker pool does not guarantee execution order.

For example, suppose the following jobs were sent:

```text
1
2
3
4
```

Job `1` may take 500 ms.

Job `2` may finish in 20 ms.

Then it is natural for the results to arrive in the order:

```text
2
1
```

This is exactly the benefit of concurrent execution: one slow job does not completely hold up the remaining jobs.

But sometimes the results must be returned exactly in input order.

In such a case each job can be given an index.

For example:

```go
ordered := make([]int, jobCount)

for result := range results {
	ordered[result.JobID-1] = result.Value
}
```

If:

```text
JobID = 1
```

then:

```go
ordered[0] = result.Value
```

is written.

If:

```text
JobID = 5
```

then:

```go
ordered[4] = result.Value
```

is written.

Results may come from the channel in any order, but inside the slice they are placed by their original index.

For example, let the results arrive like this:

```text
JobID=3 Value=30
JobID=1 Value=10
JobID=2 Value=20
```

After collecting:

```text
ordered[0] = 10
ordered[1] = 20
ordered[2] = 30
```

As a result the order:

```text
[10 20 30]
```

is restored.

This technique also has a drawback.

All results are kept in memory:

```go
ordered := make([]int, jobCount)
```

If there are millions of large results, this can require noticeable memory.

In such a situation a separate collector stage that restores the order may be needed.

For example, the collector keeps the next expected index. Future results that arrive before it are held in a limited temporary buffer.

If order is not required at all, processing a result as soon as it arrives is usually better.

This:

* uses less memory;
* lets the first result be processed sooner;
* reduces the need to wait for all jobs to finish.

## Choosing the number of workers

One of the most important questions in a worker pool is how many workers to create.

There is no universal number here.

The rule "the more workers, the faster the program runs" is wrong.

Many workers sometimes help. Sometimes, on the contrary, they slow the system down or overload external resources.

### CPU-bound work

A CPU-bound task spends most of its time computing.

For example:

* a big mathematical calculation;
* image processing;
* compression;
* hashing;
* encoding;
* parsing large amounts of data.

For such tasks, keeping the number of workers close to the available parallelism is often a good starting point.

Creating very many workers does not multiply the CPU.

On the contrary:

* scheduling overhead grows;
* goroutines wait in the queue more;
* cache efficiency may drop;
* context switching may increase.

That is why in CPU-bound work "a thousand workers" does not automatically mean "faster".

### I/O-bound work

I/O-bound tasks spend most of their time waiting for an external operation.

For example:

* an HTTP request;
* reading from disk;
* a database query;
* a network socket;
* an external service's response.

In such a case the number of workers can be larger than the number of CPUs.

The reason is that many goroutines are not using the CPU at the same time. Most of them wait for an I/O response.

For example, there may be 100 workers, but at any moment only a few of them may be doing real CPU work.

But this does not mean "the more, the better" either.

External system limits must be taken into account.

### Working with a database

For a database, the number of workers may be tied to the connection pool.

For example, if:

```text
worker = 100
DB max connections = 10
```

not all workers can run queries at the same time.

Most workers end up waiting for a connection.

Such a pool can sometimes increase useless queuing and timeouts.

### Working with an external API

An API may set the following limit:

```text
20 requests per second
```

If you start 500 workers, the program can internally send requests fast, but the external service may return:

```text
429 Too Many Requests
```

That is why the number of workers is chosen together with:

* the API rate limit;
* the server's recommended concurrency limit;
* the timeout;
* the retry strategy;
* the network bandwidth.

### The best value is measured

Choosing the number of workers only by theoretical guesses is not enough.

In practice you should watch indicators such as:

* benchmarks;
* profiling;
* latency metrics;
* throughput;
* CPU;
* memory;
* the number of connections;
* the error rate.

For example, you can try increasing the number of workers:

```text
10 -> 20 -> 50 -> 100
```

If throughput barely increases after `50` workers, but memory and latency get worse, adding more workers may be useless.

### When the number of workers is `0`

You should not forget this edge case.

For example, if:

```go
const workerCount = 0
```

no worker is created.

And the producer tries to do:

```go
jobs <- job
```

If no one reads the channel, the producer blocks.

That is why, when creating a general worker pool API, the condition:

```go
workerCount > 0
```

should be checked.

For example:

```go
if workerCount <= 0 {
	return errors.New("workerCount must be positive")
}
```

### A very large queue is also a problem

Even if concurrency is limited, the queue can be very large.

For example:

```text
worker = 10
jobs buffer = 1 000 000
```

This ensures only 10 jobs run at a time. But up to a million jobs may wait in the queue in memory.

As a result:

* a lot of memory is used;
* old tasks wait very long;
* jobs the user has cancelled may also stay in the queue;
* the system notices an overload late.

That is why the concurrency limit and the queue limit are managed separately.

## Panics and resource cleanup

In workers:

```go
defer wg.Done()
```

is often used.

This is good practice.

No matter which ordinary path the worker function exits through, such as:

```go
return
```

or the loop finishing, `wg.Done()` runs.

For example:

```go
func worker(wg *sync.WaitGroup) {
	defer wg.Done()

	// work
}
```

This helps avoid forgetting to decrease the `WaitGroup` counter.

But a panic is a separate issue.

If a panic occurs inside a worker and is not `recover`ed anywhere, usually the whole Go program stops.

For example:

```go
func worker() {
	panic("unexpected error")
}
```

An unrecovered panic in a goroutine does not just quietly end that goroutine. The runtime prints a stack trace and ends the process.

In some server or task-processing systems you may need to use `recover` at the worker boundary.

But simply swallowing a panic with:

```go
recover()
```

is not a good solution either.

When a panic happens, usually at least:

* logging the panic value;
* saving the stack trace;
* deciding whether to turn it into an error result;
* checking whether the system state is broken

is needed.

For example, if a worker wrote half of an operation and then panicked, simply retrying the job may also be dangerous.

### Every resource a job opens must be closed

Because workers do many tasks, a resource leak can grow quickly.

For example, each task opens a file:

```go
file, err := os.Open(name)
```

If the file is not closed, after many tasks the process may reach the file descriptor limit.

Or if an HTTP response:

```go
resp, err := client.Do(req)
```

is obtained, then where needed:

```go
resp.Body.Close()
```

must be done.

This also applies to database rows, transactions, sockets and other resources.

A worker pool manages concurrency. But it does not automatically clean up the resources inside the worker.

## Common mistakes

### Not closing the `jobs` channel

If a worker uses:

```go
for job := range jobs {
	// ...
}
```

it keeps waiting for new values until the channel is closed.

Even after the producer has sent all tasks, if it does not do:

```go
close(jobs)
```

the workers do not leave the loop.

As a result:

```go
wg.Wait()
```

may not finish either.

### Closing a channel from several workers

For example, if each worker at the end does:

```go
close(results)
```

this is wrong.

The first worker to finish closes the channel.

If the next worker does:

```go
results <- result
```

then:

```text
panic: send on closed channel
```

occurs.

The rule for closing a channel is simple:

> A channel should be closed by the side that knows for sure no more values will be sent.

In a channel with many senders, a single worker usually does not know this.

### Closing `results` before the workers finish

For example, the order:

```go
close(results)
wg.Wait()
```

is wrong.

The correct order:

```go
wg.Wait()
close(results)
```

First all sending workers finish. Then the channel is closed.

### No one receiving the results

Imagine there is:

```go
results := make(chan Result, 10)
```

The workers are sending results, but no one does:

```go
<-results
```

The first 10 values may go into the buffer.

The next worker blocks on the line:

```go
results <- result
```

Because the worker does not finish:

```go
wg.Done()
```

is not called either.

And the coordinator waits on the line:

```go
wg.Wait()
```

This way a deadlock-like situation arises.

### Assuming results arrive in input order

Concurrent workers do not run at the same speed.

That is why, if:

```text
job1
job2
job3
```

were sent, the results may arrive in the order:

```text
job2
job3
job1
```

If order is required, it must be restored separately.

### Creating more uncontrolled goroutines for every job

For example, suppose 10 workers were created to limit concurrency to `10`.

But if inside the worker you do:

```go
for job := range jobs {
	go process(job)
}
```

the pool's limit is effectively broken.

The worker itself may quickly take all the tasks and create a new goroutine for each.

As a result, even if:

```text
workerCount = 10
```

hundreds or thousands of `process` goroutines may run at the same time.

If inner goroutines are also needed, there must be separate concurrency control for them.

### Calling `WaitGroup.Add` after the goroutine starts

The following order should be avoided:

```go
go worker(&wg)
wg.Add(1)
```

The worker may finish very quickly and call:

```go
wg.Done()
```

before `Add`.

That is why the counter is increased before the goroutine is started:

```go
wg.Add(1)
go worker(&wg)
```

For many workers, the form:

```go
wg.Add(workerCount)

for i := 0; i < workerCount; i++ {
	go worker(&wg)
}
```

is clear and safe.

### Copying a used `WaitGroup`

A `sync.WaitGroup` must not be copied after its first use.

For example, passing it to a function by value leads to a wrong design:

```go
func worker(wg sync.WaitGroup) {
	// ...
}
```

Here the worker may work with a copy of the `WaitGroup`.

Usually a pointer is passed:

```go
func worker(wg *sync.WaitGroup) {
	defer wg.Done()
}
```

That is why the worker pool examples above also use:

```go
wg *sync.WaitGroup
```

## Important points for interviews

When asked about worker pools, you should clearly distinguish several concepts from each other.

First, a worker pool controls concurrency.

For example, with:

```text
1000 jobs
10 workers
```

the worker pool ensures that at most about 10 workers' worth of work runs at a time.

The channel buffer controls something else.

For example, with:

```text
10 workers
a buffer of 100
```

10 jobs may be running while up to 100 more jobs wait in the channel queue.

So:

```text
number of workers != queue size
```

Second, closing a channel does not delete the values.

If, while the buffer holds:

```text
job1
job2
job3
```

you do:

```go
close(jobs)
```

the receivers can take these values first.

Only after the buffer runs out does the receive operation:

```go
value, ok := <-jobs
```

give:

```text
ok == false
```

Third, a worker pool does not guarantee the order of results.

In concurrent execution, the result of a job that finishes quickly arrives first.

Fourth, `sync.WaitGroup` only waits for goroutines to finish.

It does not:

* pass errors;
* create a context;
* send a cancellation signal;
* close channels automatically;
* handle panics.

Separate mechanisms are needed for these jobs.

Fifth, checking for cancellation only at the start of the worker is not enough.

If the producer can block while sending, it must also watch the context.

If the worker can block while sending a result, the context must be checked there too.

If `process` takes a long time, it must also understand the cancellation signal.

That is why a complete cancellation flow looks roughly like this:

```text
cancel()
   |
   v
context
   |
   +----> the producer stops
   |
   +----> a worker waiting on jobs stops
   |
   +----> a worker sending a result stops
   |
   +----> a long process that accepts the context may also stop
```

When writing a reliable worker pool, just creating worker goroutines is not enough. The task queue, channel ownership, the closing order, receiving results, backpressure, errors, cancellation and external resource limits are all considered together.
