.DEFAULT_GOAL := help
POETRY_OVERRIDE_PYTHON := true

export PROJECT_DIR ?= $(shell pwd | sed 's/\/cygdrive//g')

ifeq ($(firstword $(MAKECMDGOALS)), $(filter $(firstword $(MAKECMDGOALS)), new run))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

help:  ## print this help
	@# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^([a-zA-Z_-]|\/)+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
.PHONY: help

lock:  ## Regenerate poetry.lock
	poetry lock -vvv
.PHONY: lock

init:  ## Install dependencies in poetry.lock
	if [ ! -e "poetry.lock" ]; then \
		make lock; \
	else \
		poetry install; \
		pre-commit install; \
	fi
.PHONY: init

run:  ## Run code
	poetry run python src/$(RUN_ARGS)
.PHONY: run

new:  ## Start a new app
	cp -r src/template src/$(RUN_ARGS)
.PHONY: new

lint:  ## Local python lint
	mkdir -p qa_reports
	poetry run black . --check
	poetry run isort . --check
	poetry run pflake8 --format codeclimate
.PHONY: lint

fmt:  ## Python format
	poetry run black .
	poetry run isort .
.PHONY: fmt
