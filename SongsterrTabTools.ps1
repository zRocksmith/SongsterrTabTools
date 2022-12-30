#### TO-DO: ######################################################################
## - Output list of generated urls to .txt file                                 ##
## - Scrape GPT download link from each URL in .txt file                        ##
## - Loop each scraped GPT download link and download each file.                ##
## - Rename all files downloaded using their associated artist name/song title. ##
##################################################################################
#Import-Module -Name ImportExcel
###### GLOBAL VARIABLES #######
$savedir = "H:\.midi"
#$SpotifyAPIUrl = "https://api.spotify.com/"



#########################################################
# Get Songsterr GuitarPro Tabs using Songsterr JSON API #
#########################################################
function Get-SongsterrTabs($startIndex = 0)
{
    $prefix = "http://www.songsterr.com/a/wsa/"
    $apiURL = "https://www.songsterr.com/api/songs?size=500&from="
    $songLinks = @()
    
    #[int]$pageCount = [int]$(gc -Path "H:\.midi\PageCount.txt")
    $pageMax = 21
    $songIndex = $startIndex
    
    for($i=0; $i -lt $pageMax; $i++)
    {
        $webAPIDataPage = Invoke-RestMethod -Uri "$($apiURL)$($songIndex)"
        #$songIndex++
        
        #loop through all songs in the JSON...
        $indx = 0
        foreach($songJSON in $webAPIDataPage)
        {
            $songLinks += "$($prefix)$(CleanText($songJSON.artist))-$(CleanText($songJSON.title))-tab-s$($songJSON.songId)"
            write-host "$($prefix)$(CleanText($songJSON.artist))-$(CleanText($songJSON.title))-tab-s$($songJSON.songId)" | out-file ".\songsterr_LINKS.txt" -Append -Force
            $indx++
        }##END## SongJSON Loop ###############################################

        #add links from current API page to file...
        $songLinks | out-file ".\SongLinks-pg$($i).txt" -Force -Append
        $songIndex = $startIndex+($i*500)
        write-host "[PAGE: $($i) | SONGS: $($indx)]" -ForegroundColor Green -NoNewline
        write-host " SongIndex = $($songIndex)" -ForegroundColor Red
    }##END## API PAGE LOOP ################################################

    $songLinks | out-file ".\SongLinks-FULL.txt" -Force -Append
    #$pageCount += $songIndex | out-file H:\.midi\PageCount.txt -Force
}

########################################################
## Search For Tabs By Artist Using Songsterr JSON API ##
########################################################
# Search for Songsterr Tabs by Artist Name (or Song Title)...
function Get-SongsterrTabsByArtist($artistName)
{
    $results = @()

    if($artistName -eq "")
    {
        $SearchString = read-host "Enter an Artist and/or Song to search for..."
    }else{
        $SearchString = $artistName
    }
    $escString = [URI]::EscapeUriString($SearchString)

    ## Using Invoke-RestMethod
    $webAPIData = Invoke-RestMethod -Uri "https://www.songsterr.com/api/songs?size=500&pattern=$($escString)"
    ## Using Invoke-WebRequest
    $webAPIData = ConvertFrom-JSON (Invoke-WebRequest -uri "https://www.songsterr.com/api/songs?size=500&pattern=$($escString)")

    ## The download information is stored in the "assets" section of the data
    $songs = $webAPIData
    #$webAPIData | Get-Member

    # Generate a http URL for each song...
    foreach($song in $webAPIData)
    {
        write-host "http://www.songsterr.com/a/wsa/" -NoNewline
        write-host "$(CleanText($song.artist))-$(CleanText($song.title))-tab-s$($song.songId)" | out-file "SearchResults_$($artistName).txt" -Force
        $results += "http://www.songsterr.com/a/wsa/$(CleanText($song.artist))-$(CleanText($song.title))-tab-s$($song.songId)"
    }
    $results | out-file ".\SearchResults\$($SearchString).txt" -Force
    
    return $results
}
# Get Songsterr tabs by Artist from a .txt list of artists
function GetSongsterrTabsByArtistList($artistlist)
{
    $list = gc $artistlist
    foreach($a in $list)
    {
        Get-SongsterrTabsByArtist $a
    }
}

