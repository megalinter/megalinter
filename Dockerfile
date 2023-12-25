# syntax=docker/dockerfile:1
###########################################
###########################################
## Dockerfile to run MegaLinter ##
###########################################
###########################################

# @not-generated

#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################
#FROM__START
FROM rhysd/actionlint:latest as actionlint
# shellcheck is a dependency for actionlint

FROM koalaman/shellcheck:stable as shellcheck
# Next FROM line commented because already managed by another linter
# FROM koalaman/shellcheck:stable as shellcheck
FROM mvdan/shfmt:latest-alpine as shfmt
FROM hadolint/hadolint:v2.12.0-alpine as hadolint
FROM mstruebing/editorconfig-checker:2.7.2 as editorconfig-checker
FROM golang:1-alpine as revive
## The golang image used as a builder is a temporary workaround 
## for the released revive binaries not returning version numbers (devel). 
## The install command should then be what is commented in the go.megalinter-descriptor.yml
RUN GOBIN=/usr/bin go install github.com/mgechev/revive@latest

FROM ghcr.io/yannh/kubeconform:latest-alpine as kubeconform
FROM ghcr.io/assignuser/chktex-alpine:latest as chktex
FROM mrtazz/checkmake:latest as checkmake
FROM ghcr.io/phpstan/phpstan:latest-php8.1 as phpstan
FROM yoheimuta/protolint:latest as protolint
FROM golang:alpine as dustilock
RUN GOBIN=/usr/bin go install github.com/checkmarx/dustilock@v1.2.0

FROM zricethezav/gitleaks:v8.18.1 as gitleaks
FROM checkmarx/kics:alpine as kics
FROM trufflesecurity/trufflehog:latest as trufflehog
FROM jdkato/vale:latest as vale
FROM lycheeverse/lychee:latest-alpine as lychee
FROM ghcr.io/terraform-linters/tflint:v0.50.0 as tflint
FROM tenable/terrascan:1.18.8 as terrascan
FROM alpine/terragrunt:latest as terragrunt
# Next FROM line commented because already managed by another linter
# FROM alpine/terragrunt:latest as terragrunt
#FROM__END

##################
# Get base image #
##################
FROM python:3.11.7-alpine3.18
ARG GITHUB_TOKEN

#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################
#ARG__START
ARG ARM_TTK_NAME='master.zip'
ARG ARM_TTK_URI='https://github.com/Azure/arm-ttk/archive/master.zip'
ARG ARM_TTK_DIRECTORY='/opt/microsoft'
ARG BICEP_EXE='bicep'
ARG BICEP_URI='https://github.com/Azure/bicep/releases/latest/download/bicep-linux-musl-x64'
ARG BICEP_DIR='/usr/local/bin'
ARG DART_VERSION='2.8.4'
ARG PMD_VERSION=6.55.0
ARG PSSA_VERSION='latest'
#ARG__END

####################
# Run APK installs #
####################

WORKDIR /

#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################
#APK__START
RUN apk add --no-cache \
                bash \
                ca-certificates \
                curl \
                gcc \
                git \
                git-lfs \
                libffi-dev \
                make \
                musl-dev \
                openssh \
                docker \
                openrc \
                icu-libs \
                dotnet7-sdk \
                openjdk17 \
                perl \
                perl-dev \
                gnupg \
                php81 \
                php81-phar \
                php81-mbstring \
                php81-xmlwriter \
                php81-tokenizer \
                php81-ctype \
                php81-curl \
                php81-dom \
                php81-simplexml \
                dpkg \
                py3-pyflakes \
                clang16-extra-tools \
                nodejs \
                npm \
                yarn \
                go \
                helm \
                gcompat \
                libc6-compat \
                libstdc++ \
                openssl \
                readline-dev \
                g++ \
                libc-dev \
                libcurl \
                libgcc \
                libxml2-dev \
                libxml2-utils \
                linux-headers \
                R \
                R-dev \
                R-doc \
                nodejs-current \
                ruby \
                ruby-dev \
                ruby-bundler \
                ruby-rdoc \
    && git config --global core.autocrlf true
#APK__END

# PATH for golang & python
ENV GOROOT=/usr/lib/go \
    GOPATH=/go
    # PYTHONPYCACHEPREFIX="$HOME/.cache/cpython/" NV: not working for all packages :/
# hadolint ignore=DL3044
ENV PATH="$PATH":"$GOROOT"/bin:"$GOPATH"/bin
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin || true && \
    # Ignore npm package issues
    yarn config set ignore-engines true || true

