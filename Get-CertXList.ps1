[cmdletbinding()]
param (
    <#
        This parameter accepts the list (array) of servers to be checked.
    #>
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [array]
    $ServerList,

    <#
        This parameter indicates to return on certificates that are expiring in exactly X days.
        If not used, all certificates in LocalMachine\My will be reported
    #>
    [Parameter()]
    [int[]]
    $ExpiringInDays,

    <#
        List (array) of certificate thumbprint to be excluded
    #>
    [Parameter()]
    [array]
    $ExclusionList
)

$today = Get-Date
$finalResult = @()

foreach ($server in $ServerList) {

    $certObjectList = Invoke-Command -ComputerName ($server) -ScriptBlock {
        Get-ChildItem "Cert:\LocalMachine\My"
    }

    if ($certObjectList) {
        foreach ($certObject in $certObjectList) {

            if ($ExclusionList -contains $certObject.Thumbprint) {
                continue
            }

            # Calculate remaining days before expiration.
            $DaysLeft = (New-TimeSpan -Start $today -End ($certObject.NotAfter)).Days

            # Create temp object to hold values
            $tempObj = [ordered]@{
                PSTypeName                = 'LazyExchangeAdmin.Certificate.Report'
                "Server Name"             = $server
                "Certificate Name"        = ($certObject.Subject)
                "Certificate Thumbprint"  = ($certObject.Thumbprint)
                "Certificate Valid From"  = ($certObject.NotBefore)
                "Certificate Valid Until" = ($certObject.NotAfter)
                "Day(s) Remaining"        = $DaysLeft
            }

            # If ExpiringInDays is not specified, add the object to the report.
            if (!$ExpiringInDays) {
                $finalResult += New-Object psobject -property $tempObj
            }

            # If ExpiringInDay is specified, compare the remaining days with the threshold.
            if ($ExpiringInDays) {
                foreach ($day in $ExpiringInDays) {
                    # If remaining days is equal to the threshold, add the object to the report.
                    if ($DaysLeft -eq $day) {
                        $finalResult += New-Object psobject -property $tempObj
                    }
                }
            }
        }
    }
}
return $finalResult

