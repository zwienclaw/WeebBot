# If on secure network
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# This part I use Twilio. You can make an account if you want or use simple email->phone messaging using Send-MailMessage
$sid    = "{TwilioSid}"

# Encrypt password to desired location using (Get-Credential).Password | ConvertFrom-SecureString | Out-File "C:\Passwords\{DesiredName}.txt"
$token  = Get-Content "C:\Passwords\TwilioToken.txt" | ConvertTo-SecureString

$TwilioNumber = "{Twilio number}"
$ToNumber = "{DestinationPhoneNumber}"
$cred = New-Object System.Management.Automation.PSCredential($sid, $token)

function sendSMS {
    $SMSBody = @{
        From = $TwilioNumber
        To = $ToNumber
        Body = $Body
    }
    $apiEndpoint= "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    Invoke-RestMethod -Uri $apiEndpoint -Body $SMSBody -Credential $cred -Method "POST" -ContentType "application/x-www-form-urlencoded"
}

try
{
    # I use manganelo for manga updates. This is to make sure the server is still up and send me a text when an error occurs.
    $site = Invoke-WebRequest -UseBasicParsing -Uri "manganelo.com"
}
catch [System.Exception]
{
    $Body = "Error occurred connecting to the manga website"
    sendSMS
    break
}

# I use excel to keep track of manga I'm keeping up with
$fileName = "MasterMangaList.csv"
$filePath = Join-Path $PSScriptRoot $fileName
$import = Import-csv $filePath

foreach ($list in $import) 
{
	$Name = $list.Name
	$Chapter = $list.Chapter
    $oldChapter = $Chapter

    if($site.Links | Where {($_.title -eq $Name)})
    {
        $result = $site.Links | Where {(($_.title -like $Name + " Chapter*") -and ($_.title -Match "Chapter"))}
    
        # Sorting is weird in powershell. sorting by '| sort' yields 9.5,9,10
        # So we sort on when it updates which we assume is in descending order
        if($result.Count -gt 1) { [array]::Reverse($result) }
    
        foreach ($resultData in $result)
        {
            $mangaData = $resultData.title -split " Chapter "

            if($mangaData[1].Contains(":"))
            {  
                $mangaData = $mangaData[1] -split ":" 
                $foundChapter = $mangaData[0]
            }
            else
            {
                $foundChapter = $mangaData[1]
            }
            
            if($Chapter -lt [double]$foundChapter)
            {
                $Chapter = [double]$foundChapter
                $Display = "New " + $resultData.title
                $Display
            }
        }

        if($Chapter -ne $oldChapter)
        {            
            $Body = " `n " + $Name + " updated with " + [int]$result.Count + " new chapters. `n" + $result[0].href
            sendSMS
            $list.Chapter = $Chapter
        }
    }
    
	$import | Export-Csv $filePath -NoTypeinformation 
}
