FROM gcr.io/corp-prod-gkeinfra/lacapitale-base-opencpu:2.1.1r2

# Copying files over
WORKDIR /src
COPY ./totalloss /totalloss
COPY ./apachemod/mod_dumpost.so /usr/lib/apache2/modules/mod_dumpost.so
COPY ./apachemod/dumpost.load /etc/apache2/mods-available/dumpost.load
COPY ./apachesites /etc/apache2/sites-available
COPY ./opencpu/Rprofile /etc/opencpu/Rprofile
COPY ./opencpu/server.conf /etc/opencpu/server.conf

# Install built package
RUN R CMD INSTALL /totalloss/totalloss_1.0.1.tar.gz

# Enable dumpost from precompiled binaries
RUN chmod 644 /usr/lib/apache2/modules/mod_dumpost.so
RUN a2enmod dumpost
