SHELL := /bin/sh

.PHONY: fmt lint fix test

fmt:
	gofumpt -w .

lint:
	golangci-lint run

fix:
	golangci-lint run --fix
