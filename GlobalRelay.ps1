function Get-WordsInTags {
    param(
        [string]$regexString = "<p(| \w+.*)>.*</p>"
    )

    $listOfContents = @()

    $tags = ([regex]$regexString).Matches($global:httpContent).value
    $tags | ForEach-Object {
    
        if($_ -match ">(.*\w+.*)<"){
            $listOfContents += $matches[1]
        }
    
    }

    return $listOfContents
}

function Remove-UnneededElements {
    param(
        [bool]$ifA,
        [string[]] $contentTag
        
    )
    $output = @()

    $contentTag | ForEach-Object {

        $content = [System.Web.HttpUtility]::Htmldecode($_)
         
        if(!($ifA)){
            $content = $content -split "<a.*</a>"
        }else{
            if($content -match "<.+>"){
                $content = ([regex]"(>(\w+ ?)+<|(\w+ ?)+<|>(\w+ ?)+)").Matches($content).value
                $content = $content -split "\<" -split "\>"
            }
        }
        $contents = $content -split " " -split "\/" -split "<br>"
        $output += $contents.Where({ ($_ -ne "") -and ($_ -match ".*[a-zA-Z]+.*") })
    }

    return $output
}
$wordsInWebsite = @()
Add-Type -AssemblyName System.Web
$uri = "https://www.globalrelay.com/"

# Get All HTML Contents of Global Relay
$httpInfo = invoke-webrequest -Uri $uri -UseBasicParsing
$global:httpContent = $httpInfo.content 

# Filter <p> <h> <a> tags
$pTagsRegex = "<p(| \w+.*)>.*</p>"
$hTagsRegex = "<h\d(| \w+.*)>.*</h\d>"
$aTagsRegex = "<a(| \w+.*)>.*</a>"


# Get Contents of each tags
$p = Get-WordsInTags -regexString $pTagsRegex
$h = Get-WordsInTags -regexString $hTagsRegex
$a = Get-WordsInTags -regexString $aTagsRegex


# Remove unneeded items
$wordsInWebsite += Remove-UnneededElements -contentTag $p -ifA $false
$wordsInWebsite += Remove-UnneededElements -contentTag $h -ifA $false
$wordsInWebsite += Remove-UnneededElements -contentTag $a -ifA $true

Write-Host "There are $($wordsInWebsite.Count) words in $uri"
