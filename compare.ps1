param (
  [Parameter(Mandatory=$false)][string]$project
)

# TODO: Write a validation when target value is missing
# TODO: Add a validation when the target does not hold a # character

# $git_path = Join-Path $PSScriptRoot "../git"
Write-Host $PSScriptRoot
if (-not $project) {
  $project = git -C $git_path branch --show-current
}

$project_path = Join-Path $PSScriptRoot "projects\$($project).json"


$myJson = Get-Content $project_path -Raw | ConvertFrom-Json
Write-Host $myJson.branchName
$git_path = $myJson.project_path
$deployment_path = $myJson.deployment_path
$trnbr = 0

foreach ($i in $myJson.transitions) {
  $trnbr = $trnbr + 1
  if ($i.source) {
    $d1path = Join-Path $git_path $i.source
  } else {
    $d1path = $null
  }
  $d2path = Join-Path $git_path $deployment_path
  $d2path = Join-Path $d2path $i.target.Replace("#",$trnbr.ToString('00'))
  
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
        m4 -D __TABLE_NAME__="$($i.table_name)" -D __TABLE_OWNER__="$($i.table_owner)" -D __FIELDS_LIST__="$($fieldlist)" -D __DATA_TYPES__="$($typeslist)" -I (Join-Path $PSScriptRoot "/templates/lib") (Join-Path $PSScriptRoot "/templates/appendfields.m4") > $d2path
      }
      rollout-indexes {
        $indexlist = ""
        $columnlist = ""
        foreach ($j in $i.indexes) {
          $indexlist  = "$($indexlist)$($j.name);"
          $columnlist = "$($columnlist)$($j.column);"
        }
        m4 -D __TABLE_NAME__="$($i.table_name)" -D __TABLE_OWNER__="$($i.table_owner)" -D __IX_TBS__="$($i.tablespace)" -D __INDEX_LIST__="$($indexlist)" -D __INDEX_COLUMNS__="$($columnlist)" -I (Join-Path $PSScriptRoot "/templates/lib") (Join-Path $PSScriptRoot "/templates/indextable.m4") > $d2path
      }
    }
  }
}