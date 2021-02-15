# Build with
#   docker build -t code-connect-ci .
# To run the linter and the formatter
#   docker run --rm -v "$(pwd):/app" code-connect-ci
# To only run the linter
#   docker run --rm -v "$(pwd):/app" code-connect-ci make lint

FROM python:3.8

RUN mkdir /app
WORKDIR /app

# Install poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

CMD ["poetry", "--version"]
