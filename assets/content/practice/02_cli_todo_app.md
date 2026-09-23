# Project: CLI Todo App

We'll build a command-line todo list that saves tasks to `todos.json`.

## Usage

```bash
todo add "Learn goroutines"
todo list
todo done 1
```

## Data model

```go
type Todo struct {
    ID   int    `json:"id"`
    Text string `json:"text"`
    Done bool   `json:"done"`
}
```

## Loading and saving

```go
func load(path string) ([]Todo, error) {
    data, err := os.ReadFile(path)
    if errors.Is(err, os.ErrNotExist) {
        return nil, nil
    }
    if err != nil {
        return nil, err
    }
    var todos []Todo
    return todos, json.Unmarshal(data, &todos)
}

func save(path string, todos []Todo) error {
    data, err := json.MarshalIndent(todos, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile(path, data, 0o644)
}
```

## Your task

1. Parse `os.Args` to handle `add`, `list` and `done`.
2. Print done items with a ✓ mark.
3. **Bonus:** add a `remove` command.
