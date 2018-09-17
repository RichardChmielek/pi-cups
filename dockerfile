FROM resin/rpi-raspbian

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
  lsb

RUN sed -i "s/^#\ \+\(en_US.UTF-8\)/\1/" /etc/locale.gen \
  && locale-gen en_US en_US.UTF-8

ENV LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANGUAGE=en_US:en

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