##################################################################
## Combine All Search Results in the .\SearchResults\ Directory ##
################################################################## 
function CombineAllSearchResults()
{
    
    cd .\SearchResults
    $results = @()
    $getSearchResults = gci .\* -Include *.txt
    foreach($r in $getSearchResults)
    {
        $SearchData = gc $r
        write-host $SearchData | out-file .\SearchData.txt -Append -Force
        $results += $SearchData 
    }
    cd ..
    $results | out-file .\CombinedSearchResults.txt -Force
    
    return $results
}
function GetCombinedSearchResultsTabData()
{
    write-host "Getting SongID's from CombinedSearchResults.txt..."
    pause
    GetSongIdsFromUrls CombinedSearchResults.txt
    write-host "Getting DownloadURL's from SongID's..."
    pause
    GetSongsterrDownloadURLs SongIdsFromUrls.txt
    #write-host "Downloading all Tabs from DownloadURLs.txt..."
    #DownloadSongsterrTabs
    write-host "COMPLETE!"
}


#############################################
## GET SONGSTERR DOWNLOAD URLS FROM SONGID ##
#############################################
$cookie = 'OrigRef=d3d3Lmdvb2dsZS5jb20=; _ga=GA1.2.563324618.1641686257; G_ENABLED_IDPS=google; __gads=ID=b5de266b76d30fa8:T=1641686257:S=ALNI_MZxgEGqVWRkMMew-r_CunkutRPrQg; SongsterrL=b0b18683873fd827048dff32450b36910f6bba9e8ef30a9f; cto_bundle=uLgR3V94aUdUbzhmQVpDeW1nR3NlbHlReThHJTJCNlBGSUNnZklXeVpQREluamU3RmZTR21vZEtTVXdmJTJCOEtIZnVIbU5iZiUyRndCeFFvbTEyS3NES21EOUJ5N2ZHJTJGJTJGSmI0MUdUTGNGbEpsTm94RDE0TnF4V2lBRXRjbUx2NHZTQ2N1R0pzclNZb1VrMFpHUmglMkZTd0s4cXN3U2dNSkElM0QlM0Q; ScrShwn-svws=true; LastRef=d3d3Lmdvb2dsZS5jb20=; EE_STORAGE=["video_walkthrough","comments_removal"]; lastSeenTrack=/a/wsa/falling-in-reverse-wait-and-see-half-solo-tab-s398766; experiments={"aa":"on","sound_v4":"off","comments_removal":"on","new_plus_banner":"off"}; _gid=GA1.2.1968037562.1656242890; amp_9121af=XrOZ72J_mkX5E6aGJkftn4.MjMyMDYzMA==..1g6gt3qtj.1g6gt93ho.2p.2p.5i; SongsterrT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIyMzIwNjMwIiwiZW1haWwiOiJ6Q2xvbmVIZXJvQGdtYWlsLmNvbSIsIm5hbWUiOiJ6Q2xvbmVIZXJvIiwicGxhbiI6InBsdXMiLCJzdWJzY3JpcHRpb24iOnsic3RhdHVzIjoiYWN0aXZlIiwidHlwZSI6ImJyYWludHJlZSIsInN0YXJ0RGF0ZSI6IjIwMjItMDUtMDhUMDQ6NTE6MzQuMDAwWiIsImVuZERhdGUiOm51bGwsImNhbmNlbGxhdGlvbkRhdGUiOm51bGx9LCJzcmFfbGljZW5zZSI6Im5vbmUiLCJnb29nbGUiOiIxMDExNDgyNDE3ODYwODgwNDQxMzQiLCJpYXQiOjE2NTYyNzc2NjQsImlkIjoiMjMyMDYzMCJ9.e-cSj5xaosVcet1kNciKL2cxmiOu0lGlREz3HFNLhao'
$dlPrefix = 'https://d12drcwhcokzqv.cloudfront.net/'
$SongIDs = gc -Path H:\SongIDs.txt
$Artists = gc -Path H:\Artists.txt
$SongTitles = gc -Path H:\SongTitles.txt
$TabURL = ""
$old_FileName = ""
$new_FileName = ""
$data = @()
$fileData = @()

