# Mutex

A mutex is a synchronization tool that controls access to shared data when several goroutines work with the same data.

In Go a mutex is used through the `sync.Mutex` type.

Put simply, a mutex creates a lock around data. When one goroutine takes the lock, the other goroutines wait until that lock is released.

For example, if two goroutines want to change the same `counter` value at the same time, a mutex can make their write operations run one after another.

If several goroutines only read the same data, there is usually no problem. But if at least one of them writes to that memory location, the accesses must be coordinated.

Otherwise:

* the value may come out wrong;
* one write may overwrite another;
* a data race may occur.

Let's imagine a bank account.

The account has `1000`. An ATM wants to withdraw `800`. At the same time a mobile app is also trying to withdraw `700`.

If both operations read the old balance at the same time, both may see the value:

```text
Balance = 1000
```

The ATM checks:

```text
1000 >= 800
```

And the mobile app checks:

```text
1000 >= 700
```

Each check is correct on its own. But the total money in the account is not enough to perform both withdrawals.

That is why checking the balance and subtracting money from it must be done not separately, but as one protected logical operation.

A mutex is used exactly in such situations.

## Data race and race condition

A **data race** occurs when several goroutines access the same memory location without sufficient synchronization and at least one of the accesses is a write. A **race condition** is a broader logical problem where the program's result wrongly depends on the order of operations.

A mutex helps prevent data races that come from concurrent access to shared memory. For this, all code that accesses that data must follow the same mutex and the same locking rule.

The definition of a data race, the `-race` command and the detector's limitations are explained in detail in the Race detector lesson.

## Why is `counter++` not safe?

The following code looks very simple:

```go
counter++
```

In the source code it is a single line.

But from the concurrent programming point of view, it cannot automatically be considered an atomic operation.

Logically `counter++` consists of three steps:

1. reading the value of `counter`;
2. increasing the value by `1`;
3. writing the new value to memory.

For example, let the initial value be:

```text
counter = 10
```

If two goroutines run at the same time, the following may happen:

```text
Goroutine A: reads counter -> 10
Goroutine B: reads counter -> 10

Goroutine A: 10 + 1 -> 11
Goroutine B: 10 + 1 -> 11

Goroutine A: counter = 11
Goroutine B: counter = 11
```

Two increments were done. But the final value turned out to be:

```text
11
```

And the expected result was:

```text
12
```

So one of the increments got lost.

The following program is deliberately written wrong:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	counter := 0

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			counter++ // Wrong: the shared value is not protected.
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

Here `1000` goroutines are created.

Each goroutine performs:

```go
counter++
```

Theoretically the result should be:

```text
0 + 1000 = 1000
```

But `counter` is a shared variable. All goroutines write to the same memory location.

That is why the result may sometimes be:

```text
Counter: 1000
```

On another run it may be, for example:

```text
Counter: 987
```

or another value.

The important point is that getting `1000` once does not prove the code is safe.

The real execution order of concurrent code is affected by:

* the Go scheduler;
* the number of CPU cores;
* the operating system scheduler;
* the work of other goroutines;
* optimizations;
* the overall load at the time the program runs.

That is why code with a data race may sometimes seem to work "correctly".

Such code can be checked with `go run -race main.go`. The command and interpreting its result are covered separately in the Race detector lesson, and performance measurement in the Benchmark lesson.

## How is a `Mutex` used?

`sync.Mutex` has two main methods:

* `Lock()` — take the lock;
* `Unlock()` — release the lock that was taken.

The simple form:

```go
mu.Lock()

// Protected code.

mu.Unlock()
```

If the mutex is free when `Lock()` is called, the goroutine takes the lock and continues working.

If the lock is held by another goroutine, the new goroutine waits inside `Lock()`.

After the lock is released, one of the waiting goroutines can continue.

The code between `Lock()` and `Unlock()` is called the **critical section**.

For example:

```go
mu.Lock()
counter++
mu.Unlock()
```

Here only the operation:

```go
counter++
```

is protected by the mutex.

As a result, only one goroutine at a time can be inside this critical section.

### The zero value of `Mutex`

Using `sync.Mutex` does not need a separate constructor.

The following code alone is enough:

```go
var mu sync.Mutex
```

The zero value of `sync.Mutex` is a mutex ready to use.

