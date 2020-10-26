ARG BASE_CONTAINER=dblodgett/hydrogeoenv-r:latest

FROM ${BASE_CONTAINER}

LABEL maintainer="David Blodgett <dblodgett@usgs.gov>"

USER root

RUN Rscript -e 'devtools::install_github("dblodgett-usgs/hygeo", upgrade = "never")'

RUN install2.r --error reticulate

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME
