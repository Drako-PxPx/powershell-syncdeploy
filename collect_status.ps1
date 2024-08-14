param (
  [Parameter(Mandatory=$true)][string]$tnsstring
)

function sqlcmd {
  param (
    [string]$script,
    [string]$par1,
    [string]$par2
  )

   $output = sqlplus -L -S /@$tnsstring @$script.sql $par1 $par2
   Write-Output $output
}



$object_types = @('SYNONYM','PACKAGE BODY','TYPE BODY','TRIGGER','PACKAGE','PROCEDURE','FUNCTION','TYPE','MATERIALIZED VIEW','VIEW')
$env:SQLPATH = "sql"

$stamp = $(Get-Date).ToString("yyyyMMddHHmm");

New-Item -Path "_output" -Name $stamp -ItemType Directory
$job_count=0
$owners = $(sqlcmd -script list_owners).split(';')
foreach ($owner in $owners) {
  if ($owner) {
    foreach ($objecttype in $object_types) {
      $output_file = "_output/$($stamp)/$($owner)_$($objecttype).json"
      # Write-Host $output_file
      $job_count = $job_count + 1
      $pc = ($job_count / ($owners.count * $object_types.count))*100
      Write-Progress -Activity "Collecting current object statuses" -PercentComplete $pc -CurrentOperation "Schema: $($owner), Set: $($objecttype)"
      try {
        sqlcmd -script object_statuses -par1 $owner -par2 $objecttype |  ConvertFrom-Json -ErrorAction stop | ConvertTo-Json | Out-File -FilePath $output_file
      } catch
      {
        Write-Host "Schema: $($owner), Set: $($objecttype)"
      }

    }
  }
}