That is why, for example, there is no need to write:

```go
mu := NewMutex()
```

The Go standard library does not even have such a constructor for `sync.Mutex`.

Now let's fix the earlier counter example with a mutex:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var (
		wg      sync.WaitGroup
		mu      sync.Mutex
		counter int
	)

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()

			mu.Lock()
			counter++
			mu.Unlock()
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

Output:

```text
Counter: 1000
```

Now each goroutine calls:

```go
mu.Lock()
```

before increasing `counter`.

If another goroutine is changing `counter` at the moment, the new goroutine waits.

Only after the first goroutine does:

```go
mu.Unlock()
```

can another goroutine enter the critical section.

As a result the increments do not overlap each other.

In this example `WaitGroup` and `Mutex` are used together. But they do different jobs.

`WaitGroup`, through:

```go
wg.Wait()
```

makes the `main` function wait until all goroutines finish.

And `Mutex`, through:

```go
mu.Lock()
counter++
mu.Unlock()
```

protects the shared `counter` value.

So:

> `WaitGroup` waits for goroutines to finish. `Mutex` coordinates access to shared memory.

`WaitGroup` by itself does not protect `counter` from a data race.

In the same way, `Mutex` does not wait for all goroutines to finish.

## Releasing the lock with `defer`

In a simple case a mutex can be used like this:

```go
mu.Lock()
counter++
mu.Unlock()
```

But if there are several `return` paths inside the function, it is easy to forget `Unlock()`.

For example:

```go
mu.Lock()

if someCondition {
	return
}

mu.Unlock()
```

In this code, if `someCondition` is true, the function returns without reaching `Unlock()`.

As a result the mutex stays locked.

The next calls to:

```go
mu.Lock()
```

may get stuck waiting.

That is why in many cases `defer` is used right after the lock is taken:

```go
mu.Lock()
defer mu.Unlock()
```

Because of `defer`, `mu.Unlock()` is called automatically before the current function returns.

For example:

```go
func update() {
	mu.Lock()
	defer mu.Unlock()

	if someCondition {
		return
	}

	// Other work.
}
```

Here, no matter which `return` is used to exit, the mutex is released.

`defer` also runs during stack unwinding when a panic happens.

That is why:

```go
defer mu.Unlock()
```

also helps release the lock during a panic.

But this does not "cure" the panic.

If the panic is not recovered, the program may still stop after the deferred functions run.

**Warning**

Write `defer mu.Unlock()` only after `Lock()` has been called successfully.

For example:

```go
mu.Lock()
defer mu.Unlock()
```

is the correct order.

Calling:

```go
mu.Unlock()
```

on a mutex that was not locked leads to a runtime error.

In very small, very frequently called critical sections, `defer` may have a small extra cost.

In such a case, a direct `Unlock()` in the form:

```go
mu.Lock()
counter++
mu.Unlock()
```

may be slightly cheaper.

But a practical rule matters here:

> First make sure the code works correctly. Then check with a benchmark whether there is a performance problem.

Giving up `defer` based only on a guess can increase errors where `Unlock()` gets forgotten.

## Managing a bank account safely

Now let's look at a mutex in a more realistic example.

Keeping shared data and the mutex protecting it inside one type is considered good practice.

For example, a bank account:

```go
package main

import (
	"errors"
	"fmt"
	"sync"
)

var (
	errInvalidAmount     = errors.New("the amount must be positive")
	errInsufficientFunds = errors.New("insufficient funds in the account")
)

type Account struct {
	mu      sync.Mutex
	balance int
}

func NewAccount(initialBalance int) (*Account, error) {
	if initialBalance < 0 {
		return nil, errors.New("the initial balance cannot be negative")
	}

	return &Account{balance: initialBalance}, nil
}

func (a *Account) Withdraw(amount int) error {
	if amount <= 0 {
		return errInvalidAmount
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	if a.balance < amount {
		return errInsufficientFunds
	}

	a.balance -= amount
	return nil
}

func (a *Account) Balance() int {
	a.mu.Lock()
	defer a.mu.Unlock()

	return a.balance
}

func main() {
	account, err := NewAccount(1000)
	if err != nil {
		fmt.Println("The account was not created:", err)
		return
	}

	requests := []struct {
		name   string
		amount int
	}{
		{name: "ATM", amount: 800},
		{name: "Mobile app", amount: 700},
	}

	var wg sync.WaitGroup
	results := make([]error, len(requests))

	for i, request := range requests {
		wg.Add(1)
		go func(index int, amount int) {
			defer wg.Done()
			results[index] = account.Withdraw(amount)
		}(i, request.amount)
	}

	wg.Wait()

	for i, request := range requests {
		if results[i] != nil {
			fmt.Printf("%s: %v\n", request.name, results[i])
			continue
		}
		fmt.Printf("%s: withdrew %d\n", request.name, request.amount)
	}

	fmt.Println("Final balance:", account.Balance())
}
```

