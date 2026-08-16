FROM alpine:3.22.1 AS build
LABEL maintainer="Ross Stewart <rosskouk@gmail.com>"
LABEL org.opencontainers.image.source=https://github.com/foobarbigtime/asknavidrome

RUN apk add python3 py3-pip build-base python3-dev libffi-dev openssl-dev

WORKDIR /opt

RUN python3 -m venv env

WORKDIR /opt/asknavidrome

# Install dependencies from this checkout, then copy the skill source from this
# checkout. The upstream Dockerfile cloned rosskouk/asknavidrome during the
# build, which meant images built from a fork silently contained upstream code.
COPY skill/requirements-docker.txt skill/requirements-docker.txt
RUN source /opt/env/bin/activate && pip --no-cache-dir install wheel && pip --no-cache-dir install -r skill/requirements-docker.txt

COPY skill /opt/asknavidrome/skill


FROM alpine:3.22.1
LABEL maintainer="Ross Stewart <rosskouk@gmail.com>"
LABEL org.opencontainers.image.source=https://github.com/foobarbigtime/asknavidrome

RUN apk add python3

COPY --from=build /opt/env /opt/env
COPY --from=build /opt/asknavidrome/skill /opt/asknavidrome/

WORKDIR /opt/asknavidrome

# Activate Python Virtual Environment
ENV PATH="/opt/env/bin:$PATH"

EXPOSE 5000

ENTRYPOINT ["python3", "app.py"]
