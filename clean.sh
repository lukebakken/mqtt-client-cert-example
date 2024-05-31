#!/bin/bash

set -o nounset
# set -o xtrace

# shellcheck disable=SC2155
readonly script_dir="$(cd "$(dirname "$0")" && pwd)"

readonly rmq_version='3.13.2'
readonly rmq_xz="$script_dir/rabbitmq-server-generic-unix-$rmq_version.tar.xz"
readonly rmq_dir="$script_dir/rabbitmq_server-$rmq_version"
readonly venv_dir="$script_dir/venv"
readonly tls_gen_dir="$script_dir/tls-gen"

rm -f "$rmq_xz"
rm -rf "$rmq_dir"
rm -rf "$venv_dir"
{
    cd "$tls_gen_dir"
    git clean -xffd
}
