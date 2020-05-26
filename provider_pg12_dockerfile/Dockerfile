FROM ubuntu:xenial

ADD install.sh /
ADD db_setup.sh /
RUN chmod +x /install.sh /db_setup.sh
RUN /install.sh
# cleanup once complete
RUN rm /install.sh

# setup the postgres db with pgextwlist
USER postgres
RUN /db_setup.sh

USER root
RUN rm /db_setup.sh

EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql", "/database"]

# RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/12/main/pg_hba.conf

USER postgres

# from terminal: docker run --publish 5433:5432  --network postgres-network --name sample [image_id]
# Debugging image build failures: docker run -it [image_id] /bin/bash
#
# Original command: CMD ["/usr/lib/postgresql/12/bin/pg_ctl",  "-D", "/database", "-l", "/logfile", "start"]
# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/database", "-c", "config_file=/database/postgresql.conf"]
