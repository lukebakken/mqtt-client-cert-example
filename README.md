# Environment setup

RabbitMQ 3.9.14, Erlang 23.3.3 on Arch Linux

```
$ ./sbin/rabbitmq-plugins list
Listing plugins with pattern ".*" ...
 Configured: E = explicitly enabled; e = implicitly enabled
 | Status: [failed to contact rabbit@shostakovich - status not shown]
 |/
[  ] rabbitmq_amqp1_0                  3.7.13
[  ] rabbitmq_auth_backend_cache       3.7.13
[  ] rabbitmq_auth_backend_http        3.7.13
[  ] rabbitmq_auth_backend_ldap        3.7.13
[  ] rabbitmq_auth_mechanism_ssl       3.7.13
[  ] rabbitmq_consistent_hash_exchange 3.7.13
[  ] rabbitmq_event_exchange           3.7.13
[  ] rabbitmq_federation               3.7.13
[  ] rabbitmq_federation_management    3.7.13
[  ] rabbitmq_jms_topic_exchange       3.7.13
[E ] rabbitmq_management               3.7.13
[e ] rabbitmq_management_agent         3.7.13
[E ] rabbitmq_mqtt                     3.7.13
[  ] rabbitmq_peer_discovery_aws       3.7.13
[  ] rabbitmq_peer_discovery_common    3.7.13
[  ] rabbitmq_peer_discovery_consul    3.7.13
[  ] rabbitmq_peer_discovery_etcd      3.7.13
[  ] rabbitmq_peer_discovery_k8s       3.7.13
[  ] rabbitmq_random_exchange          3.7.13
[  ] rabbitmq_recent_history_exchange  3.7.13
[  ] rabbitmq_sharding                 3.7.13
[  ] rabbitmq_shovel                   3.7.13
[  ] rabbitmq_shovel_management        3.7.13
[  ] rabbitmq_stomp                    3.7.13
[  ] rabbitmq_top                      3.7.13
[  ] rabbitmq_tracing                  3.7.13
[E ] rabbitmq_trust_store              3.7.13
[e ] rabbitmq_web_dispatch             3.7.13
[  ] rabbitmq_web_mqtt                 3.7.13
[  ] rabbitmq_web_mqtt_examples        3.7.13
[  ] rabbitmq_web_stomp                3.7.13
[  ] rabbitmq_web_stomp_examples       3.7.13
```

`certs_1` and `certs_2` were generated from two runs of `tls-gen`'s `basic` profile:

```
git clone https://github.com/michaelklishin/tls-gen.git
cd tls-gen/basic
make
```

RabbitMQ is configured to allow certs signed by the `certs_1` CA (due to the symlink in the `ca_certs` dir). The `mqtt.py` code will present certs from the `certs_2` directory. When run, the connection is refused, as expected:

```
$ python ./mqtt.py
Traceback (most recent call last):
  File "./mqtt.py", line 33, in <module>
    client.connect("localhost", 8883, 60)
  File "/home/lbakken/issues/stack-overflow/tls-trust-store-55179047/venv/3.7.2/lib/python3.7/site-packages/paho/mqtt/client.py", line 839, in connect
    return self.reconnect()
  File "/home/lbakken/issues/stack-overflow/tls-trust-store-55179047/venv/3.7.2/lib/python3.7/site-packages/paho/mqtt/client.py", line 994, in reconnect
    sock.do_handshake()
  File "/usr/lib64/python3.7/ssl.py", line 1117, in do_handshake
    self._sslobj.do_handshake()
ssl.SSLError: [SSL: TLSV1_ALERT_UNKNOWN_CA] tlsv1 alert unknown ca (_ssl.c:1056)
```
