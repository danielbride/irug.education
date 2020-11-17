FROM rocker/geospatial:4.0.2

ENV NB_USER=rstudio

# Copies your repo files into the Docker Container
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

RUN /rocker_scripts/install_python.sh
RUN /rocker_scripts/install_binder.sh
RUN /rocker_scripts/install_shiny_server.sh

CMD jupyter notebook --ip 0.0.0.0

USER ${NB_USER}

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi

WORKDIR /home/${NB_USER}