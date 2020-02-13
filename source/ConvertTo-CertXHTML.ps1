Function ConvertTo-CertXHTML {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )
        ]
        [ValidateNotNullOrEmpty()]
        [PSTypeNameAttribute('LazyExchangeAdmin.Certificate.Report')]
        $InputObject,

        [Parameter()]
        [string]
        $Title = ("{0}{1}" -f ('Server Certificate Expiration Report - ', (Get-Date -Format "MMMM dd, yyyy hh:mm tt")))
    )
    begin {
        $ModuleInfo = Get-Module LazyExchangeAdmin.CertX
        $body = @()
        $body += '<html><head><title>' + $title + '</title>'
        $body += '<style type="text/css">'
        $body += (Get-Content (($ModuleInfo.ModuleBase.ToString()) + '\source\style.css') -Raw)
        $body += '</style></head>'
        $body += '<body>'
        $body += '<table class="tbl">'
        $body += '<thead><tr>
            <th>Server Name</th>
            <th>Certificate Name</th>
            <th>Certificate Thumbprint</th>
            <th>Valid From</th>
            <th>Valid Until</th>
            <th>Day(s) Remaining</th>
            </tr>
            </thead>'
    }
    process {
        foreach ($item in $InputObject) {
            $body += '<tr>' + `
                '<td>' + $item.'Server Name' + '</td>' + `
                '<td>' + $item.'Certificate Name' + '</td>' + `
                '<td>' + $item.'Certificate Thumbprint' + '</td>' + `
                '<td>' + $item.'Certificate Valid From' + '</td>' + `
                '<td>' + $item.'Certificate Valid Until' + '</td>' + `
                '<td>' + $item.'Day(s) Remaining' + '</td>' + `
                '</tr>'
        }
    }
    end {
        $body += '</table></body></html>'
        return ($body -join "`n")
    }
}
