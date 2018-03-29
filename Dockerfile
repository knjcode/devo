FROM python:2.7.14

RUN apt-get update && apt-get install -y \
  gettext \
  git \
  imagemagick \
  texlive-extra-utils \
  texlive-fonts-extra \
  texlive-latex-base \
  texlive-latex-extra \
  texlive-science \
  zbar-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV NODE_VERSION 9.10.0
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz"

ADD . /bot

WORKDIR /bot

RUN npm install --production && npm cache clear --force

EXPOSE 8080

CMD [ "npm", "start" ]
