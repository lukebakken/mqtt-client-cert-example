
# Start RabbitMQ

NOTE: this will also create certs using the `COMPUTERNAME` env variable for `CN=`

```
.\setup.ps1
```

# Add user

```
.\add-user.ps1
```

# Run MQTT mqtt client

NOTE: client authenticates using X509 client cert

```
pipenv install
pipenv run mqtt
```

# Encrypting value

NOTE: this is using `cmd.exe`:

```
C:\Users\lbakken\development\lukebakken\mqtt-client-cert-example>.\rabbitmq_server-3.13.2\sbin\rabbitmqctl.bat encode --cipher aes_256_cbc --hash sha512 --iterations 1000 """grapefruit""" rabbitmq-server-11347
Encrypting value ...
{encrypted,<<"fHrsMqvZGNbxwujPMDTjwQ61Pu9weIZDgqnEyATvnZrNIEi5HmJSr4qCRGn7ljLI">>}

C:\Users\lbakken\development\lukebakken\mqtt-client-cert-example>.\rabbitmq_server-3.13.2\sbin\rabbitmqctl.bat decode --cipher aes_256_cbc --hash sha512 --iterations 1000 "{encrypted,<<""fHrsMqvZGNbxwujPMDTjwQ61Pu9weIZDgqnEyATvnZrNIEi5HmJSr4qCRGn7ljLI"">>}" rabbitmq-server-11347
Decrypting value...
"grapefruit"
```
