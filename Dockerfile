FROM centos:centos8

RUN dnf -y --setopt=tsflags=nodocs install python3 mariadb-connector-c postgresql httpd python3-mod_wsgi mod_ssl && \
    dnf clean all

# Apache configuration for non-root users
EXPOSE 8080
EXPOSE 8443
COPY ./httpd-foreground /httpd-foreground
CMD /httpd-foreground
RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf && \
    sed -i 's/Listen 443/Listen 8443/' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's!ErrorLog "logs/error_log"!ErrorLog "/dev/stderr"!' /etc/httpd/conf/httpd.conf && \
    sed -i 's!CustomLog "logs/access_log"!CustomLog "/dev/stdout"!' /etc/httpd/conf/httpd.conf && \
    sed -i 's!ErrorLog logs/ssl_error_log!ErrorLog "/dev/stderr"!' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's!TransferLog logs/ssl_access_log!TransferLog "/dev/stdout"!' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's!CustomLog logs/ssl_request_log!CustomLog "/dev/stdout"!' /etc/httpd/conf.d/ssl.conf && \
    rm -rf /run/httpd && mkdir /run/httpd && chmod -R a+rwx /run/httpd
COPY ./etc/kiwi-httpd.conf /etc/httpd/conf.d/

ENV PATH /venv/bin:${PATH} \
    VIRTUAL_ENV /venv

# copy virtualenv dir which has been built inside the kiwitcms/buildroot container
# this helps keep -devel dependencies outside of this image
COPY ./dist/venv/ /venv

COPY ./manage.py /Kiwi/
COPY ./etc/kiwitcms/ssl/ /Kiwi/ssl/
RUN sed -i "s/tcms.settings.devel/tcms.settings.product/" /Kiwi/manage.py && \
    ln -s /Kiwi/ssl/localhost.crt /etc/pki/tls/certs/localhost.crt && \
    ln -s /Kiwi/ssl/localhost.key /etc/pki/tls/private/localhost.key

# create a mount directory so we can properly set ownership for it
RUN mkdir /Kiwi/uploads

# collect static files
RUN /Kiwi/manage.py collectstatic --noinput --link

# from now on execute as non-root
RUN chown -R 1001 /Kiwi/ /venv/
USER 1001