A possible output:

```text
ATM: withdrew 800
Mobile app: insufficient funds in the account
Final balance: 200
```

Let's go through this example step by step.

### The mutex inside `Account`

```go
type Account struct {
	mu      sync.Mutex
	balance int
}
```

`balance` is the shared state that several goroutines may use.

And `mu` protects this state.

Keeping the mutex right next to the field it protects makes it easier to understand which lock is used for which data.

### Checking the initial balance

```go
func NewAccount(initialBalance int) (*Account, error) {
	if initialBalance < 0 {
		return nil, errors.New("the initial balance cannot be negative")
	}

	return &Account{balance: initialBalance}, nil
}
```

Here an account is not allowed to be created with a negative balance.

This check runs before the object is used concurrently. That is why no mutex is needed here.

### A simple check inside `Withdraw`

```go
if amount <= 0 {
	return errInvalidAmount
}
```

`amount` is a local value that came into the function as an argument.

This check does not access the shared `balance` field of `Account`.

That is why it can be done before the mutex.

The benefit is that when an invalid `amount` comes in, there is no need to take the mutex at all.

This shortens the critical section.

### Protecting the balance

Then the lock is taken with:

```go
a.mu.Lock()
defer a.mu.Unlock()
```

The code after that:

```go
if a.balance < amount {
	return errInsufficientFunds
}

a.balance -= amount
```

runs inside one critical section.

This is very important.

Checking the balance:

```go
a.balance < amount
```

and decreasing the balance:

```go
a.balance -= amount
```

are related operations.

They must be treated as one logical operation.

For example, writing it like this can be wrong:

```go
if a.balance < amount {
	return errInsufficientFunds
}

a.mu.Lock()
a.balance -= amount
a.mu.Unlock()
```

The reason is that another goroutine may change the balance between the check and the write.

For example:

```text
Initial balance = 1000

Goroutine A checks:
1000 >= 800 -> yes

Goroutine B checks:
1000 >= 700 -> yes
```

Then both goroutines may try to withdraw money.

That is why the mutex must protect not only the line:

```go
a.balance -= amount
```

but the whole invariant.

The main invariant in this example:

> The account balance must not become negative as a result of a withdrawal.

That is why checking and changing the balance are done under one lock.

### Which request runs first?

Two goroutines are created:

```go
account.Withdraw(800)
```

and:

```go
account.Withdraw(700)
```

But which goroutine takes the mutex first is not guaranteed.

If the ATM is first:

```text
1000 - 800 = 200
```

Then the mobile app tries to withdraw `700`:

```text
200 < 700
```

so the operation is rejected.

The result:

```text
ATM: withdrew 800
Mobile app: insufficient funds in the account
Final balance: 200
```

If the mobile app runs first:

```text
1000 - 700 = 300
```

Then for the ATM:

```text
300 < 800
```

In such an execution the final balance is:

```text
300
```

So which operation succeeds depends on the scheduler order.

But in both cases the important invariant is kept:

* only one withdrawal succeeds;
* the balance does not become negative.

The mutex is used exactly to guarantee this.

### `Balance` also uses the mutex

```go
func (a *Account) Balance() int {
	a.mu.Lock()
	defer a.mu.Unlock()

	return a.balance
}
```

At first glance `Balance` only reads. That is why the question:

> Why is reading also locked?

may come up.

The reason is that another goroutine may at the same moment be writing to this value through:

```go
a.balance -= amount
```

An unprotected read at the same time as a write is also a data race.

That is why the general rule is:

> If data is protected by a mutex, all related reads and writes of it must follow the same synchronization rule.

