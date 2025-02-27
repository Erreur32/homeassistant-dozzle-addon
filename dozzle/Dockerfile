ARG BUILD_FROM
FROM $BUILD_FROM

LABEL io.hass.type="addon"
LABEL io.hass.name="Dozzle"
LABEL io.hass.version="1.0.0"

COPY dozzle/run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
