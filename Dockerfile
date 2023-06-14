FROM python:3.10-slim AS base

ARG USERNAME="deng"
ARG GROUP="deng"
ARG USERID="10001"
ARG GROUPID="10001"

RUN groupadd --gid $GROUPID $GROUP \
    && useradd --create-home --no-user-group --gid $GROUPID --uid $USERID $USERNAME

ENV HOME=/home/$USERNAME

WORKDIR /app
COPY pyproject.toml poetry.lock /app/
ENV BUILD_DEPS="freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev git"

RUN apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    $BUILD_DEPS \
    freetds-bin \
    build-essential \
    default-libmysqlclient-dev \
    apt-utils \
    curl \
    rsync \
    netcat \
    locales

# Install poetry
# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -
RUN pip install poetry
ENV PATH $PATH:$HOME/.poetry/bin:$HOME/.local/bin
ENV PYTHONPATH $PYTHONPATH:$HOME/.local/lib/python3.7/site-packages

# Configure poetry to not use virtual environments
RUN poetry config virtualenvs.create false

# Install python dependencies
RUN poetry install --only main --no-root

# Clean up
RUN apt-get purge --auto-remove -yqq $BUILD_DEPS \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

COPY . /app
# Now that we've copied our project we can install it
RUN poetry install --only main

RUN chown -R $USERNAME.$GROUP $HOME /app

USER $USERNAME

FROM base as test
USER $USERNAME
