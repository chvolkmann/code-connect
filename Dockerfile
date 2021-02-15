# Build with
#   docker build -t code-connect-ci .
# To run the linter and the formatter
#   docker run --rm -v "$(pwd):/app" code-connect-ci
# To only run the linter
#   docker run --rm -v "$(pwd):/app" code-connect-ci make lint

FROM python:3.8

RUN mkdir /app
WORKDIR /app

RUN pip install flake8 black isort

CMD ["make"]