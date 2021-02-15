.PHONY: lint format

code-style: format lint

lint:
	flake8 .

format:
	black .
	isort .

