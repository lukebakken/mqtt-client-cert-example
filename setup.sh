#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# shellcheck disable=SC2155
readonly script_dir="$(cd "$(dirname "$0")" && pwd)"

readonly rmq_version='3.9.14'
readonly rmq_xz="$script_dir/rabbitmq-server-generic-unix-$rmq_version.tar.xz"
readonly rmq_dir="$script_dir/rabbitmq_server-$rmq_version"

if [[ ! -s $rmq_xz ]]
then
    curl -LO "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$rmq_version/rabbitmq-server-generic-unix-$rmq_version.tar.xz"
    tar xf "$rmq_xz"
fi

readonly rmq_plugins="$rmq_dir/sbin/rabbitmq-plugins"
if [[ -x $rmq_plugins ]]
then
    "$rmq_plugins" enable rabbitmq_management rabbitmq_mqtt
else
    echo "[ERROR] expected to find '$rmq_plugins', exiting" 1>&2
    exit 69
fi

readonly venv_dir="$script_dir/venv"
readonly venv_activate="$script_dir/venv/bin/activate"
if [[ ! -x $venv_activate ]]
then
    python -m venv "$venv_dir"
fi

source "$venv_activate"

pip install paho.mqtt
