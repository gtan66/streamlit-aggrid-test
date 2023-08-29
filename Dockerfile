# syntax=docker/dockerfile:1.4

ARG PYTHON_VERSION="3.11.4"
FROM python:${PYTHON_VERSION}-slim-bullseye

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

# Setup Pip
ARG PIP_VERSION="23.2.1"
ENV PIP_VERSION=${PIP_VERSION}

RUN pip install --no-cache-dir --upgrade "pip==${PIP_VERSION}" && pip --version

ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore
RUN mkdir /component
WORKDIR /component

# Install streamlit and components
ARG STREAMLIT_VERSION="latest"
ENV E2E_STREAMLIT_VERSION=${STREAMLIT_VERSION}

RUN <<"EOF"
if [[ "${E2E_STREAMLIT_VERSION}" == "latest" ]]; then
  pip install --no-cache-dir "streamlit"
elif [[ "${E2E_STREAMLIT_VERSION}" == "nightly" ]]; then
  pip uninstall --yes streamlit
  pip install --no-cache-dir "streamlit-nightly"
else
  pip install --no-cache-dir "streamlit==${E2E_STREAMLIT_VERSION}"
fi

# Coherence check
installed_streamlit_version=$(python -c "import streamlit; print(streamlit.__version__)")
echo "Installed Streamlit version: ${installed_streamlit_version}"
if [[ "${E2E_STREAMLIT_VERSION}" == "nightly" ]]; then
  echo "${installed_streamlit_version}" | grep 'dev'
else
  echo "${installed_streamlit_version}" | grep -v 'dev'
fi
EOF