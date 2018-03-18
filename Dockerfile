FROM nishith
COPY abc.sh /
RUN /bin/bash /abc.sh
CMD service nginx start && service php7.0-fpm start && tail -f /var/log/syslog
