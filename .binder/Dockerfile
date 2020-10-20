FROM rocker/rstudio:4.0.3-daily

RUN /rocker_scripts/install_tidyverse.sh

ENV NB_USER=jovyan

RUN /rocker_scripts/install_python.sh
RUN /rocker_scripts/install_binder.sh

RUN install2.r --error --skipinstalled\
      gganimate\
      gapminder

CMD jupyter notebook --ip 0.0.0.0

USER ${NB_USER}

WORKDIR /home/${NB_USER}