##############################
# Installs rust dependencies #
#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################

#CARGO__START
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable \
    && export PATH="/root/.cargo/bin:${PATH}" \
    && rustup component add clippy && cargo install --force --locked sarif-fmt  shellcheck-sarif \
    && rm -rf /root/.cargo/registry /root/.cargo/git /root/.cache/sccache
ENV PATH="/root/.cargo/bin:${PATH}"
#CARGO__END

################################
# Installs python dependencies #
#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################

#PIPVENV__START
RUN PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir --upgrade pip virtualenv \
    && mkdir -p "/venvs/ansible-lint" && cd "/venvs/ansible-lint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir ansible-lint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/cpplint" && cd "/venvs/cpplint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir cpplint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/cfn-lint" && cd "/venvs/cfn-lint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir cfn-lint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/djlint" && cd "/venvs/djlint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir djlint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/pylint" && cd "/venvs/pylint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir pylint typing-extensions && deactivate && cd ./../.. \
    && mkdir -p "/venvs/black" && cd "/venvs/black" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir black && deactivate && cd ./../.. \
    && mkdir -p "/venvs/flake8" && cd "/venvs/flake8" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir flake8 && deactivate && cd ./../.. \
    && mkdir -p "/venvs/isort" && cd "/venvs/isort" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir isort black && deactivate && cd ./../.. \
    && mkdir -p "/venvs/bandit" && cd "/venvs/bandit" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir bandit bandit_sarif_formatter bandit[toml] && deactivate && cd ./../.. \
    && mkdir -p "/venvs/mypy" && cd "/venvs/mypy" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir mypy && deactivate && cd ./../.. \
    && mkdir -p "/venvs/pyright" && cd "/venvs/pyright" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir pyright && deactivate && cd ./../.. \
    && mkdir -p "/venvs/ruff" && cd "/venvs/ruff" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir ruff && deactivate && cd ./../.. \
    && mkdir -p "/venvs/checkov" && cd "/venvs/checkov" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir packaging checkov && deactivate && cd ./../.. \
    && mkdir -p "/venvs/semgrep" && cd "/venvs/semgrep" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir semgrep && deactivate && cd ./../.. \
    && mkdir -p "/venvs/rst-lint" && cd "/venvs/rst-lint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir restructuredtext_lint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/rstcheck" && cd "/venvs/rstcheck" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir rstcheck[toml,sphinx] && deactivate && cd ./../.. \
    && mkdir -p "/venvs/rstfmt" && cd "/venvs/rstfmt" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir rstfmt && deactivate && cd ./../.. \
    && mkdir -p "/venvs/snakemake" && cd "/venvs/snakemake" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir snakemake && deactivate && cd ./../.. \
    && mkdir -p "/venvs/snakefmt" && cd "/venvs/snakefmt" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir snakefmt && deactivate && cd ./../.. \
    && mkdir -p "/venvs/proselint" && cd "/venvs/proselint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir proselint && deactivate && cd ./../.. \
    && mkdir -p "/venvs/sqlfluff" && cd "/venvs/sqlfluff" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir sqlfluff && deactivate && cd ./../.. \
    && mkdir -p "/venvs/yamllint" && cd "/venvs/yamllint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir yamllint && deactivate && cd ./../..  \
    && find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf && rm -rf /root/.cache
ENV PATH="${PATH}":/venvs/ansible-lint/bin:/venvs/cpplint/bin:/venvs/cfn-lint/bin:/venvs/djlint/bin:/venvs/pylint/bin:/venvs/black/bin:/venvs/flake8/bin:/venvs/isort/bin:/venvs/bandit/bin:/venvs/mypy/bin:/venvs/pyright/bin:/venvs/ruff/bin:/venvs/checkov/bin:/venvs/semgrep/bin:/venvs/rst-lint/bin:/venvs/rstcheck/bin:/venvs/rstfmt/bin:/venvs/snakemake/bin:/venvs/snakefmt/bin:/venvs/proselint/bin:/venvs/sqlfluff/bin:/venvs/yamllint/bin
#PIPVENV__END

############################
# Install NPM dependencies #
#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################

ENV NODE_OPTIONS="--max-old-space-size=8192" \
    NODE_ENV=production