### About the `results` slice

The code creates:

```go
results := make([]error, len(requests))
```

Then each goroutine writes only to its own index through:

```go
results[index] = account.Withdraw(amount)
```

For example:

```text
Goroutine 0 -> results[0]
Goroutine 1 -> results[1]
```

Even though the slice header is shared, its length or capacity is not being changed here.

Each goroutine writes to a separate element that already exists.

And `main` reads the results only after:

```go
wg.Wait()
```

That is why in this exact structure no separate mutex is needed for `results`.

## Keeping the mutex together with the data

A mutex is usually kept inside the same struct as the data it protects.

For example:

```go
type Cache struct {
	mu    sync.Mutex
	items map[string]string
}
```

From this structure the person reading the code can immediately understand:

```text
mu -> protects the items field
```

For example, the methods can be written like this:

```go
func (c *Cache) Set(key, value string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.items[key] = value
}
```

This approach clearly shows the owner of the lock.

### Why is a pointer receiver used?

Methods of a struct holding a mutex are usually written with a pointer receiver:

```go
func (c *Cache) Set(...)
```

The reason is not only changing `items`.

There is another important reason:

> A `sync.Mutex` must not be copied.

If a value receiver is used:

```go
func (c Cache) Set(...)
```

a copy of `Cache` may be created as the receiver.

Along with it, the:

```go
c.mu
```

mutex is also copied.

This is very dangerous.

For example, two goroutines seem to work with the same shared data. But they may be locking different copies of the mutex.

In such a case the lock does not coordinate real shared access.

That is why there is an important rule about `sync.Mutex`:

> A mutex must not be copied after its first use.

This is not only about receivers.

A struct with a mutex can also cause problems when:

* passed to a function by value;
* used through a value receiver;
* copied through assignment;
* moved into another struct by value.

For example:

```go
original := Cache{}
copy := original
```

if the mutex has already been used, such copying can lead to a wrong design.

`go vet` can detect some cases of copying a mutex:

```bash
go vet ./...
```

For this reason `go vet` is one of the useful checks when writing concurrent code.

## The memory guarantee of a mutex

A mutex is not just a mechanism that says:

> Let one goroutine in, let the other wait.

It also synchronizes memory visibility from the point of view of the Go memory model.

For example, one goroutine works like this:

```go
mu.Lock()
value = 42
mu.Unlock()
```

If later another goroutine takes the same mutex:

```go
mu.Lock()
fmt.Println(value)
mu.Unlock()
```

thanks to correct synchronization, the writes the previous goroutine made before releasing the lock are visible to the next goroutine.

Put simply:

> If one goroutine updates data under a mutex and then does `Unlock()`, another goroutine that later successfully does `Lock()` on the same mutex can see those updates.

The main conditions here are:

* the same mutex is used;
* the lock is taken correctly;
* this synchronization order is followed when accessing the data.

If one goroutine writes with `mu` and another reads without the mutex, it does not benefit from this guarantee.

## Keeping the critical section short

While a mutex is held, other goroutines cannot take that mutex.

For example, with:

```go
mu.Lock()

// Long-running work.

mu.Unlock()
```

other goroutines wait until this work finishes.

That is why the critical section should, as far as possible, contain only the code needed to check and change the shared state.

Be careful when doing the following slow or possibly blocking operations inside a lock:

* a network request;
* a database call;
* reading a file;
* writing a file;
* a long computation;
* a blocking send to a channel;
* calling an external callback;
* calling a method whose running time is unknown.

For example, code like:

```go
mu.Lock()

resp, err := http.Get(url)

mu.Unlock()
```

has a dangerous performance property.

An HTTP request can take:

* a few milliseconds;
* a few seconds;
* until the timeout.

During this time other goroutines cannot take `mu`.

As a result contention, that is, competition and waiting for one lock, increases.

In many cases a better approach is:

1. take the mutex;
2. read or copy the needed shared data;
3. release the mutex;
4. do the slow operation outside.

For example, conceptually:

```go
mu.Lock()
localValue := sharedValue
mu.Unlock()

doSlowOperation(localValue)
```

But this technique is not always correct.

If in the process:

```text
check -> long operation -> update
```

the shared state must not change in the middle, simply releasing the mutex early can break the business logic.

