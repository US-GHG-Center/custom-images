FROM ghcr.io/nmfs-opensci/container-images/py-rocket-geospatial:latest

COPY environment.yml environment.yml
RUN /pyrocket_scripts/install-conda-packages.sh environment.yml && rm environment.yml

COPY install.R install.R
RUN /pyrocket_scripts/install-r-packages.sh install.R && rm install.R