#NPM__START
WORKDIR /node-deps
RUN npm --no-cache install --ignore-scripts --omit=dev \
                @salesforce/cli \
                typescript \
                @coffeelint/cli \
                jscpd \
                stylelint@15.11.0 \
                stylelint-config-standard@34.0.0 \
                stylelint-config-sass-guidelines \
                stylelint-scss@5.3.2 \
                gherkin-lint \
                graphql \
                graphql-schema-linter \
                npm-groovy-lint \
                htmlhint \
                eslint \
                eslint-config-airbnb \
                eslint-config-prettier \
                eslint-config-standard \
                eslint-plugin-import \
                eslint-plugin-jest \
                eslint-plugin-node \
                eslint-plugin-prettier \
                eslint-plugin-promise \
                eslint-plugin-vue \
                @babel/core \
                @babel/eslint-parser \
                @microsoft/eslint-formatter-sarif \
                standard \
                prettier \
                @prantlf/jsonlint \
                eslint-plugin-jsonc \
                v8r \
                npm-package-json-lint \
                npm-package-json-lint-config-default \
                eslint-plugin-react \
                eslint-plugin-jsx-a11y \
                markdownlint-cli \
                markdown-link-check \
                markdown-table-formatter \
                @stoplight/spectral-cli \
                secretlint \
                @secretlint/secretlint-rule-preset-recommend \
                @secretlint/secretlint-formatter-sarif \
                cspell \
                sql-lint \
                @ibm/tekton-lint \
                prettyjson \
                @typescript-eslint/eslint-plugin \
                @typescript-eslint/parser \
                ts-standard  && \
    echo "Cleaning npm cache…" \
    && npm cache clean --force || true \
    && echo "Changing owner of node_modules files…" \
    && chown -R "$(id -u)":"$(id -g)" node_modules # fix for https://github.com/npm/cli/issues/5900 \
    && echo "Removing extra node_module files…" \
    && rm -rf /root/.npm/_cacache \
    && find . -name "*.d.ts" -delete \
    && find . -name "*.map" -delete \
    && find . -name "*.npmignore" -delete \
    && find . -name "*.travis.yml" -delete \
    && find . -name "CHANGELOG.md" -delete \
    && find . -name "README.md" -delete \
    && find . -name ".package-lock.json" -delete \
    && find . -name "package-lock.json" -delete \
    && find . -name "README.md" -delete
WORKDIR /

#NPM__END

# Add node packages to path #
ENV PATH="/node-deps/node_modules/.bin:${PATH}" \
    NODE_PATH="/node-deps/node_modules"

##############################
# Installs ruby dependencies #
#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################

#GEM__START
RUN echo 'gem: --no-document' >> ~/.gemrc && \
    gem install \
          scss_lint \
          puppet-lint \
          rubocop \
          rubocop-github \
          rubocop-performance \
          rubocop-rails \
          rubocop-rake \
          rubocop-rspec
#GEM__END

##############################
# COPY instructions #
#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################

#COPY__START
COPY --link --from=actionlint /usr/local/bin/actionlint /usr/bin/actionlint
# shellcheck is a dependency for actionlint

COPY --link --from=shellcheck /bin/shellcheck /usr/bin/shellcheck
# Next COPY line commented because already managed by another linter
# COPY --link --from=shellcheck /bin/shellcheck /usr/bin/shellcheck
COPY --link --from=shfmt /bin/shfmt /usr/bin/
COPY --link --from=hadolint /bin/hadolint /usr/bin/hadolint
COPY --link --from=editorconfig-checker /usr/bin/ec /usr/bin/editorconfig-checker
COPY --link --from=revive /usr/bin/revive /usr/bin/revive
COPY --link --from=kubeconform /kubeconform /usr/bin/
COPY --link --from=chktex /usr/bin/chktex /usr/bin/
COPY --link --from=checkmake /checkmake /usr/bin/checkmake
COPY --link --from=phpstan /composer/vendor/phpstan/phpstan/phpstan.phar /usr/bin/phpstan
COPY --link --from=protolint /usr/local/bin/protolint /usr/bin/
COPY --link --from=dustilock /usr/bin/dustilock /usr/bin/dustilock
COPY --link --from=gitleaks /usr/bin/gitleaks /usr/bin/
COPY --link --from=kics /app/bin/kics /usr/bin/kics
COPY --from=kics /app/bin/assets /usr/bin/assets
COPY --link --from=trufflehog /usr/bin/trufflehog /usr/bin/
COPY --link --from=vale /bin/vale /bin/vale
COPY --link --from=lychee /usr/local/bin/lychee /usr/bin/
COPY --link --from=tflint /usr/local/bin/tflint /usr/bin/
COPY --link --from=terrascan /go/bin/terrascan /usr/bin/
COPY --link --from=terragrunt /usr/local/bin/terragrunt /usr/bin/
COPY --link --from=terragrunt /bin/terraform /usr/bin/
#COPY__END

