

function SongsterrSearch($txt)
{
    $ApiURL = "http://www.songsterr.com/a/ra/songs.json?pattern="
    $searchString = "$([URI]::EscapeDataString($txt))"

    $response = Invoke-RestMethod "$($ApiURL)$($searchString)"
    write-host $response.count -ForegroundColor Green
    
    foreach($result in $response)
    {
        $jsondata = ConvertTo-Json($result)
        write-host $result.title
        Write-Host $jsondata
    }
    Get-Member -InputObject $response[0].tabTypes
}