FROM trestletech/plumber:latest

# Settings up working directory
WORKDIR /src

# Copying files over
COPY ./rprodraqc19_0.1.0.tar.gz /tmp/rprodraqc19_0.1.0.tar.gz
COPY ./api /etc

# Update/Upgrade and install packages
RUN apt-get update && \
    apt-get upgrade -f -y && \
    apt-get install -y apt-utils
RUN R -e 'install.packages(c("xgboost", "data.table", "Matrix"))'
RUN R CMD INSTALL /tmp/rprodraqc19_0.1.0.tar.gz

EXPOSE 80
ENTRYPOINT ["R", "-f", "/etc/startup.R", "--slave"]
