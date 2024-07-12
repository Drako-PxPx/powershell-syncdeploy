param (
  [Parameter(Mandatory=$false)][string]$project
)

$git_path = Join-Path $PSScriptRoot "../git"
if (-not $project) {
  $project = git -C $git_path branch --show-current
}

$project_path = Join-Path $PSScriptRoot "projects\$($project).json"

$myJson = Get-Content $project_path -Raw | ConvertFrom-Json
Write-Host $myJson.branchName

foreach ($i in $myJson.transitions) {
  # Write-Host $i.description
  $d1path = Join-Path $git_path $i.source
  $d2path = Join-Path $git_path $i.target
  $d1 = [datetime](Get-ItemProperty -Path $d1path -Name LastWriteTime).LastWriteTime
  $d2 = [datetime](Get-ItemProperty -Path $d2path -Name LastWriteTime).LastWriteTime

  if ($d1 -gt $d2) {
    Write-Host $i.description
    Write-Host $i.source " -> " $i.target
    switch ($i.operation) {
      Copy {
        Copy-Item $d1path -Destination $d2path
      }
      template-copy {
        m4 -D __TABLE_NAME__="$($i.table_name)" -D __TABLE_OWNER__="$($i.table_owner)" -D __KEYSEQUENCE__="$($i.PKSEQ)" -D __PK__="$($i.PK)" -D __TABLEDEF__="$($d1path)" (Join-Path $PSScriptRoot "/templates/$($i.template)") > $d2path
      }
    }
  }
}