In such a case the algorithm may need to be redesigned.

That is why the main goal is:

> Hold the mutex as briefly as possible, but not at the cost of breaking the data invariant.

## Deadlock and re-locking

A **deadlock** is a situation where goroutines wait for a lock or signal from each other that never comes.

In such a situation some goroutines in the program can no longer move forward.

Two of the common causes of mutex-related deadlocks are:

* locking one mutex again;
* taking several mutexes in different orders.

### Locking one mutex again

Go's `sync.Mutex` is not a **reentrant** mutex.

A reentrant lock means a mechanism that allows the same execution owner to take a lock it has already taken again.

`sync.Mutex` does not work like this.

If a goroutine does:

```go
mu.Lock()
```

and then, without `Unlock()`, does again:

```go
mu.Lock()
```

the second `Lock()` waits for a free lock.

But the goroutine that must release the lock is itself.

As a result the goroutine ends up waiting for itself.

For example:

```go
// Wrong example: update takes the mu lock and calls the value method.
// value also tries to take the same mu lock.
func (s *Store) update() {
	s.mu.Lock()
	defer s.mu.Unlock()

	_ = s.value()
}
```

Imagine `value()` is also written like this:

```go
func (s *Store) value() int {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.someValue
}
```

The execution order:

```text
update()
    |
    +-- s.mu.Lock() -> lock taken
    |
    +-- s.value()
            |
            +-- s.mu.Lock() -> the same lock is requested again
```

But the mutex is still held by `update()`.

And `update()` waits for `value()` to finish.

And `value()` waits for the mutex to be released.

As a result: deadlock.

In such a case an internal helper method that does not require the lock is often extracted.

For example, a conceptual approach:

```go
func (s *Store) valueLocked() int {
	return s.someValue
}
```

This method does not take the mutex itself.

Its contract:

> The caller must already have taken the needed mutex.

And the outer method can work like:

```go
func (s *Store) value() int {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.valueLocked()
}
```

Then where the lock is taken is managed explicitly.

### Taking locks in different orders

If one operation needs to take several mutexes, another kind of deadlock can happen.

For example, there are two mutexes:

```text
muA
muB
```

The first goroutine takes them in the order:

```text
muA.Lock()
muB.Lock()
```

The second goroutine takes them in the order:

```text
muB.Lock()
muA.Lock()
```

A bad execution may look like this:

```text
Goroutine 1:
took muA

Goroutine 2:
took muB

Goroutine 1:
waiting for muB

Goroutine 2:
waiting for muA
```

Now:

* Goroutine 1 waits for `muB`;
* Goroutine 2 waits for `muA`.

But neither can release the lock it holds, because it is waiting to move to the next step.

This is a classic deadlock.

That is why, if several locks are used, all code must take them in the same global order.

For example, the rule may be:

```text
Always muA first, then muB.
```

It also helps to reduce, as far as possible, holding many mutexes at once in one operation.

`defer`:

```go
defer mu.Unlock()
```

protects against forgetting the lock.

But `defer` does not automatically fix a wrong locking order.

## `RWMutex`: separating reads and writes

Some data is read very often but changed rarely.

If an ordinary `sync.Mutex` is used, even two goroutines that only read wait for each other.

For example:

```text
Reader A -> Lock
Reader B -> waits
```

In fact, if both goroutines only read, it may be safe for them to run at the same time.

For such cases Go has `sync.RWMutex`.

`RWMutex` provides two kinds of locks.

For a writer:

```go
Lock()
Unlock()
```

For a reader:

```go
RLock()
RUnlock()
```

Several readers can hold `RLock()` at the same time.

A writer, on the other hand, requires exclusive access.

For example:

```go
package main

import (
	"fmt"
	"sync"
)

type Scores struct {
	mu     sync.RWMutex
	values map[string]int
}

func NewScores() *Scores {
	return &Scores{values: make(map[string]int)}
}

func (s *Scores) Set(name string, score int) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.values[name] = score
}

func (s *Scores) Get(name string) (int, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	score, ok := s.values[name]
	return score, ok
}

func main() {
	scores := NewScores()
	scores.Set("Ali", 95)

	score, ok := scores.Get("Ali")
	if !ok {
		fmt.Println("Result not found")
		return
	}

	fmt.Println("Ali:", score)
}
```

