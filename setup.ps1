$ProgressPreference = 'Continue'
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

New-Variable -Name curdir -Option Constant `
  -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)
New-Variable -Name curdir_fwd_slash -Option Constant -Value ($curdir -Replace '\\','/')

Write-Host "[INFO] script directory: $curdir"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 'Tls12'

New-Variable -Name rabbitmq_version -Option Constant -Value '3.13.2'

New-Variable -Name rabbitmq_dir -Option Constant -Value `
    (Join-Path -Path $curdir -ChildPath "rabbitmq_server-$rabbitmq_version")

New-Variable -Name rabbitmq_sbin -Option Constant -Value `
	(Join-Path -Path $rabbitmq_dir -ChildPath 'sbin')

New-Variable -Name rabbitmq_download_url -Option Constant -Value `
	"https://github.com/rabbitmq/rabbitmq-server/releases/download/v$rabbitmq_version/rabbitmq-server-windows-$rabbitmq_version.zip"

New-Variable -Name rabbitmq_zip_file -Option Constant -Value `
	(Join-Path -Path $curdir -ChildPath "rabbitmq-server-windows-$rabbitmq_version.zip")

New-Variable -Name rabbitmqctl_cmd -Option Constant -Value `
	(Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmqctl.bat')

New-Variable -Name rabbitmq_plugins_cmd -Option Constant -Value `
	(Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmq-plugins.bat')

New-Variable -Name rabbitmq_server_cmd -Option Constant -Value `
	(Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmq-server.bat')

New-Variable -Name rabbitmq_base -Option Constant -Value `
	(Join-Path -Path $curdir -ChildPath 'rmq')

New-Variable -Name rabbitmq_conf_in -Option Constant -Value `
	(Join-Path -Path $curdir -ChildPath 'rabbitmq.conf.in')

New-Variable -Name rabbitmq_conf_out -Option Constant -Value `
	(Join-Path -Path $rabbitmq_base -ChildPath 'rabbitmq.conf')

New-Variable -Name enabled_plugins_file -Option Constant -Value `
	(Join-Path -Path $curdir -ChildPath 'enabled_plugins')

New-Variable -Name enabled_plugins_file_out -Option Constant -Value `
	(Join-Path -Path $rabbitmq_base -ChildPath 'enabled_plugins')

if (!(Test-Path -Path $rabbitmq_dir))
{
    Invoke-WebRequest -Verbose -UseBasicParsing -Uri $rabbitmq_download_url -OutFile $rabbitmq_zip_file
    Expand-Archive -Path $rabbitmq_zip_file -DestinationPath $curdir
}

New-Variable -Name tls_gen_dir -Option Constant -Value `
    (Join-Path -Path $curdir -ChildPath 'tls-gen')
New-Variable -Name tls_gen_basic_dir -Option Constant -Value `
    (Join-Path -Path $tls_gen_dir -ChildPath 'basic')
New-Variable -Name tls_gen_basic_result_dir -Option Constant -Value `
    (Join-Path -Path $tls_gen_basic_dir -ChildPath 'result')
New-Variable -Name tls_gen_basic_result_dir_slashes -Option Constant -Value `
    ($tls_gen_basic_result_dir -Replace '\\','/')
New-Variable -Name ca_certfile -Option Constant -Value `
    (Join-Path -Path $tls_gen_basic_result_dir -ChildPath 'ca_certificate.pem')

& git submodule update --init

if (!(Test-Path -LiteralPath $ca_certfile))
{
    try
    {
        pushd $tls_gen_basic_dir
        & python .\profile.py --password=grapefruit --common-name=$env:COMPUTERNAME --days-of-validity=3650 --key-bits=4096 generate
        & python .\profile.py --common-name=$env:COMPUTERNAME alias-leaf-artifacts
    }
    finally
    {
        popd
    }
}

(Get-Content -Raw -Path $rabbitmq_conf_in) `
    -Replace '##TLS_GEN_RESULT_DIR##', $tls_gen_basic_result_dir_slashes | Set-Content -Path $rabbitmq_conf_out

Copy-Item -Verbose -Force -LiteralPath $enabled_plugins_file -Destination $enabled_plugins_file_out

$env:RABBITMQ_ALLOW_INPUT = 'true'
$env:RABBITMQ_BASE = $rabbitmq_base
& $rabbitmq_server_cmd
