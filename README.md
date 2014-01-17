Get-WebFile
===========

Powershell script based on Boe Prox's Get-WebPage.ps1, but this one pulls down a specific file

I had tried using Boe Prox's Get-WebPage.ps1 script to pull a specific file, a binary file in this case, from a web site and was having issues working with that file. Thanks so some troubleshooting by a colleague, I learned that I needed to use the DownloadFile() method rather than DownloadString to retrieve the file and be able to work with it in the expected manner.

I simply modifyed Boe's script for this purpose. I also had to add some bits from one of Lee Holmes' post in order to accomodate malformed headers.

##Usage example:
```
. .\Get-WebFile.ps1
Get-Webfile -url http://www.bing.com/robots.txt -file c:\temp\robots.txt
```
