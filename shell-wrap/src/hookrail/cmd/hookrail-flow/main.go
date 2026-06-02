package main

import (
	"context"
	"fmt"
	"os"

	"github.com/fatb4f/dotfiles/shell-wrap/src/hookrail/internal/flowproof"
)

func main() {
	ctx := context.Background()

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

	if _, err := os.Stdout.Write(report); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if _, err := os.Stdout.Write([]byte("\n")); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
