package main

import (
	"context"
	"fmt"
	"os"

	"github.com/fatb4f/dotfiles/shell-wrap/src/hookrail/internal/flowproof"
)

func main() {
	ctx := context.Background()
	traceOut := ""
	args := os.Args[1:]
	if len(args) == 2 && args[0] == "--trace-out" {
		traceOut = args[1]
	} else if len(args) != 0 {
		fmt.Fprintln(os.Stderr, "usage: hookrail-flow [--trace-out path]")
		os.Exit(2)
	}

	repoRoot, err := flowproof.FindRepoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	report, err := flowproof.Run(ctx, repoRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if traceOut != "" {
		if err := os.WriteFile(traceOut, append(report, '\n'), 0o644); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
	}

	if _, err := os.Stdout.Write(report); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if _, err := os.Stdout.Write([]byte("\n")); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