#############################################################################################
## @generated by .automation/build.py using descriptor files, please do not update manually ##
#############################################################################################
#OTHER__START
RUN rc-update add docker boot && rc-service docker start || true \
# ARM installation
    && curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh


# CLOJURE installation
ENV LANG=C.UTF-8
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.34-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget --quiet --tries=10 --waitretry=10 \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    mv /etc/nsswitch.conf /etc/nsswitch.conf.bak && \
    apk add --no-cache --force-overwrite \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    mv /etc/nsswitch.conf.bak /etc/nsswitch.conf && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true) && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"


# CSHARP installation
ENV PATH="${PATH}:/root/.dotnet/tools"

# DART installation
# Next line commented because already managed by another linter
# ENV LANG=C.UTF-8
# Next line commented because already managed by another linter
# RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
#     ALPINE_GLIBC_PACKAGE_VERSION="2.34-r0" && \
#     ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#     ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#     ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#     apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
#     echo \
#         "-----BEGIN PUBLIC KEY-----\
#         MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
#         y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
#         tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
#         m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
#         KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
#         Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
#         1QIDAQAB\
#         -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
#     wget --quiet --tries=10 --waitretry=10 \
#         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
#     mv /etc/nsswitch.conf /etc/nsswitch.conf.bak && \
#     apk add --no-cache --force-overwrite \
#         "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
#     \
#     mv /etc/nsswitch.conf.bak /etc/nsswitch.conf && \
#     rm "/etc/apk/keys/sgerrand.rsa.pub" && \
#     (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true) && \
#     echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
#     \
#     apk del glibc-i18n && \
#     \
#     rm "/root/.wget-hsts" && \
#     apk del .build-dependencies && \
#     rm \
#         "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#         "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# JAVA installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="$JAVA_HOME/bin:${PATH}"

# KOTLIN installation
# Next line commented because already managed by another linter
# ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# Next line commented because already managed by another linter
# ENV PATH="$JAVA_HOME/bin:${PATH}"

# PHP installation
RUN --mount=type=secret,id=GITHUB_TOKEN GITHUB_AUTH_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" \
    && export GITHUB_AUTH_TOKEN \
    && wget --tries=5 -q -O phive.phar https://phar.io/releases/phive.phar \
    && wget --tries=5 -q -O phive.phar.asc https://phar.io/releases/phive.phar.asc \
    && PHAR_KEY_ID="0x6AF725270AB81E04D79442549D8A98B29B2D5D79" \
    && ( gpg --keyserver hkps://keys.openpgp.org --recv-keys "$PHAR_KEY_ID" \
       || gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$PHAR_KEY_ID" \
       || gpg --keyserver keyserver.pgp.com --recv-keys "$PHAR_KEY_ID" \
       || gpg --keyserver pgp.mit.edu --recv-keys "$PHAR_KEY_ID" ) \
    && gpg --verify phive.phar.asc phive.phar \
    && chmod +x phive.phar \
    && mv phive.phar /usr/local/bin/phive \
    && rm phive.phar.asc \
    && update-alternatives --install /usr/bin/php php /usr/bin/php81 110


# POWERSHELL installation
# Next line commented because already managed by another linter
# RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz \
#     && mkdir -p /opt/microsoft/powershell/7 \
#     && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
#     && chmod +x /opt/microsoft/powershell/7/pwsh \
#     && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# SALESFORCE installation
# Next line commented because already managed by another linter
# ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# Next line commented because already managed by another linter
# ENV PATH="$JAVA_HOME/bin:${PATH}"
RUN sf plugins install @salesforce/plugin-packaging \
    && echo y|sfdx plugins:install sfdx-hardis \
    && npm cache clean --force || true \
    && rm -rf /root/.npm/_cacache \

# SCALA installation
# Next line commented because already managed by another linter
# ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# Next line commented because already managed by another linter
# ENV PATH="$JAVA_HOME/bin:${PATH}"
    && curl --retry-all-errors --retry 10 -fLo coursier https://git.io/coursier-cli && \
        chmod +x coursier


