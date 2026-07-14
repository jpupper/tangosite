
$baseUrl = "ftp://fullscreencode.com"
$username = "jpupper@jeyder.com.ar"
$password = "Sarosa2025"
$localFile = "D:\Programacion\tango\index.html"
$remotePath = "/jpupper/pasosdecambios/index.html"

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$fileContent = [System.IO.File]::ReadAllBytes($localFile)

# Create parent directories on FTP
$parts = $remotePath.TrimStart('/').Split('/')
$current = ""
for ($i = 0; $i -lt $parts.Length - 1; $i++) {
  $current += "/" + $parts[$i]
  try {
    $req = [System.Net.FtpWebRequest]::Create("$baseUrl$current")
    $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $req.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $req.UsePassive = $true; $req.EnableSsl = $true; $req.KeepAlive = $false
    $resp = $req.GetResponse(); $resp.Close()
  } catch { }
}

# Upload the file
$request = [System.Net.FtpWebRequest]::Create("$baseUrl$remotePath")
$request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$request.Credentials = New-Object System.Net.NetworkCredential($username, $password)
$request.UseBinary = $true; $request.UsePassive = $true; $request.KeepAlive = $false; $request.EnableSsl = $true

$requestStream = $request.GetRequestStream()
$requestStream.Write($fileContent, 0, $fileContent.Length)
$requestStream.Close()

$response = $request.GetResponse() -as [System.Net.FtpWebResponse]
Write-Host "Status: $($response.StatusCode) - $($response.StatusDescription)"
$response.Close()
