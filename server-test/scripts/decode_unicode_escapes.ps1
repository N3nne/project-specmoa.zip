param(
  [string[]]$Paths
)

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Convert-UnicodeEscapes([string]$content) {
  return [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    '\\u([0-9A-Fa-f]{4})',
    {
      param($match)
      $code = [Convert]::ToInt32($match.Groups[1].Value, 16)
      return [char]$code
    }
  )
}

foreach ($path in $Paths) {
  if (-not (Test-Path $path)) {
    continue
  }

  $item = Get-Item $path
  if ($item.PSIsContainer) {
    $files = Get-ChildItem -Path $path -Recurse -Include *.dart,*.ts -File
  } else {
    $files = @($item)
  }

  foreach ($file in $files) {
    $original = [System.IO.File]::ReadAllText($file.FullName)
    $converted = Convert-UnicodeEscapes $original

    if ($converted -ne $original) {
      [System.IO.File]::WriteAllText($file.FullName, $converted, $utf8NoBom)
      Write-Output "Converted: $($file.FullName)"
    }
  }
}
