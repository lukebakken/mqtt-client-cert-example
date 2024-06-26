#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

# shellcheck disable=SC2155
readonly script_dir="$(cd "$(dirname "$0")" && pwd)"

readonly rmq_version='3.13.2'
readonly rmq_xz="$script_dir/rabbitmq-server-generic-unix-$rmq_version.tar.xz"
readonly rmq_dir="$script_dir/rabbitmq_server-$rmq_version"
readonly rmq_etc_dir="$rmq_dir/etc/rabbitmq"
readonly rmq_sbin_dir="$rmq_dir/sbin"
readonly rmq_server="$rmq_sbin_dir/rabbitmq-server"
readonly rmq_ctl="$rmq_sbin_dir/rabbitmqctl"

function on_exit
{
    set +o errexit
    echo '[INFO] exiting!'
}
trap on_exit EXIT

if [[ ! -s $rmq_xz ]]
then
    curl -LO "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$rmq_version/rabbitmq-server-generic-unix-$rmq_version.tar.xz"
    tar xf "$rmq_xz"
fi

readonly rmq_plugins="$rmq_sbin_dir/rabbitmq-plugins"
if [[ -x $rmq_plugins ]]
then
    "$rmq_plugins" enable rabbitmq_management rabbitmq_mqtt rabbitmq_auth_mechanism_ssl
else
    echo "[ERROR] expected to find '$rmq_plugins', exiting" 1>&2
    exit 69
fi

# Set up Python virtualenv and install paho.mqtt
readonly venv_dir="$script_dir/venv"
readonly venv_activate="$script_dir/venv/bin/activate"
if [[ ! -x $venv_activate ]]
then
    python -m venv "$venv_dir"
fi
# shellcheck disable=SC1090
source "$venv_activate"
pip install paho.mqtt

# Create certificates
git submodule update --init
readonly tls_gen_basic_dir="$script_dir/tls-gen/basic"
readonly tls_gen_result_dir="$tls_gen_basic_dir/result"
if [[ ! -d $tls_gen_result_dir ]]
then
    make -C "$tls_gen_basic_dir"
    make -C "$tls_gen_basic_dir" alias-leaf-artifacts
fi

# Generate RabbitMQ conf file
sed -e "s|##TLS_GEN_RESULT_DIR##|$tls_gen_result_dir|" "$script_dir/rabbitmq.conf.in" > "$rmq_etc_dir/rabbitmq.conf"

# Start RabbitMQ and wait
"$rmq_server" -detached
sleep 5
readonly cn="$(openssl x509 -noout -subject -nameopt multiline -in tls-gen/basic/result/client_certificate.pem | awk '/commonName/ { print $3 }')"
set +o errexit
"$rmq_ctl" add_user "$cn" password_unused
"$rmq_ctl" set_permissions "$cn" '.*' '.*' '.*'
set -o errexit

# Start Python program
python "$script_dir/mqtt.py"
