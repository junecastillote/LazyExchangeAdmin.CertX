## START EDIT HERE

# [REQUIRED] Where can I find the module?
$modulePath = "C:\Scripts\CertX\LazyExchangeAdmin.CertX.psd1"

# [REQUIRED] Where will the HTML report be saved?
$reportFile = "C:\Scripts\CertX\CertReport.html"

# [REQUIRED] The servers to be monitored
$serverList = @('devpc')

# [OPTIONAL] Expiring in Days
$expiringInDays = @(7,15,30,60)

# [OPTIONAL] Excluded these thumbprints from the monitoring
$exclusionList = @('04F9D994251D33E155AB92593CA0D997D2126AC1')

# EMAIL PROPERTIES
$mailProps = @{
    SmtpServer = 'localhost'
    From = 'reports@posh.lab'
    To = 'admin@posh.lab','june@posh.lab'
    Subject = 'Certificate Expiration Report'
}

## END EDIT HERE

Import-Module $modulePath

$CertXProps = @{
    ServerList = $serverList
}

if ($expiringInDays) {
    $CertXProps.ExpiringInDays += $expiringInDays
    Write-Output ('>> Looking for certificates that will expire in exactly ' + ($expiringInDays -join ",") + ' day(s)')
}
if ($exclusionList) {
    $CertXProps.ExclusionList += $exclusionList
    Write-Output ('>> These certificates will be excluded:')
    Write-Output ($exclusionList -join "`n")
}

$certXobject = Get-CertXList @CertXProps

if ($certXobject) {
    Write-Output ('>> Found ' + (@($certXobject).count) + ' certificate(s)')
    $certXobject | ConvertTo-CertXHtml | Out-File $reportFile
    Write-Output '>> Sending email report'
    Send-MailMessage @mailProps -Body (Get-Content $reportFile -raw) -BodyAsHtml
}
else {
    Write-Output ('>> Found ' + (@($certXobject).count) + ' certificate(s)')
    Write-Output '>> Email abort'
}