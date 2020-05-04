FROM alpine:3.10
LABEL maintainer="hajo@ventx.de"

ENV KUBE_LATEST_VERSION v1.15.3
ENV KUBE_RUNNING_VERSION v1.14.1
ENV HELM_VERSION v2.13.1
ENV AWSCLI 1.16.243
ENV TERRAFORM_VERSION 0.12.24
ENV AWS_AUTHENTICATOR_VERSION 1.14.6
ENV AWS_AUTHENTICATOR_DATE 2019-08-22

RUN apk --update --no-cache add \
  bash \
  ca-certificates \
  curl \
  jq \
  git \
  openssh-client \
  python3 \
  tar \
  wget

RUN pip3 install --upgrade pip
RUN pip3 install requests awscli==${AWSCLI}

# Install Terraform
RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install aws-iam-authenticator
RUN curl https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_AUTHENTICATOR_VERSION}/${AWS_AUTHENTICATOR_DATE}/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_RUNNING_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install helm
RUN wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# Install latest kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl_latest && \
    chmod +x /usr/local/bin/kubectl_latest

# Install envsubst
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install Helm plugins
RUN helm init --client-only
RUN helm plugin install https://github.com/databus23/helm-diff

WORKDIR /work

CMD ["helm", "version"]