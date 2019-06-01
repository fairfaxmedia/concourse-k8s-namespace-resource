FROM hadolint/hadolint:v1.16.3 AS hadolint
FROM koalaman/shellcheck:v0.6.0 AS shellcheck
FROM alpine:3.9 as build

WORKDIR /tmp/build

ENV KUBE_VERSION="1.11.10"
ENV kubectlURL https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl

# hadolint ignore=DL3018
RUN apk --no-cache --quiet add jq curl upx; \
    curl -L -s -o /usr/local/bin/kubectl \
        ${kubectlURL} && \
    chmod +x /usr/local/bin/kubectl && \
    upx --brute /usr/local/bin/kubectl

# Lint, test
COPY . .
COPY --from=hadolint /bin/hadolint /usr/local/bin/hadolint
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/shellcheck

RUN /usr/local/bin/hadolint ./Dockerfile

RUN /usr/local/bin/shellcheck --format=gcc ./bin/*

FROM alpine:3.9
RUN apk --no-cache --quiet add jq~=1.6 bash~=4.4
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl

COPY bin/* /opt/resource/

CMD ["/usr/local/bin/kubectl"]
