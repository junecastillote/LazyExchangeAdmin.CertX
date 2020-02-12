[cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $InputObject,

    [Parameter()]
    [ValidateSet('Alert','Report')]
    [string]
    $Mode = 'Report',

    [Parameter()]
    [int[]]
    $ExpiringInDays = 7
)

$today = Get-Date
$finalResult = @()

foreach ($item in $InputObject) {

    $ThresholdDays = ($ExpiringInDays -split ",")

    $certObject = Invoke-Command -ComputerName ($item.Server) -ScriptBlock {
        Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq ($using:item.Thumbprint)}
    }

    if ($certObject) {
        foreach ($day in $ThresholdDays) {
            $DaysLeft = (New-TimeSpan -Start $today -End ($certObject.NotAfter)).Days

            $tempObj = [ordered]@{
                PSTypeName = "LazyExchangeAdmin.Certificate.$Mode"
                "Server Name"             = ($item.Server)
                "Certificate Name"        = ($certObject.Subject)
                "Certificate Thumbprint"  = ($certObject.Thumbprint)
                "Certificate Valid From"  = ($certObject.NotBefore)
                "Certificate Valid Until" = ($certObject.NotAfter)
                "Day(s) Remaining"        = $DaysLeft
            }

            if ($Mode -eq 'Report') {
                $finalResult += New-Object psobject -property $tempObj
            }

            if ($Mode -eq 'Alert') {
                if ($DaysLeft -eq $day) {
                    $finalResult += New-Object psobject -property $tempObj
                }
            }
        }
    }
}
return $finalResult