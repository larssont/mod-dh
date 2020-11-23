$ErrorActionPreference = 'Stop';

$packageName  = 'colemak-mod-dh'
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$checksumFile = 'checksums.json'
$url          = 'https://github.com/ColemakMods/mod-dh/raw/master/klc/'

$locale = 'EN'
$arch = 'i386'
if (Get-ProcessorBits 64) {
    $arch = 'amd64'
}

$pp = Get-PackageParameters
$validLayouts = @{
  "dh_ansi_us"        = "usckdh"
  "dh_ansi_us_awing"  = "usckdha"
  "dh_ansi_us_wide"   = "usckdhw"
  "dh_iso_uk"         = "ukckdh"
  "dh_iso_uk_wide"    = "ukckdh"
  "dh_matrix_us"      = "usckdhm"
  "dhk_ansi_us"       = "usckdhk"
  "dhk_ansi_us_awing" = "usckdhka"
  "dhk_ansi_us_wide"  = "usckdhkw"
  "dhk_iso_uk"        = "ukckdhk"
  "dhk_iso_uk_wide"   = "ukckdhkw"
}

if (!$pp.layout) {
  $pp.layout = "dh_ansi_us"
}
if ($validLayouts.keys -notcontains $pp.layout) {
  throw 'Invalid option for parameter "layout", valid options are: ' + $validLayouts.keys
}
if ($pp.layout -Match "dhk") {
  $url += "Colemak-DHk/"
}

$url += "colemak_$($pp.layout).zip"
$layoutId = $validLayouts[$pp.layout]

$fileLocation = Join-Path $toolsDir "$layoutId`_$arch.msi"
$checksums = Get-Content -Raw -Path (Join-Path $toolsDir $checksumFile) | ConvertFrom-Json

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url           = $url
  file          = $fileLocation
  silentArgs    = "/qn /norestart /l*v `"$env:TEMP\chocolatey\$($packageName)\$($packageName).MsiInstall.log`" ALLUSERS=1"
  validExitCodes= @(0, 3010, 1641)
  softwareName  = 'colemak-mod-dh*'
  checksum      = $checksums.$layout
  checksumType  = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

Get-ChildItem -recurse $toolsDir -filter setup.exe | foreach {
    $ignoreFile = $_.FullName + '.ignore'
    Set-Content -Path $ignoreFile -Value ($null)
}

Install-ChocolateyInstallPackage @packageArgs