# VBDOTNET installation
# Next line commented because already managed by another linter
# ENV PATH="${PATH}:/root/.dotnet/tools"

# actionlint installation
# Managed with COPY --link --from=actionlint /usr/local/bin/actionlint /usr/bin/actionlint
#              # shellcheck is a dependency for actionlint
# Managed with COPY --link --from=shellcheck /bin/shellcheck /usr/bin/shellcheck

# arm-ttk installation
ENV ARM_TTK_PSD1="${ARM_TTK_DIRECTORY}/arm-ttk-master/arm-ttk/arm-ttk.psd1"
RUN curl --retry 5 --retry-delay 5 -sLO "${ARM_TTK_URI}" \
    && unzip "${ARM_TTK_NAME}" -d "${ARM_TTK_DIRECTORY}" \
    && rm "${ARM_TTK_NAME}" \
    && ln -sTf "${ARM_TTK_PSD1}" /usr/bin/arm-ttk \
    && chmod a+x /usr/bin/arm-ttk \

# bash-exec installation
    && printf '#!/bin/bash \n\nif [[ -x "$1" ]]; then exit 0; else echo "Error: File:[$1] is not executable"; exit 1; fi' > /usr/bin/bash-exec \
    && chmod +x /usr/bin/bash-exec \

# shellcheck installation
# Managed with # Next COPY line commented because already managed by another linter
#              # COPY --link --from=shellcheck /bin/shellcheck /usr/bin/shellcheck

# shfmt installation
# Managed with COPY --link --from=shfmt /bin/shfmt /usr/bin/

# bicep_linter installation
    && curl --retry 5 --retry-delay 5 -sLo ${BICEP_EXE} "${BICEP_URI}" \
    && chmod +x "${BICEP_EXE}" \
    && mv "${BICEP_EXE}" "${BICEP_DIR}" \

# clj-kondo installation
    && curl --retry 5 --retry-delay 5 -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo \
    && chmod +x install-clj-kondo \
    && ./install-clj-kondo \

# cljstyle installation
    && curl --retry 5 --retry-delay 5 -sLO https://raw.githubusercontent.com/greglook/cljstyle/main/script/install-cljstyle \
    && chmod +x install-cljstyle \
    && ./install-cljstyle \

# csharpier installation
    && dotnet tool install --global csharpier \

# roslynator installation
    && dotnet tool install -g roslynator.dotnet.cli \

