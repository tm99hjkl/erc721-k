SHELL=/bin/bash
TESTS = tests/**/*

erc721-k: erc721.k
	kompile erc721.k
	source test.sh

.PHONY: clean
clean:
	rm -r erc721-kompiled
