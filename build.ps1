# Builds index.html from policy.json (all languages on one page, English first).
$here = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$data = [IO.File]::ReadAllText((Join-Path $here 'policy.json'), $utf8) | ConvertFrom-Json
function E([string]$s) { [System.Net.WebUtility]::HtmlEncode($s) }

$nav = ($data.languages | ForEach-Object { "<a href=`"#$($_.code)`" hreflang=`"$($_.code)`">$(E $_.label)</a>" }) -join ''
$sections = foreach ($l in $data.languages) {
    $dir = if ($l.rtl) { ' dir="rtl"' } else { '' }
    $body = foreach ($s in $l.sections) {
        $text = if ($s[1] -eq '@email') { "<a href=`"mailto:$($data.email)`">$($data.email)</a>" } else { E $s[1] }
        "    <h3>$(E $s[0])</h3>`n    <p>$text</p>"
    }
    @"
  <section id="$($l.code)" lang="$($l.code)"$dir>
    <h2>$(E $l.title)</h2>
    <p class="updated">$(E $l.updated)</p>
    <p class="lead">$(E $l.lead)</p>
$($body -join "`n")
  </section>
"@
}

$html = [IO.File]::ReadAllText((Join-Path $here 'template.html'), $utf8).
    Replace('{{nav}}', $nav).
    Replace('{{sections}}', ($sections -join "`n"))
[IO.File]::WriteAllText((Join-Path $here 'index.html'), $html, $utf8)
"index.html: $($data.languages.Count) languages"
