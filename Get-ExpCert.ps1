[cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $InputObject
)

$today = Get-Date
$finalResult = @()

foreach ($item in $InputObject) {

    $DaysToExpire = ($item.DaysToExpire -split ",")
    $certObject = Get-ExchangeCertificate -Server ($item.server) -Thumbprint ($item.Thumbprint) -ErrorAction STOP

    foreach ($day in $DaysToExpire) {
        $DaysLeft = (New-TimeSpan -Start $today -End ($certObject.NotAfter)).Days

        if ($DaysLeft -eq $day) {
            $tempObj = [ordered]@{
                "Server Name"             = ($item.Server)
                "Certificate Name"        = ($certObject.Subject)
                "Certificate Thumbprint"  = ($certObject.Thumbprint)
                "Certificate Valid Until" = ($certObject.NotAfter)
                "Day(s) Remaining"        = $DaysLeft
            }
            $finalResult += New-Object psobject -property $tempObj
        }
    }
}
return $finalResult