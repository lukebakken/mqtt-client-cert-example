# Environment setup

RabbitMQ 3.12.1, Erlang 26.0.2 on Arch Linux

Run `setup.sh`, which will download RabbitMQ, set up configuration, set up certificates, set up Python, and start the test application.

You can locate and inspect the generated configuration file like this:

```
lbakken@shostakovich ~/development/lukebakken/mqtt-client-cert-example (main *=)
$ cat rabbitmq_server-3.12.1/etc/rabbitmq/rabbitmq.conf
loopback_users = none

log.file.level = debug

auth_mechanisms.1 = EXTERNAL
auth_mechanisms.2 = PLAIN
auth_mechanisms.3 = AMQPLAIN

ssl_options.certfile   = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/server_certificate.pem
ssl_options.keyfile    = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/server_key.pem
ssl_options.cacertfile = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/ca_certificate.pem
ssl_options.verify     = verify_peer
ssl_options.fail_if_no_peer_cert  = true
ssl_cert_login_from = common_name

listeners.tcp.default = 5672
listeners.ssl.default = 5671

mqtt.listeners.tcp.default = 1883
mqtt.listeners.ssl.default = 8883
mqtt.ssl_cert_login = true
mqtt.allow_anonymous = true

management.tcp.port = 15672
management.ssl.port = 15671

management.ssl.certfile   = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/server_certificate.pem
management.ssl.keyfile    = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/server_key.pem
management.ssl.cacertfile = /home/lbakken/development/lukebakken/mqtt-client-cert-example/tls-gen/basic/result/ca_certificate.pem
```
