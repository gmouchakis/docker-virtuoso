FROM stain/virtuoso

MAINTAINER Yiannis Mouchakis <gmouchakis@gmail.com>

COPY docker-entrypoint.sh /
RUN chmod 755 /usr/local/bin/staging.sh /docker-entrypoint.sh


# Modify config-file on start-up to reflect memory available
ENTRYPOINT ["/docker-entrypoint.sh"]
# Run virtuoso in the foreground
CMD ["/usr/bin/virtuoso-t", "+wait", "+foreground", "+configfile", "/etc/virtuoso-opensource-7/virtuoso.ini"]

