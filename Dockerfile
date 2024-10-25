ARG py_version=3.11.2

FROM python:$py_version-slim-bullseye as base

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20210119 \
    git=1:2.30.2-1+deb11u2 \
    libpq-dev=13.16-0+deb11u1 \
    make=4.3-4.1 \
    openssh-client=1:8.4p1-5+deb11u3 \
    software-properties-common=0.96.20.2-2.1 \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8

RUN python -m pip install --upgrade "pip==24.0" "setuptools==69.2.0" "wheel==0.43.0" --no-cache-dir


FROM base as dbt

ARG commit_ref=main

HEALTHCHECK CMD dbt --version || exit 1

WORKDIR /analytics_engineer_assessment/
ENTRYPOINT ["tail", "-f", "/dev/null"]
COPY requirements.txt /analytics_engineer_assessment/
RUN python -m pip install -r /analytics_engineer_assessment/requirements.txt --no-cache-dir
ENV DBT_PROFILES_DIR="/analytics_engineer_assessment/"