# dartanalyzer installation
    && wget --tries=5 https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -O - -q | unzip -q - \
    && chmod +x dart-sdk/bin/dart* \
    && mv dart-sdk/bin/* /usr/bin/ && mv dart-sdk/lib/* /usr/lib/ && mv dart-sdk/include/* /usr/include/ \
    && rm -r dart-sdk/ \

# hadolint installation
# Managed with COPY --link --from=hadolint /bin/hadolint /usr/bin/hadolint

# editorconfig-checker installation
# Managed with COPY --link --from=editorconfig-checker /usr/bin/ec /usr/bin/editorconfig-checker

# dotenv-linter installation
    && wget -q -O - https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s \

# golangci-lint installation
    && wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh \
    && golangci-lint --version


# revive installation
# Managed with COPY --link --from=revive /usr/bin/revive /usr/bin/revive

# npm-groovy-lint installation
# Next line commented because already managed by another linter
# ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# Next line commented because already managed by another linter
# ENV PATH="$JAVA_HOME/bin:${PATH}"

# checkstyle installation
RUN --mount=type=secret,id=GITHUB_TOKEN CHECKSTYLE_LATEST=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    https://api.github.com/repos/checkstyle/checkstyle/releases/latest \
        | grep browser_download_url \
        | grep ".jar" \
        | cut -d '"' -f 4) \
    && curl --retry 5 --retry-delay 5 -sSL $CHECKSTYLE_LATEST \
        --output /usr/bin/checkstyle


# pmd installation
RUN wget --quiet https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip && \
    unzip pmd-bin-${PMD_VERSION}.zip && \
    rm pmd-bin-${PMD_VERSION}.zip && \
    mv pmd-bin-${PMD_VERSION} /usr/bin/pmd && \
    chmod +x /usr/bin/pmd/bin/run.sh \

# ktlint installation
    && curl --retry 5 --retry-delay 5 -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint && \
    chmod a+x ktlint && \
    mv "ktlint" /usr/bin/ \

# kubeconform installation
# Managed with COPY --link --from=kubeconform /kubeconform /usr/bin/

# kubescape installation
    && ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2 && \
    curl --retry 5 --retry-delay 5 -sLv https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash -s -- -v v2.9.0 \

# chktex installation
# Managed with COPY --link --from=chktex /usr/bin/chktex /usr/bin/
    && cd ~ && touch .chktexrc && cd / \

# luacheck installation
    && wget --tries=5 https://www.lua.org/ftp/lua-5.3.5.tar.gz -O - -q | tar -xzf - \
    && cd lua-5.3.5 \
    && make linux \
    && make install \
    && cd .. && rm -r lua-5.3.5/ \
    && wget --tries=5 https://github.com/cvega/luarocks/archive/v3.3.1-super-linter.tar.gz -O - -q | tar -xzf - \
    && cd luarocks-3.3.1-super-linter \
    && ./configure --with-lua-include=/usr/local/include \
    && make \
    && make -b install \
    && cd .. && rm -r luarocks-3.3.1-super-linter/ \
    && luarocks install luacheck \
    && cd / \

# checkmake installation
# Managed with COPY --link --from=checkmake /checkmake /usr/bin/checkmake

# perlcritic installation
    && curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm | perl - install -g --show-build-log-on-failure --without-build --without-test --without-runtime Perl::Critic \
    && rm -rf /root/.perl-cpm


# phpcs installation
RUN --mount=type=secret,id=GITHUB_TOKEN GITHUB_AUTH_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && export GITHUB_AUTH_TOKEN && phive --no-progress install phpcs -g --trust-gpg-keys 31C7E470E2138192,95DE904AB800754A11D80B605E6DDE998AB73B8E


# phpstan installation
# Managed with COPY --link --from=phpstan /composer/vendor/phpstan/phpstan/phpstan.phar /usr/bin/phpstan
RUN chmod +x /usr/bin/phpstan

# psalm installation
RUN --mount=type=secret,id=GITHUB_TOKEN GITHUB_AUTH_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && export GITHUB_AUTH_TOKEN && phive --no-progress install psalm -g --trust-gpg-keys 8A03EA3B385DBAA1,12CE0F1D262429A5


# phplint installation
RUN --mount=type=secret,id=GITHUB_TOKEN GITHUB_AUTH_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && export GITHUB_AUTH_TOKEN && phive --no-progress install overtrue/phplint --force-accept-unsigned -g


# powershell installation
RUN pwsh -c 'Install-Module -Name PSScriptAnalyzer -RequiredVersion ${PSSA_VERSION} -Scope AllUsers -Force'

# powershell_formatter installation
# Next line commented because already managed by another linter
# RUN pwsh -c 'Install-Module -Name PSScriptAnalyzer -RequiredVersion ${PSSA_VERSION} -Scope AllUsers -Force'

# protolint installation
# Managed with COPY --link --from=protolint /usr/local/bin/protolint /usr/bin/

# mypy installation
ENV MYPY_CACHE_DIR=/tmp

# lintr installation
RUN mkdir -p /home/r-library \
    && cp -r /usr/lib/R/library/ /home/r-library/ \
    && Rscript -e "install.packages(c('lintr','purrr'), repos = 'https://cloud.r-project.org/')" \
    && R -e "install.packages(list.dirs('/home/r-library',recursive = FALSE), repos = NULL, type = 'source')" \

# raku installation
    && curl -L https://github.com/nxadm/rakudo-pkg/releases/download/v2020.10-02/rakudo-pkg-Alpine3.12_2020.10-02_x86_64.apk > rakudo-pkg-Alpine3.12_2020.10-02_x86_64.apk \
    && apk add --no-cache --allow-untrusted rakudo-pkg-Alpine3.12_2020.10-02_x86_64.apk \
    && rm rakudo-pkg-Alpine3.12_2020.10-02_x86_64.apk \
    && /opt/rakudo-pkg/bin/add-rakudo-to-path \
    # && source /root/.profile \
    && /opt/rakudo-pkg/bin/install-zef-as-user

ENV PATH="~/.raku/bin:/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/site/bin:$PATH"

# devskim installation
# Next line commented because already managed by another linter
# ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet tool install --global Microsoft.CST.DevSkim.CLI \

# dustilock installation
# Managed with COPY --link --from=dustilock /usr/bin/dustilock /usr/bin/dustilock

# gitleaks installation
# Managed with COPY --link --from=gitleaks /usr/bin/gitleaks /usr/bin/

# grype installation
    && curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin v0.63.1

# kics installation
# Managed with COPY --link --from=kics /app/bin/kics /usr/bin/kics
ENV KICS_QUERIES_PATH=/usr/bin/assets/queries KICS_LIBRARIES_PATH=/usr/bin/assets/libraries
# Managed with COPY --from=kics /app/bin/assets /usr/bin/assets

# syft installation
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin \

# trivy installation
    && wget --tries=5 -q -O - https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \

# trivy-sbom installation
# Next line commented because already managed by another linter
# RUN wget --tries=5 -q -O - https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# trufflehog installation
# Managed with COPY --link --from=trufflehog /usr/bin/trufflehog /usr/bin/

# sfdx-scanner-apex installation
    && sfdx plugins:install @salesforce/sfdx-scanner \
    && npm cache clean --force || true \
    && rm -rf /root/.npm/_cacache \

# sfdx-scanner-aura installation
# Next line commented because already managed by another linter
# RUN sfdx plugins:install @salesforce/sfdx-scanner \
#     && npm cache clean --force || true \
#     && rm -rf /root/.npm/_cacache

# sfdx-scanner-lwc installation
# Next line commented because already managed by another linter
# RUN sfdx plugins:install @salesforce/sfdx-scanner \
#     && npm cache clean --force || true \
#     && rm -rf /root/.npm/_cacache

# lightning-flow-scanner installation
    && echo y|sfdx plugins:install lightning-flow-scanner \
    && npm cache clean --force || true \
    && rm -rf /root/.npm/_cacache \

# scalafix installation
    && ./coursier install scalafix --quiet --install-dir /usr/bin && rm -rf /root/.cache \

# vale installation
# Managed with COPY --link --from=vale /bin/vale /bin/vale

# lychee installation
# Managed with COPY --link --from=lychee /usr/local/bin/lychee /usr/bin/

# tsqllint installation
# Next line commented because already managed by another linter
# ENV PATH="${PATH}:/root/.dotnet/tools"
    && dotnet tool install --global TSQLLint

# tflint installation
# Managed with COPY --link --from=tflint /usr/local/bin/tflint /usr/bin/

# terrascan installation
# Managed with COPY --link --from=terrascan /go/bin/terrascan /usr/bin/

# terragrunt installation
# Managed with COPY --link --from=terragrunt /usr/local/bin/terragrunt /usr/bin/

# terraform-fmt installation
# Managed with COPY --link --from=terragrunt /bin/terraform /usr/bin/

#OTHER__END

################################
# Installs python dependencies #
################################
COPY megalinter /megalinter
RUN PYTHONDONTWRITEBYTECODE=1 python /megalinter/setup.py install \
    && PYTHONDONTWRITEBYTECODE=1 python /megalinter/setup.py clean --all \
    && rm -rf /var/cache/apk/* \
    && find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf

#######################################
# Copy scripts and rules to container #
#######################################
COPY megalinter/descriptors /megalinter-descriptors
COPY TEMPLATES /action/lib/.automation

# Copy server scripts
COPY server /server

###########################
# Get the build arguments #
###########################
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

#################################################
# Set ENV values used for debugging the version #
#################################################
ENV BUILD_DATE=$BUILD_DATE \
    BUILD_REVISION=$BUILD_REVISION \
    BUILD_VERSION=$BUILD_VERSION

#FLAVOR__START
ENV MEGALINTER_FLAVOR=all
#FLAVOR__END

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="MegaLinter" \
      com.github.actions.description="The ultimate linters aggregator to make sure your projects are clean" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="Nicolas Vuillamy <nicolas.vuillamy@gmail.com>" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$BUILD_REVISION \
      org.opencontainers.image.version=$BUILD_VERSION \
      org.opencontainers.image.authors="Nicolas Vuillamy <nicolas.vuillamy@gmail.com>" \
      org.opencontainers.image.url="https://megalinter.io" \
      org.opencontainers.image.source="https://github.com/oxsecurity/megalinter" \
      org.opencontainers.image.documentation="https://megalinter.io" \
      org.opencontainers.image.vendor="Nicolas Vuillamy" \
      org.opencontainers.image.description="Lint your code base with GitHub Actions"

#EXTRA_DOCKERFILE_LINES__START
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
#EXTRA_DOCKERFILE_LINES__END
