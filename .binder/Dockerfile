FROM rocker/binder:4.0.2
LABEL maintainer='Daniel Bride'

## Declares build arguments
ARG NB_USER
ARG NB_UID

USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}


RUN wget https://github.com/danielbride/irug.education/raw/master/DESCRIPTION && R -e "options(repos = list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2020-10-08/')); devtools::install_deps()"

RUN rm DESCRIPTION.1

USER ${NB_USER}

RUN exit 0
