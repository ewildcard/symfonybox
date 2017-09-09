#!/bin/bash

function system_update {
  # Update OS
  lsb_release -a

  echo -e "\n--- Ubuntu updating ---"
  sudo apt-get update        # Fetches the list of available updates
  sudo apt-get upgrade       # Strictly upgrades the current packages
  sudo apt-get dist-upgrade  # Installs updates (new ones), will not upgrade to a new Ubuntu release
  sudo apt-get autoremove    # Remove any install packages
  echo Update complete

  echo -e "\n--- Ubuntu version info now: ---"
  lsb_release -a
}

system-escape() {
  local glue
  glue=${1:--}
  while read arg; do
    echo "${arg,,}" | sed -e 's#[^[:alnum:]]\+#'"$glue"'#g' -e 's#^'"$glue"'\+\|'"$glue"'\+$##g'
  done
}

php-settings-update() {
  local args
  local settings_name
  local php_ini
  local php_extra
  args=( "$@" )
  PREVIOUS_IFS="$IFS"
  IFS='='
  args="${args[*]}"
  IFS="$PREVIOUS_IFS"
  settings_name="$( echo "$args" | system-escape )"
  for php_ini in $( $SUDO find /etc -type f -iname 'php*.ini' ); do
    php_extra="$( dirname "$php_ini" )/conf.d"
    $SUDO mkdir -p "$php_extra"
    echo "$args" | $SUDO tee "$php_extra/0-$settings_name.ini" >/dev/null
  done
}

