#!/bin/sh
# Copyright (c) 2020 vm75 <vm75dev@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# MiniDLNA container may fail to restart, because a previous lock may exist:
# let's shoot it!
/bin/rm -rf /var/run/minidlna

CONF_FILE=/etc/minidlna.conf

for SETTING in $(env) ; do
  if [[ "${SETTING:0:11}" = MINIDLNA_ ]]; then
    key=$(echo "${SETTING}" | sed -r "s/MINIDLNA_(.*)=.*/\\1/g" | tr '[:upper:]' '[:lower:]')
    value=$(echo "${SETTING}" | sed -r "s/.*=(.*)/\\1/g")

    case ${key} in
    user | friendly_name | serial | model_number | max_connections | strict_dlna | notify_interval | enable_tivo | tivo_discovery | transcode_* )
        /bin/sed "s/^${key}=.*/${key}=${value}/" -i ${CONF_FILE}
        ;;
    album_art_names)   # append
        /bin/sed "s/^album_art_names=\(.*\)/album_art_names=\1\/${value}/" -i ${CONF_FILE}
        ;;
    port | media_dir | db_dir) # ignore these as they are mounted
        ;;
    *)
        echo "${key}=${value}" >> ${CONF_FILE}
        ;;
    esac
  fi
done

minidlnad -d -f ${CONF_FILE}