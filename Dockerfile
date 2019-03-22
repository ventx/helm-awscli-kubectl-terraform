FROM ventx/alpine
LABEL maintainer="hajo@ventx.de"

ENV KUBE_LATEST_VERSION v1.13.4
ENV KUBE_RUNNING_VERSION v1.11.6
ENV HELM_VERSION v2.13.0
ENV AWSCLI 1.16.125
ENV TERRAFORM_VERSION 0.11.11


RUN apk --update --no-cache add libc6-compat git openssh-client python py-pip
RUN pip install --upgrade pip
RUN pip install requests awscli==${AWSCLI}

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_RUNNING_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl_latest \
  && chmod +x /usr/local/bin/kubectl_latest \
  && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

WORKDIR /work

CMD ["/bin/bash", "-l"]
