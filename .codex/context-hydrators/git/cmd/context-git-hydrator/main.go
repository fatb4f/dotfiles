package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/fatb4f/dotfiles/.codex/context-hydrators/git/internal/hydrator"
)

func main() {
	if err := run(os.Args[1:], os.Stdout, os.Stderr); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(arguments []string, stdout, stderr io.Writer) error {
	if len(arguments) == 0 || arguments[0] != "committed" {
		return errors.New("usage: context-git-hydrator committed --request request.json")
	}

	flags := flag.NewFlagSet("committed", flag.ContinueOnError)
	flags.SetOutput(stderr)
	requestPath := flags.String("request", "", "path to a committed snapshot request JSON document")
	if err := flags.Parse(arguments[1:]); err != nil {
		return err
	}
	if flags.NArg() != 0 || *requestPath == "" {
		return errors.New("usage: context-git-hydrator committed --request request.json")
	}

	requestFile, err := os.Open(*requestPath)
	if err != nil {
		return fmt.Errorf("open request: %w", err)
	}
	defer requestFile.Close()

	request, err := hydrator.DecodeRequest(requestFile)
	if err != nil {
		return err
	}
	observation, err := hydrator.HydrateCommitted(request, hydrator.DefaultConfig())
	if err != nil {
		return err
	}
	payload, err := hydrator.MarshalCanonical(observation)
	if err != nil {
		return err
	}
	if _, err := stdout.Write(payload); err != nil {
		return fmt.Errorf("write observation: %w", err)
	}
	return nil
}
