#!/bin/sh
echo "The shell is $SHELL"
set -e
PIP_INSTALL="pip install --use-mirrors"
[ -n "$DAV_SERVER" ] || DAV_SERVER=radicale_filesystem
[ -n "$REQUIREMENTS" ] || REQUIREMENTS=release

$PIP_INSTALL --editable .
$PIP_INSTALL -r requirements.txt

davserver_radicale_filesystem() {
    radicale_deps
}

davserver_radicale_database() {
    radicale_deps
    $PIP_INSTALL sqlalchemy pysqlite
}

radicale_deps() {
    if [ "$REQUIREMENTS" = "release" ]; then
        radicale_pkg="radicale"
    elif [ "$REQUIREMENTS" = "devel" ]; then
        radicale_pkg="git+https://github.com/Kozea/Radicale.git"
    else
        echo "Invalid requirements envvar"
        false
    fi
    $PIP_INSTALL werkzeug $radicale_pkg
}

davserver_owncloud() {
    # Maybe tmpfs is mounted on /tmp/, can't harm anyway.
    if [ ! -d ./owncloud-testserver/ ]; then
        git clone --depth=1 \
            https://github.com/untitaker/owncloud-testserver.git \
            /tmp/owncloud-testserver
        ln -s /tmp/owncloud-testserver .
    fi
    cd ./owncloud-testserver/
    sh install.sh
}


davserver_$DAV_SERVER
