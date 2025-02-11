FROM eclipse-temurin:17.0.4_8-jdk-jammy

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -qy --no-install-recommends \
  curl \
  libxi6 \
  libxrender1 \
  libxtst6 \
  openjfx \
  python3-pip \
  python3-setuptools \
  unzip \
  xvfb \
  && python3 -m pip install --upgrade pip \
  && if test "$(dpkg --print-architecture)" = "armhf" ; then python3 -m pip config set global.extra-index-url https://www.piwheels.org/simple ; fi \
  && echo '8508bbdbc61027942aff5db81d7d224ada9f8ceeeab94f185d8c72adcc3d31aa  ibc.zip' | tee ibc.zip.sha256 \
  && curl -qL https://github.com/IbcAlpha/IBC/releases/download/3.14.0/IBCLinux-3.14.0.zip -o ibc.zip \
  && sha256sum -c ibc.zip.sha256 \
  && unzip ibc.zip -d /opt/ibc \
  && chmod o+x /opt/ibc/*.sh /opt/ibc/*/*.sh \
  && rm ibc.zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src

ADD ./tws/Jts /root/Jts
ADD ./dist /src/dist
ADD entrypoint.bash /src/entrypoint.bash

RUN python3 -m pip install dist/thetagang-*.whl \
  && rm -rf /root/.cache \
  && rm -rf dist \
  && echo '--module-path /usr/share/openjfx/lib' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '--add-modules java.base,java.naming,java.management,javafx.base,javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.swing,javafx.web' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '--add-opens java.desktop/javax.swing=ALL-UNNAMED' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '--add-opens java.desktop/java.awt=ALL-UNNAMED' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '--add-opens java.base/java.util=ALL-UNNAMED' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '--add-opens javafx.graphics/com.sun.javafx.application=ALL-UNNAMED' | tee -a /root/Jts/*/tws.vmoptions \
  && echo '[Logon]' | tee -a /root/Jts/jts.ini \
  && echo 'UseSSL=true' | tee -a /root/Jts/jts.ini

ENTRYPOINT [ "/src/entrypoint.bash" ]