# Get all song data from a songsterr SongID...
function GetSongsterrDownloadData($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $DownloadURL = $R[0].source | out-host

    $RevisionId = $R[0].revisionId | out-host
    $Tracks = $R[0].tracks | out-host
    $Title = $R[0].title | out-host
    $Artist = $R[0].artist | out-host

    $data += "$($R[0].source)`n"
    $data += "$($R[0].revisionId)`n"
    $data += "$($R[0].title)`n"
    $data += "$($R[0].artist)`n"
    $data += "$($R[0].tracks)`n"
    $data | out-file .\test.txt -Append -Force

    

    return $data
}

# Get a Download URL from a Songsterr SongID...
function GetSongsterrDownloadURL($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $getDownloadURL = $R[0].source #| out-host
    
    return $($R[0].source).ToString()
}
function GetSongsterrRevisionID($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $getRevisionID = $R[0].revisionId #| out-host
    
    return $($R[0].revisionId).ToString()
}
function GetSongsterrTitle($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $getTitle = $R[0].title #| out-host
    
    return $($R[0].title).ToString()
}
function GetSongsterrArtist($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $getArtist = $R[0].artist #| out-host
    
    return $($R[0].artist).ToString()
}
function GetSongsterrTracks($songid)
{
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $getTracks = $R[0].tracks #| out-host
    
    return $($R[0].tracks).ToString()
}
# Get the Artist and SongTitle from a Songsterr SongID...
function GetSongsterrArtistAndTitle($songid)
{
    $dlUrlPrefix = 'https://d12drcwhcokzqv.cloudfront.net/'
    $R = Invoke-RestMethod -uri "https://songsterr.com/api/meta/$($songid)/revisions" #-OutFile H:\.midi\json.json
    $songArtist = $R[0].artist #| out-host
    $songSongTitle = $R[0].title
    $tmpExt = $($($R[0].source).ToString()).Replace($dlUrlPrefix, "")
    
    $output = "$($songArtist) - $($songSongTitle).$($tmpExt)"

    return $output.ToString()
}

# Get the Download URL from a list of SongID's...
function GetSongsterrDownloadURLs($SongIDs_List)
{
    write-host "Getting Songsterr download URL's from SongId list file: " -NoNewLine; write-host $SongIDs_List -ForegroundColor Green -NoNewline; write-host "...`n"

    $SongIDs = gc $SongIDs_List
    foreach($sID in $SongIDs)
    {
        write-host "SongID: " -NoNewline; write-host $sID -ForegroundColor DarkGreen
        write-host "DownloadURL: " -NoNewline
        GetSongsterrDownloadURL $sID | out-file -FilePath .\DownloadURLs.txt -Append -Force
        write-host "$(GetSongsterrDownloadURL $sID)" -ForegroundColor Green
    }
}

################################
#### MISC UTILITY FUNCTIONS ####
################################
# Convert artist/titles to their url equivalent
function CleanText([string]$rawText)
{
    $cText = $rawText.Replace(" ", "-")
    $clText = $cText.replace("(","")
    $cleText = $clText.replace(")","")
    $cleaText = $cleText.replace(".","")
    $cleanText = $cleaText.replace(",","")
    $betterText = $cleanText.replace("'","")
    [string]$goodText = $betterText

    return $goodText
}

