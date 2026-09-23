# Project: REST API

Build a tiny JSON API with only the standard library (Go 1.22+ routing).

```go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "sync"
)

type Book struct {
    ID    string `json:"id"`
    Title string `json:"title"`
}

var (
    mu    sync.Mutex
    books = map[string]Book{}
)

func main() {
    mux := http.NewServeMux()

    mux.HandleFunc("GET /books", func(w http.ResponseWriter, r *http.Request) {
        mu.Lock()
        defer mu.Unlock()
        list := make([]Book, 0, len(books))
        for _, b := range books {
            list = append(list, b)
        }
        json.NewEncoder(w).Encode(list)
    })

    mux.HandleFunc("POST /books", func(w http.ResponseWriter, r *http.Request) {
        var b Book
        if err := json.NewDecoder(r.Body).Decode(&b); err != nil {
            http.Error(w, err.Error(), http.StatusBadRequest)
            return
        }
        mu.Lock()
        books[b.ID] = b
        mu.Unlock()
        w.WriteHeader(http.StatusCreated)
    })

    log.Println("listening on :8080")
    log.Fatal(http.ListenAndServe(":8080", mux))
}
```

## Try it

```bash
curl -X POST localhost:8080/books -d '{"id":"1","title":"The Go Programming Language"}'
curl localhost:8080/books
```

## Challenges

- Add `GET /books/{id}` using `r.PathValue("id")`.
- Add `DELETE /books/{id}`.
- Write tests with `net/http/httptest`.
