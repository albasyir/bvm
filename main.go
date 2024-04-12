package main

import (
    "fmt"
    "os"
)

func main() {
    // Check if there are enough arguments
    if len(os.Args) < 2 {
        fmt.Println("Usage: go run main.go [argument]")
        os.Exit(1)
    }

    // Get the first command-line argument
    argument := os.Args[1]

	unix.SayHello()

    // Print the argument
    fmt.Println("Argument:", argument)
}