#############################
## Download Songsterr Tabs ##
#############################
function DownloadSongsterrTabs($path2urls = 'DownloadURLs.txt',$path2songids = 'SongIdsFromUrls.txt',$path2oldnames = 'OldFilenames.txt',$path2newnames = 'NewFilenames.txt')
{
	$dlUrlPrefix = "https://d12drcwhcokzqv.cloudfront.net/"
    if($path2oldnames -eq "" -or $path2newnames -eq "")
    {
        #Generate the old/new filenames data lists...
        write-host "Generating OldFilenames.txt file..."
        GenerateOldFilenames $path2urls
        write-host "Generating NewFilenames.txt file..."
        GenerateNewFilenames $path2songids
    }else{
        $oldFilenames = gc -Path $path2oldnames # **NOTE: see GenerateOldFilenames function.**
	    $newFilenames = gc -Path $path2newnames # **NOTE: see GenerateNewFilenames function.**
    }
    <#if($path2artists -eq "" -or $path2songtitles -eq "")
    {
        #Generate Artists/SongTitles data lists...
        write-host "Generating Artists.txt file..."
        GenerateArtistsFile
        write-host "Generating SongTitles.txt file..."
        GenerateSongTitlesFile
    }else{
        $Artists = gc -Path $path2artists
	    $SongTitles = gc -Path $path2songtitles
    }#>
    $dlURLs = gc -Path $path2urls
    $idx = 0
	foreach($s in $dlURLs)
	{
		$oldFilename = $oldFilenames[$idx].ToString(); $newFilename = $newFilenames[$idx].ToString()
        write-host "Downloading " -NoNewline; write-host $oldFilename -ForegroundColor Green -NoNewline; write-host " (" -NoNewline; write-host $newFilename -ForegroundColor Green -NoNewline; write-host ")..."
		Invoke-WebRequest -Uri $s -OutFile ".\Files\$($oldFilename)"
		$idx++
	}
    $savedFiles = gci ".\Files\*"
    RenameDownloadedFiles "$($pwd)\Files\" $oldFilenames $newFilenames
}
# Download Songsterr Tabs from a list of Songsterr Song Page URL's...
function DownloadSongsterrTabsFromURLs($path2urls = 'DownloadURLs.txt',$path2songids = 'SongIdsFromUrls.txt',$path2oldnames = 'OldFilenames.txt',$path2newnames = 'NewFilenames.txt')
{
	$dlURLs = gc -Path $path2urls
    if($path2oldnames -eq "" -or $path2newnames -eq "")
    {
        write-host "`nGenerating OldFilenames.txt File...`n" -ForegroundColor Green -BackgroundColor Black; sleep 3
        GenerateOldFilenames $path2urls
        write-host "`nGenerating NewFilenames.txt File...`n" -ForegroundColor Green -BackgroundColor Black; sleep 3
        GenerateNewFilenames $path2songids
        $oldFilenames = gc -Path OldFilenames.txt
	    $newFilenames = gc -Path NewFilenames.txt
    }else{
	    $oldFilenames = gc -Path $path2oldnames
	    $newFilenames = gc -Path $path2newnames
    }
	$idx = 0
	foreach($s in $dlURLs)
	{
		$oldFilename = $oldFilenames[$idx].ToString(); $newFilename = $newFilenames[$idx].ToString()
        write-host "Downloading " -NoNewline; write-host $oldFilename -ForegroundColor Green -NoNewline; write-host " (" -NoNewline; write-host $newFilename -ForegroundColor Green -NoNewline; write-host ")..."
		Invoke-WebRequest -Uri $s -OutFile ".\Files\$($oldFilename)"
		$idx++
	}
    $savedFiles = gci ".\Files\*"
    RenameDownloadedFiles "$($pwd)\Files\" $oldFilenames $newFilenames
}
function GenerateOldFilenames($download_urls_list = "DownloadURLs.txt")
{
    $dlUrlPrefix = "https://d12drcwhcokzqv.cloudfront.net/"
    $arrOldFilenames = @()

    $list = gc $download_urls_list
    foreach($n in $list)
    {
        $tmpString = $n; $outString = $tmpString.Replace($dlUrlPrefix, "")
        #write-host $outString
        $arrOldFilenames += $outString
    }
    $arrOldFilenames | out-file .\OldFilenames.txt -Force
}
function GenerateNewFilenames($songids_list = 'SongIdsFromUrls.txt')
{
    $arrNewFilenames = @()

    $list = gc $songids_list
    foreach($id in $list)
    {
        $outString = GetSongsterrArtistAndTitle $id
        #write-host $outString
        $arrNewFilenames += $outString
    }
    $arrNewFilenames | out-file .\NewFilenames.txt -Force
}
function GenerateArtistsFile($songids_list = 'SongIdsFromUrls.txt')
{
    $arrArtists = @()

    $list = gc $songids_list
    foreach($id in $list)
    {
        $outString = GetSongsterrArtist $id
        #write-host $outString
        $arrArtists += $outString
    }
    $arrArtists | out-file .\Artists.txt -Force
}
function GenerateSongTitlesFile($songids_list = 'SongIdsFromUrls.txt')
{
    $arrSongTitles = @()

    $list = gc $songids_list
    foreach($id in $list)
    {
        $outString = GetSongsterrTitle $id
        #write-host $outString
        $arrSongTitles += $outString
    }
    $arrSongTitles | out-file .\SongTitles.txt -Force
}

