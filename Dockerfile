FROM hadolint/hadolint:v1.14.0 AS hadolint
FROM koalaman/shellcheck:v0.5.0 AS shellcheck
FROM alpine:3.8 as build

WORKDIR /tmp/build

ENV KUBE_VERSION="1.11.4"
ENV kubectlURL https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl

# hadolint ignore=DL3018
RUN apk --no-cache --quiet add jq curl; \
    curl -L -s -o /usr/local/bin/kubectl \
        ${kubectlURL} && \
    chmod +x /usr/local/bin/kubectl

# Lint, test
COPY . .
COPY --from=hadolint /bin/hadolint /usr/local/bin/hadolint
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/shellcheck

RUN /usr/local/bin/hadolint ./Dockerfile

RUN /usr/local/bin/shellcheck --format=gcc ./bin/*

FROM alpine:3.8
RUN apk --no-cache --quiet add jq=1.6_rc1-r1 bash=4.4.19-r1
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl

COPY bin/* /opt/resource/

CMD ["/usr/local/bin/kubectl"]
