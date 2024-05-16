#!/bin/bash

# Typeset book _Print This_
# Copyright (C) 2024  Adam Monsen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

##############################################################
# Performs typesetting in a container.                       #
# Requires Docker.                                           #
##############################################################

set -o errexit
set -o nounset
set -o pipefail

SECONDS=0
echo "🏗️	start at $(date)"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_NAME=asciidoctor-lists-repro01
WORK_DIR=/usr/src/app/book
GID="$(id -g)"
GROUP="$(id -gn)"
BUILD_DATE_TIME="$(date)"
BUILD_LOCALE_LANG="${LANG:-en_US.UTF-8}"
BUILD_GIT_COMMIT="$(git rev-parse --short HEAD || echo FIXME)"
BUILD_OS_RELEASE="$(lsb_release --short --description || echo FIXME)"

echo '🚢	build image'
cd "$SCRIPT_DIR"
# discard container checksum
sudo docker build \
    --tag $IMAGE_NAME \
    --build-arg WORK_DIR="$WORK_DIR" \
    --build-arg USER="$USER" \
    --build-arg UID="$UID" \
    --build-arg GROUP="$GROUP" \
    --build-arg GID="$GID" \
    --quiet \
    . \
    > /dev/null

echo '🚢	start container'
sudo docker run \
    --rm \
    --interactive \
    --tty \
    --user "$USER:$GROUP" \
    --volume "$SCRIPT_DIR:$WORK_DIR" \
    --env BUILD_DATE_TIME="$BUILD_DATE_TIME" \
    --env BUILD_LOCALE_LANG="$BUILD_LOCALE_LANG" \
    --env BUILD_GIT_COMMIT="$BUILD_GIT_COMMIT" \
    --env BUILD_OS_RELEASE="$BUILD_OS_RELEASE" \
    $IMAGE_NAME

echo "🏗️	done (${SECONDS}s elapsed)"