# Rename Downloaded Songsterr Tabs...
function RenameDownloadedFiles($path2files = ".\Files\",$oldnames = "OldFilenames.txt",$newnames = "NewFilenames.txt")
{
    $oldFilenames = gc $oldnames
    $newFilenames = gc $newnames
    cd .\Files
    $ndx = 0
    foreach($n in $oldFilenames)
    {
        Move-Item -Path ".\$($n.ToString())" -Destination ".\$($newFilenames[$ndx].ToString())" -Force -Verbose
        $ndx++
    }
    write-host "`nFinished Renaming " -NoNewline; write-host $ndx.ToString() -ForegroundColor DarkGreen -NoNewline; write-host " Files!`n"; pause
    cd ..
    
}

###################################################
## Get Songsterr SongID(s) from Songsterr URL(s) ##
###################################################
# Get SongId From URL...
function GetSongIdFromURL($url)
{
    $SongIdRegEx = "([a-zA-Z]+(-[a-zA-Z]+)+)"
    $url -match "(tab-s[0-9]+)"
    [string]$rawSongId = $Matches[1].ToString()
    $fName = $url.Remove(0,31)
    $fName -match "(-tab-s[0-9]+)"
    [string]$cleanName = $fName.Replace($Matches[1].ToString(), "").ToString()
    
    
    write-host $cleanName.Replace($Matches[1].ToString(), "") -ForegroundColor Green | out-file SongIdNames.txt -Append -Force
    write-host $rawSongId.Replace("tab-s", "") -ForegroundColor Red

    return [string]$rawSongId.Replace("tab-s", "")
}
# Get multiple SongId's from a list of URL's...
function GetSongIdsFromURLs($URLsList)
{
    $list = gc $URLsList
    foreach($u in $list)
    {
        [string]$sngID = GetSongIdFromURL $u 
        $sngID.Replace("True", "").Replace("False", "").Remove(0,2) | out-file ".\Files\SongIdsFromUrls.txt" -Append -Force
    }
}

####################
#### DO NOT USE ####
#######################################################
## Generate Songsterr Download URL(s) from SongID(s) ##
#######################################################
# Generate download links from a SongIds...
function GetDownloadURLsFromSongIds($SongIdsList)
{
    $prefix = 'https://d12drcwhcokzqv.cloudfront.net/'
    $list = gc $SongIdsList
    foreach($i in $list)
    {
        $downloadURL = "$($prefix)$($i).gp5"
    }
}



######################################
# Import Song Data From Spreadsheets #
######################################
# Songsterr Data > Artist/Title/SongId
function ImportSongsterrData($xlFile)
{
    Import-Excel -Path $xlFile -ImportColumns @(3,4,6) -StartRow 1
    #Import-Excel -Path $xlFile -ImportColumns @(1,2,4) -StartRow 1
}
# Songsterr URLs > Artist/Title/DownloadURL
function ImportSongsterrURLs($xlFile)
{
    Import-Excel -Path $xlFile -ImportColumns @(3,4,6) -StartRow 1
    #Import-Excel -Path $xlFile -ImportColumns @(1,2,4) -StartRow 1
}

# SheetMusic-Free Data > DownloadURL/SongPageURL/SongTitle/Artist
function ImportSheetMusicFreeData($xlfile)
{
    #import DownloadURL(8), SongPageURL(11), SongTitle(12), Artist(13) from spreadsheet...
    $SheetMusicFree_Data = Import-Excel -Path $xlfile -ImportColumns @(8,11,12,13) -StartRow 1
    #return the Imported columns from the spreadsheet...
    return $SheetMusicFree_Data
}



###############################################
# Rename downloaded Songsterr GuitarPro files #
###############################################
function RenameSongsterrDownloads($path2files, $path2titles)
{
    #ImportSongsterrURLs("H:\.Midi\Seether.xlsx")
    $FileURLsList = ls -Path $path2files #Get-Content D:\urls.txt
    $TitlesList = Get-Content $path2titles #D:\titles.txt
    $indx = 0

    foreach($url in $FileURLsList)
    {
        write-host $url
        $nTitle = $TitlesList[$indx].ToString().Replace(" ","_")
        $neTitle = $nTitle.ToString().Replace(".", "")
        $newTitle = $neTitle.ToString().Replace("'","")
        write-host "$($newTitle).gp5"
        rename-item -Path $url.FullName -NewName "$($newTitle).gp5" -Verbose
        $indx++
    }
}
function RenameSongsterrDownloads($path2files, $artist)
{
    ImportSongsterrURLs("$($path2files)\$($artist)Data-ScrapeStorm.xlsx")
    $FileURLsList = ls -Path $path2files #Get-Content D:\urls.txt
    $TitlesList = Get-Content "$($path2files)\titles.txt"
    $indx = 0

    foreach($url in $FileURLsList)
    {
        write-host $url
        $nTitle = $TitlesList[$indx].ToString().Replace(" ","_")
        $neTitle = $nTitle.ToString().Replace(".", "")
        $newTitle = $neTitle.ToString().Replace("'","")
        write-host "$($newTitle).gp5"
        rename-item -Path $url.FullName -NewName "$($newTitle).gp5" -Verbose
        $indx++
    }
}




######################################
## Download Songsterr GPT Tab By ID ##
######################################
function DownloadByID($id)
{
    $fileurl = "https://d12drcwhcokzqv.cloudfront.net/$($id).gp5"
    $outpath = "$($savedir)\$($id).gp5"
    write-host "Saving... $($fileurl) ...To... $($outpath)" -ForegroundColor Red
    Invoke-WebRequest $fileurl -OutFile $outpath -Verbose
}
function DownloadByIDExt($id, $gpext = "gp5")
{
    $fileurl = "https://d12drcwhcokzqv.cloudfront.net/$($id).$($gpext)"
    $outpath = "$($savedir)/$($id).$($gpext)"
    write-host "Saving $($fileurl)... Saving to $($outpath)" -ForegroundColor Green -BackgroundColor Black
    Invoke-WebRequest $fileurl -OutFile $outpath -Verbose
}
function DownloadByFilename($fName)
{
    $fileurl = "https://d12drcwhcokzqv.cloudfront.net/$($fName)"
    $outpath = "$($savedir)\$($fName)"
    write-host "Saving $($fileurl)... Saving to $($outpath)" -ForegroundColor Green -BackgroundColor Black
    Invoke-WebRequest $fileurl -OutFile $outpath -Verbose
}


############################################
## Songsterr GPT Download Link Generation ##
############################################
function GenerateDownloadLink($fileID)
{
    $urlGPTPrefix = "https://d12drcwhcokzqv.cloudfront.net"
    $urlGPTExt = "gp5"
    [string]$dlLink = "$($urlGPTPrefix)/$($fileID).$($urlGPTExt)"

    return [string]$dlLink
}
function GenerateDownloadLinks($path2IDList)
{
    $urlGPTPrefix = "https://d12drcwhcokzqv.cloudfront.net"
    $urlGPTExt = "gp5"
    $dlList = @()
    $listIDs = get-content $path2IDList

    foreach($id in $listIDs)
    {
        [string]$dlLink = "$($urlGPTPrefix)/$($id).$($urlGPTExt)"
        $dlList += $dlLink
    }

    return $dlList
}


##################################################################
## Search Songsterr for Artist and/or Song Title using JSON API ##
##################################################################





########################################################################################################
#### UI/DISPLAY RELATED FUNCTIONS #####
#######################################
function TextBar($txt)
{
    write-host "[ " -ForegroundColor Red -NoNewline
    write-host $txt -ForegroundColor DarkRed -NoNewline
    write-host " ]" -ForegroundColor Red -NoNewline
}
function TextBarW($txt)
{
    write-host "[ " -ForegroundColor Red -BackgroundColor Black -NoNewline
    write-host $txt -ForegroundColor DarkRed -BackgroundColor Black -NoNewline
    write-host " ]" -ForegroundColor Red -BackgroundColor Black -NoNewline
}
function TextBarL($title, $txt)
{
    TextBarW($title); write-host " $($txt)"
}

function TextLog($txt)
{
    TextBar("zRS"); write-host " $($txt)"
}

function uiBanner()
{
    write-host ""
    write-host '||[ ' -ForegroundColor Red -NoNewline -BackgroundColor Black
    write-host 'zRocksmith Utilities' -ForegroundColor DarkRed -NoNewline -BackgroundColor Black
    write-host ' ]||' -ForegroundColor Red -BackgroundColor Black
    write-host "       " -NoNewLine
    write-host '|[ ' -ForegroundColor Red -NoNewline -BackgroundColor Black
    write-host 'By Zanzo' -ForegroundColor DarkRed -NoNewline -BackgroundColor Black
    write-host ' ]|' -ForegroundColor Red -BackgroundColor Black
    write-host
}
function uiText($txt)
{
    write-host ""
    write-host '[' -ForegroundColor Red -NoNewline -BackgroundColor Black
    write-host 'zRS' -ForegroundColor DarkRed -NoNewline -BackgroundColor Black
    write-host ']' -ForegroundColor Red -BackgroundColor Black -NoNewline
    write-host " $($txt)"
}
function uiBannerText([string]$txt)
{
    write-host ""
    write-host '||[ ' -ForegroundColor Red -NoNewline -BackgroundColor Black
    write-host 'zRS' -ForegroundColor DarkRed -NoNewline -BackgroundColor Black
    write-host ' ]||[ ' -ForegroundColor Red -BackgroundColor Black -NoNewline
    write-host 'Rocksmith Utilities' -ForegroundColor darkgray -BackgroundColor Black -NoNewline
    write-host ' ]||' -ForegroundColor Red -BackgroundColor Black
    write-host $txt
}
function uiBannerText([string]$txt, [System.ConsoleColor]$color = "White")
{
    write-host ""
    write-host '||[ ' -ForegroundColor Red -NoNewline -BackgroundColor Black
    write-host 'zRS' -ForegroundColor DarkRed -NoNewline -BackgroundColor Black
    write-host ' ]||[ ' -ForegroundColor Red -BackgroundColor Black -NoNewline
    write-host $txt -ForegroundColor $color -BackgroundColor Black -NoNewline
    write-host ' ]||' -ForegroundColor Red -BackgroundColor Black
}
                                                   ######################################################
                        ################################################ UI/DISPLAY RELATED FUNCTIONS ###
#########################################################################################################