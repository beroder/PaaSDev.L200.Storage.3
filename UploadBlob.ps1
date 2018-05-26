#Login-AzureRmAccount
$storageAccountName = "l200XXXX"
$storageAccountKey = "XXXX"
$rndstring = $(-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})).ToLower()
$blobname = "archivedata$rndstring.txt"
$containerName = "archivefiles$rndstring"

$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

try
{
    Write-Host "Creating container..."
    New-AzureStorageContainer -Name $containerName -Context $ctx -Permission blob
}
catch [Exception]
{
    Write-Host $_.Exception.GetType().FullName, $_.Exception.Message
}

Write-Host "Uploading blob..."
Set-AzureStorageBlobContent -File ".\file.txt" `
 -Container $containerName `
 -Blob $blobname `
 -Context $ctx `
 -Force

Write-Host
Write-Host "Blob upload finished!"
Write-Host

$blob = Get-AzureStorageBlob -Container $containerName -Blob $blobname -Context $ctx

try
{
    Write-Host "Setting blob tier..."
    Write-Host
    $blob.icloudblob.setstandardblobtier("Archive")
    Write-Host (Get-Date).ToUniversalTime()
    Write-Host "Archive blob tier set successfully!" -ForegroundColor Yellow
    Write-Host "TimeStamp: " (Get-Date).ToUniversalTime() -ForegroundColor Yellow
    $tmp = New-TemporaryFile
    Write-Host "Temporary file $tmp"
    Get-AzureStorageBlob -Container $containerName -Blob $blobname -Context $ctx | Select-Object -Property Name, BlobType, Length, ContentType, @{n='AccessTier';e={$_.ICloudBlob.Properties.StandardBlobTier}}
    #  | Select-Object -Property Name, BlobType, Length, ContentType, @{n='AccessTier';e={$_.ICloudBlob.Properties.StandardBlobTier}} | Export-Csv "$tmp.csv"
}
catch [Exception]
{
    Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red
    $dt = $(Get-Date).ToUniversalTime()
    Write-Host "TimeStamp: $dt UTC" -ForegroundColor Red
}