Output:

```text
Ali: 95
```

### Why does `Set` use `Lock`?

The `Set` method writes to the `map` through:

```go
s.values[name] = score
```

That is why it takes an exclusive lock:

```go
s.mu.Lock()
defer s.mu.Unlock()
```

While the writer is working, no other reader or writer can enter the protected part.

### Why does `Get` use `RLock`?

`Get` only reads through:

```go
score, ok := s.values[name]
```

That is why it uses:

```go
s.mu.RLock()
defer s.mu.RUnlock()
```

If there is no other writer, several `Get` calls can read at the same time.

This can be useful in systems with many concurrent reads.

### An ordinary `map` is not automatically safe for concurrent use

The ordinary Go:

```go
map[string]int
```

is not automatically safe for concurrent writes.

Also, one goroutine reading this map without a mutex while another goroutine writes to it can cause problems.

`RWMutex` coordinates these accesses.

### `RWMutex` is not always faster

`RWMutex` gives more capabilities. But this does not lead to the conclusion:

> `RWMutex` is always faster than `Mutex`.

`RWMutex` has its own management overhead.

If:

* the critical section is very short;
* the number of goroutines is small;
* writes happen often;
* the benefit of parallel reads is small,

an ordinary `Mutex` may give a better or at least the same result.

That is why `RWMutex` is usually considered in cases where:

* there are many concurrent reads;
* there are few writes.

The practical choice should be checked with a benchmark.

### There is no upgrade from `RLock` to `Lock`

There is another subtle point with `RWMutex`.

For example, the following idea may come up:

1. first read with `RLock()`;
2. if we find out a change is needed;
3. turn that lock into a `Lock()`.

Go's `sync.RWMutex` type does not support such an upgrade mechanism.

That is, while holding an `RLock`, you cannot directly promote it to a `Lock`.

If you do:

```go
RUnlock()
Lock()
```

another goroutine may change the shared state between these two operations.

That is why, if the decision to write depends on the current state of the data, usually:

1. an exclusive `Lock()` is taken;
2. the condition is checked again;
3. the change is made if needed.

An important rule:

> When the lock type changes, you should not assume the earlier check result is still correct.

## Mutex, channel or `atomic`?

Go concurrent programming has several synchronization tools.

For example:

* `sync.Mutex`;
* `sync.RWMutex`;
* channels;
* `sync/atomic`.

Their jobs may look similar, but their usage models differ.

### `sync.Mutex`

If several goroutines read or change a small shared state of one object, `sync.Mutex` is often the clearest choice.

For example:

```go
type Account struct {
	mu      sync.Mutex
	balance int
}
```

The problem here is:

> All goroutines access the same `balance` value.

That is why protecting this data with a lock is natural.

### `sync.RWMutex`

If:

* there are very many reads;
* there are few writes;
* concurrent reads give a real benefit,

`sync.RWMutex` can be useful.

But this choice is better made on the basis of measurement, not guesses.

### Channel

A channel is better suited to passing work or ownership of data between goroutines.

For example:

```text
worker -> result channel -> collector
```

In this model one goroutine produces data and another receives it.

But using a channel does not automatically make an object concurrent-safe.

For example, a pointer was sent through a channel:

```go
ch <- account
```

If afterwards several goroutines change the object through this `account` pointer, shared memory appears again.

In such a case separate synchronization may be needed.

So:

> Passing a pointer through a channel does not automatically protect the object the pointer points to.

### `sync/atomic`

`sync/atomic` is useful for atomic operations on simple individual values.

For example:

* a counter;
* a flag;
* a simple statistic value.

But `atomic` does not automatically protect an invariant that covers several related fields.

Let's take the bank account example.

We need:

1. to check that the balance is sufficient;
2. to decrease the balance.

These two operations are related.

Using just one atomic `Load` and then one atomic `Store` does not automatically solve the whole logical problem.

For such invariants a mutex often gives a much clearer and less error-prone design.

The main question when choosing a synchronization tool:

> How does the data flow, and which invariant must be protected?

Choosing only by the question "which tool is faster?" can be wrong.

## Common mistakes

When working with mutexes, beginners and even experienced developers often run into certain mistakes.

### Locking only writes and not reads

For example:

