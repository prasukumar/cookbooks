﻿<#
.SYNOPSIS

Install the LANSA IDE.
Creates a SQL Server Database then installs from the DVD image

Requires the environment that a LANSA Cake provides, particularly an AMI license.

# N.B. It is vital that the user id and password supplied pass the password rules. 
E.g. The password is sufficiently complex and the userid is not duplicated in the password. 
i.e. UID=PCXUSER and PWD=PCXUSER@#$%^&* is invalid as the password starts with the entire user id "PCXUSER".

.EXAMPLE


#>

# If environment not yet set up, it should be running locally, not through Remote PS
if ( -not $script:IncludeDir)
{
    # Log-Date can't be used yet as Framework has not been loaded

	Write-Output "Initialising environment - presumed not running through RemotePS"
	$MyInvocation.MyCommand.Path
	$script:IncludeDir = Split-Path -Parent $MyInvocation.MyCommand.Path

	. "$script:IncludeDir\Init-Baking-Vars.ps1"
	. "$script:IncludeDir\Init-Baking-Includes.ps1"
}
else
{
	Write-Output "$(Log-Date) Environment already initialised - presumed running through RemotePS"
}


try
{

    #####################################################################################
    Write-Output "$(Log-Date) Installing License"
    #####################################################################################

    CreateLicence "$Script:ScriptTempPath\LANSAScalableLicense.pfx" $LicenseKeyPassword "LANSA Scalable License" "ScalableLicensePrivateKey"
    CreateLicence "$Script:ScriptTempPath\LANSAIntegratorLicense.pfx" $LicenseKeyPassword "LANSA Integrator License" "IntegratorLicensePrivateKey"

    #####################################################################################
    Write-output ("$(Log-Date) Shortcuts")
    #####################################################################################

    New-Shortcut "C:\Program Files\Internet Explorer\iexplore.exe" "Desktop\Start Here.lnk" -Description "Start Here"  -Arguments "file://$Script:GitRepoPath/Marketplace/LANSA%20Scalable%20License/ScalableStartHere.htm" -WindowStyle "Maximized"
    New-Shortcut "C:\Program Files\Internet Explorer\iexplore.exe" "Desktop\Education.lnk" -Description "Education"  -Arguments "http://www.lansa.com/education/" -WindowStyle "Maximized"

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "StartHere" -Value "c:\Users\Administrator\Desktop\Start Here.lnk"

    Add-TrustedSite "lansa.com"
    Add-TrustedSite "google-analytics.com"
    Add-TrustedSite "googleadservices.com"
    Add-TrustedSite "img.en25.com"
    Add-TrustedSite "addthis.com"

    Write-Output ("$(Log-Date) Installation completed successfully")
}
catch
{
	$_
    Write-Error ("$(Log-Date) Installation error")
    throw
}
finally
{
    Write-Output ("$(Log-Date) See LansaInstallLog.txt and other files in $ENV:TEMP for more details.")

    # Wait if we are upgrading so the user can see the results
    if ( $UPGD_bool )
    {
        Write-Output ""
        Write-Output "Press any key to continue ..."

        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Successful completion so set Last Exit Code to 0
cmd /c exit 0