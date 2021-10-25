FROM arm64v8/ubuntu
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
  curl \
  sudo \
  locales \
  whois \
  cups \
  cups-filters \
  cups-pdf \
  cups-client \
  cups-bsd \
  printer-driver-all \
  tzdata

RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
  && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/lib/apt/lists/partial

RUN curl https://launchpadlibrarian.net/374116317/printer-driver-escpr_1.6.21-1_armhf.deb --output printer-driver-escpr_1.6.21-1_armhf.deb
COPY install.sh .
RUN sh install.sh printer-driver-escpr_1.6.21-1_armhf.deb

COPY etc/cups/cupsd.conf /etc/cups/cupsd.conf

EXPOSE 631
ENTRYPOINT ["/usr/sbin/cupsd", "-f"]