```go
func (s *Store) Set(v int) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.value = v
}

func (s *Store) Get() int {
	return s.value
}
```

`Set` is locked.

But `Get` reads without protection.

If `Set` and `Get` run at the same time, a concurrent read alongside a write can cause a data race.

That is why the rule for accessing the same shared data must be consistent.

### Using different mutexes for the same data

For example, if one goroutine does:

```go
muA.Lock()
shared++
muA.Unlock()
```

and another does:

```go
muB.Lock()
shared++
muB.Unlock()
```

the two mutexes are independent of each other.

Even if `muA` is locked, `muB` may be free.

So both goroutines can access `shared` at the same time.

The same synchronization mechanism must be used for the same data.

### Forgetting `Unlock()`

For example:

```go
mu.Lock()

if err != nil {
	return
}

mu.Unlock()
```

If `err != nil`, the mutex is not released.

As a result the next `Lock()` calls may wait for a long time or forever.

In many cases:

```go
mu.Lock()
defer mu.Unlock()
```

is safer.

### Calling `Unlock()` on a mutex that was not locked

`Unlock()` must be called only on a mutex that was successfully locked earlier.

Doing:

```go
mu.Unlock()
```

on a mutex that was not locked ends with a runtime error.

### Copying a struct with a mutex

A `sync.Mutex` must not be copied after its first use.

Copying a struct with a mutex by value can create a separate copy of the lock.

This leads to "protecting" the same shared data with different locks.

That is why using a pointer receiver is usually the right approach for such structs.

### Doing slow I/O inside a lock

For example:

```go
mu.Lock()
readFromDatabase()
mu.Unlock()
```

If the database query is slow, other goroutines wait a long time for the mutex.

This increases contention.

You should try to keep only the necessary code related to the shared state under the mutex.

### Taking one mutex again in the same goroutine

`sync.Mutex` is not reentrant.

That is why a situation like:

```go
mu.Lock()
mu.Lock()
```

can lead to waiting on itself.

This often happens when a method that has taken the lock calls another method that takes the same mutex again.

### Assuming `RWMutex` is always faster

`RWMutex` allows parallel reads.

But its management mechanism is more complex than an ordinary `Mutex`.

That is why the real benefit depends on the workload.

The choice should be checked with a benchmark.

### Thinking the race detector finds every problem

`-race` is a useful tool, but it does not replace a correct concurrent design. How the detector works and what it cannot detect are explained in detail in the Race detector lesson.

## What do interviews focus on?

In an interview on mutexes, the question may not be limited to:

> What do `Lock()` and `Unlock()` do?

It is important to understand the following subtle points.

### The zero value of `Mutex` is ready to use

The following alone is enough:

```go
var mu sync.Mutex
```

No separate constructor is needed.

### A `Mutex` must not be copied after its first use

This is especially important for structs that hold a mutex.

That is why such structs are often used through a pointer.

### The critical section should be as short as possible

The longer a lock is held, the longer other goroutines wait.

But shortening the critical section must not break the data invariant.

### `sync.Mutex` is not reentrant

If a goroutine does `Lock()` again on a mutex it already holds without `Unlock()`, it may end up waiting for itself.

### `sync.Mutex` does not track the owning goroutine

Picturing a mutex as "belonging to a certain goroutine" is not a complete model.

Go's `sync.Mutex` does not provide an ownership model through a goroutine identifier as reentrant locks do.

The code design must rely on clear rules about who takes the lock and where.

### `WaitGroup` and `Mutex` do different jobs

`WaitGroup` solves the problem:

```text
Have all goroutines finished?
```

`Mutex` solves the problem:

```text
Who may access shared memory at a given time?
```

They cannot be used in place of each other.

### `RWMutex` allows many readers

With `RLock()` several readers can work at the same time.

A writer, on the other hand, takes an exclusive lock through:

```go
Lock()
```

But `RWMutex` helps only if the workload suits it.

### Correct synchronization does not automatically solve all race conditions

A mutex can eliminate a data race.

But if the business logic is wrong, a race condition may remain.

For example, if a program wrongly relies on which of two correctly synchronized events comes first, there may be no data race.

But the result still depends on the execution order.

That is why in concurrent programming two things must be checked separately:

1. is the memory access technically safe;
2. does the business logic stay correct if the execution order changes.
