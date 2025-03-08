.PHONY: deps format lint typecheck check

deps:
	poetry install

check: lint typecheck


format: deps
	poetry run ruff format bin/
lint: deps
	poetry run ruff check bin/
typecheck: deps
	poetry run mypy bin/
