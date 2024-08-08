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
  if ($i.source) {
    $d1path = Join-Path $git_path $i.source
  } else {
    $d1path = $null
  }
  $d2path = Join-Path $git_path $i.target
  
  try {
    $d1 = [datetime](Get-ItemProperty -Path $d1path -Name LastWriteTime -ErrorAction Stop).LastWriteTime
  }
  catch {
    # No destination file 
    $d1 = [datetime](Get-ItemProperty -Path $project_path -Name LastWriteTime).LastWriteTime
  }
  

  try {
    $d2 = [datetime](Get-ItemProperty -Path $d2path -Name LastWriteTime -ErrorAction Stop).LastWriteTime
  }
  catch {
    # No destination file 
    $d2 = [datetime](Get-Date -Date "01-01-1970" )
  }



  if ($d1 -gt $d2) {
    Write-Host $i.description
    Write-Host $i.source " -> " $i.target
    switch ($i.operation) {
      Copy {
        Copy-Item $d1path -Destination $d2path
      }
      table-template-copy {
        m4 -D __TABLE_NAME__="$($i.table_name)" -D __TABLE_OWNER__="$($i.table_owner)" -D __KEYSEQUENCE__="$($i.PKSEQ)" -D __PK__="$($i.PK)" -D __TABLEDEF__="$($d1path)" (Join-Path $PSScriptRoot "/templates/newtable.m4") > $d2path
      }
      rollout-fields {
        $fieldlist = ""
        $typeslist = ""
        foreach ($j in $i.fields) {
          $fieldlist = "$($fieldlist)$($j.name);"
          $typeslist = "$($typeslist)$($j.type);"
        }
        m4 -D __TABLE_NAME__="$($i.table_name)" -D __TABLE_OWNER__="$($i.table_owner)" -D __FIELDS_LIST__="$($fieldlist)" -D __DATA_TYPES__="$($typeslist)" (Join-Path $PSScriptRoot "/templates/appendfields.m4") > $d2path
      }

    }
  }
}