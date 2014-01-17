function Get-WebFile {
<#  
.SYNOPSIS  
   Downloads a file from a web site.
.DESCRIPTION
   Downloads a file from a web site. 
.PARAMETER Url
    URL for the file to download.
.PARAMETER File
    The full path to receive the file.
.PARAMETER UseDefaultCredentials
    Use the currently authenticated user's credentials.  
.PARAMETER Proxy
    Used to connect via a proxy.
.PARAMETER Credential
    Provide alternate credentials.
.NOTES  
    Name: Get-WebFile
    Derived from Boe Prox's Get-WebPage
    See: http://poshcode.org/2498
    Author: Dave Hull
    DateCreated: 20140116
.EXAMPLE  
    Get-WebFile -url "http://www.bing.com/robots.txt" -file c:\temp\robots.txt
    
Description
------------
Returns the robots.txt file from bing.com
.EXAMPLE  
    Get-WebPage -url "http://www.bing.com/robots.txt" -file c:\temp\robots.txt
#> 
[cmdletbinding(
	DefaultParameterSetName = 'url',
	ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = '',
            ValueFromPipeline = $True)]
            [string][ValidatePattern("^(http|https)\://*")]$Url,
        [Parameter(
            Position = 1,
            Mandatory = $False,
            ParameterSetName = 'defaultcred')]
            [switch]$UseDefaultCredentials,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [string]$Proxy,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = 'altcred')]
            [switch]$Credential,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = '')]
            [string]$file                        
                        
        )
    Begin {     
        $psBoundParameters.GetEnumerator() | % { 
           Write-Verbose "Parameter: $_" 
        }
   
        $netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

        if($netAssembly) {
            $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
            $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

            $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

            if($instance) {
                $bindingFlags = "NonPublic","Instance"
                $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

                if($useUnsafeHeaderParsingField) {
                    $useUnsafeHeaderParsingField.SetValue($instance, $true)
                }
            }
        }

        #Create the initial WebClient object
        Write-Verbose "Creating web client object"
        $wc = New-Object Net.WebClient 
    
        #Use Proxy address if specified
        If ($PSBoundParameters.ContainsKey('Proxy')) {
            #Create Proxy Address for Web Request
            Write-Verbose "Creating proxy address and adding into Web Request"
            $wc.Proxy = New-Object -TypeName Net.WebProxy($proxy,$True)
        }       
        #Determine if using Default Credentials
        If ($PSBoundParameters.ContainsKey('UseDefaultCredentials')) {
            #Set to True, otherwise remains False
            Write-Verbose "Using Default Credentials"
            $wc.UseDefaultCredentials = $True
        }
        #Determine if using Alternate Credentials
        If ($PSBoundParameters.ContainsKey('Credentials')) {
            #Prompt for alternate credentals
            Write-Verbose "Prompt for alternate credentials"
            $wc.Credential = (Get-Credential).GetNetworkCredential()
        }         
        
    }
    Process {    
        Try {
            #Get the contents of the webpage
            Write-Verbose "Downloading file from web site"
            $wc.DownloadFile($url, $file)       
        } Catch {
            Write-Warning "$($Error[0])"
        }   
    }
}
