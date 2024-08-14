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


$output_file = "_output/$($stamp)_$($tnsstring).json"
sqlcmd -script object_statuses |  ConvertFrom-Json -ErrorAction stop | ConvertTo-Json | Out-File -FilePath $output_file

