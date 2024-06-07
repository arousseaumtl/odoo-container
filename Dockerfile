FROM debian:latest AS cloner

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
    && git clone --depth 1 https://github.com/odoo/odoo.git /tmp/odoo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM debian:latest

ENV PATH="/home/odoo/pythonenv/bin:$PATH"

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        libpq-dev \
        curl \
        libldap2-dev \
        libsasl2-dev \
        vim \
        build-essential \
        gettext-base \
        postgresql-client \
        wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd odoo && useradd -m -g odoo odoo

WORKDIR /home/odoo

USER odoo

COPY --from=cloner --chown=odoo:odoo /tmp/odoo/ ./

RUN python3 -m venv /home/odoo/pythonenv \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && mkdir -pv /home/odoo/custom-addons

COPY --chown=odoo:odoo entrypoint.sh odoo.conf.template ./
COPY --chown=odoo:odoo custom-addons/ ./custom-addons/

ENTRYPOINT ["/usr/bin/bash", "entrypoint.sh"]
CMD ["python", "odoo-bin", "-c", "odoo.conf"]
