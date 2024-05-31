$ProgressPreference = 'Continue'
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

New-Variable -Name curdir -Option Constant `
  -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)
New-Variable -Name curdir_fwd_slash -Option Constant -Value ($curdir -Replace '\\','/')

New-Variable -Name rabbitmq_version -Option Constant -Value '3.13.2'

New-Variable -Name rabbitmq_dir -Option Constant -Value `
    (Join-Path -Path $curdir -ChildPath "rabbitmq_server-$rabbitmq_version")

New-Variable -Name rabbitmq_sbin -Option Constant -Value `
	(Join-Path -Path $rabbitmq_dir -ChildPath 'sbin')

New-Variable -Name rabbitmqctl_cmd -Option Constant -Value `
	(Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmqctl.bat')

New-Variable -Name commonName -Option Constant -Value `
    ((openssl x509 -noout -subject -nameopt multiline -in tls-gen/basic/result/client_certificate.pem | Select-String -SimpleMatch -CaseSensitive -Pattern commonName) -Split '=')[1].Trim()

& $rabbitmqctl_cmd add_user "$commonName" password_unused
& $rabbitmqctl_cmd set_permissions "$commonName" '.*' '.*' '.*'
