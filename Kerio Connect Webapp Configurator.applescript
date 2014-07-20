-- © 2014 Kai Howells, Automatica. kai@automatica.com.au - http://automatica.com.au
-- This builds on a how-to guide from Alex Narvey at Precursor Systems - http://www.precursor.ca
-- as well as my own testing and tweaking.
-- I would have prefered to have a way to restrict OS X Server's Websites to be restricted to just one IP on the Server,
-- freeing up any additional IPs for third-party services. This was possible to achieve under Lion server without too
-- much difficulty however Apple changed things (as is their wont) and the method I was using no longer works.

display dialog "This applet will create the necessary files for Kerio Connect to exist as a webapp behind OS X Server's reverse proxy" buttons {"OK", "More Info...", "Cancel"} default button "OK"
if button returned of the result = "More Info..." then display dialog "In OS X Lion and above with Server.app providing Services, Server is very aggressive at taking ports 80 and 443 on all IP addresses on the host.
With this app, you can configure Kerio Connect on a alternative ports for HTTP and HTTPS in the Kerio Connect Administration and then use the built-in webapp support in Server to reverse proxy the connections through from ports 80 and 443 to the alternative ports chosen in the Admin console.
You can then set up two new websites in Server's Websites interface and enable the Kerio Connect webapps on their respective ports. You will also need to export the SSL Certificate and Private Key from Kerio Connect and import this into Server to use for the SSL version of the site."
display dialog "Please enter the mail server's fully qualified hostname (e.g. mail.example.com.au)" buttons {"OK"} default button "OK" default answer "mail.example.com"
set theHostname to text returned of the result
display dialog "Please enter the HTTP port for Kerio Connect (e.g. 10080)" buttons {"OK"} default button "OK" default answer "10080"
set theHTTPPort to text returned of the result
display dialog "Please enter the HTTPS port for Kerio Connect (e.g. 10443)" buttons {"OK"} default button "OK" default answer "10443"
set theHTTPSPort to text returned of the result

display dialog "Please enter the full path to the Kerio Connect mailserver.conf file" buttons {"OK"} default button "OK" default answer "/usr/local/kerio/mailserver/mailserver.cfg"
set theMailserverConf to text returned of the result

-- This is the location of where Server.app keeps it's webapps and config files
set theApacheFolder to "/Library/Server/Web/Config/apache2/"
set theWebappsFolder to theApacheFolder & "webapps/"

-- This is the name of our webapp, entered here as a variable so it's easier to change this for other webapps
set theHTTPName to "KerioConnect"
set theHTTPSName to theHTTPName & "SSL"

-- This follows a similar naming convention to Apple's included webapps
set theHTTPConfigName to "httpd_" & theHTTPName & "webapp.conf"
set theHTTPSConfigName to "httpd_" & theHTTPSName & "webapp.conf"

-- The configuration plist files use reverse dns naming - put your domain name in here if you prefer. Ensure there is a full-stop at the end of it.
-- I could try and guess this from the mail server's domain name entered above, but whatever...
set theReverseDNSName to "au.com.automatica."

-- This follows a similar naming convention to Apple's included webapps
set theHTTPAppName to theReverseDNSName & theHTTPName & "webapp.plist"
set theHTTPSAppName to theReverseDNSName & theHTTPSName & "webapp.plist"

-- This converts the strings for the plist files to all lower-case. Doing it as a shell script is a bit quicker and far easier than trying to acomplish the same thing in pure AppleScript.
set theHTTPAppName to do shell script "echo " & quoted form of (theHTTPAppName) & " | tr A-Z a-z"
set theHTTPSAppName to do shell script "echo " & quoted form of (theHTTPSAppName) & " | tr A-Z a-z"

--set theHTTPConfigFile to POSIX file (theApacheFolder & theHTTPConfigName)
--set theHTTPSConfigFile to POSIX file (theApacheFolder & theHTTPSConfigName)
--set theHTTPAppFile to POSIX file (theWebappsFolder & theHTTPAppName)
--set theHTTPSAppFile to POSIX file (theWebappsFolder & theHTTPSAppName)

set theHTTPConfigFile to theApacheFolder & theHTTPConfigName
set theHTTPSConfigFile to theApacheFolder & theHTTPSConfigName

set theHTTPAppFile to theWebappsFolder & theHTTPAppName
set theHTTPSAppFile to theWebappsFolder & theHTTPSAppName

-- Here's where it gets messy as I put in the templates for the four text files that need to be dropped...
set theHTTPConfigFileContents to "RewriteEngine On
RewriteCond %{HTTPS} =off
RewriteRule . - [E=protocol:http,E=port:" & theHTTPPort & "]
RewriteCond %{HTTPS} =on
RewriteRule . - [E=protocol:https,E=port:" & theHTTPSPort & "]
ProxyPassReverse / http://" & theHostname & ":" & theHTTPPort & "/
ProxyPass / http://" & theHostname & ":" & theHTTPPort & "/"

set theHTTPSConfigFileContents to "RewriteEngine On
RewriteCond %{HTTPS} =off
RewriteRule . - [E=protocol:http,E=port:" & theHTTPPort & "]
RewriteCond %{HTTPS} =on
RewriteRule . - [E=protocol:https,E=port:" & theHTTPSPort & "]
ProxyPassReverse / https://" & theHostname & ":" & theHTTPSPort & "/
ProxyPass / https://" & theHostname & ":" & theHTTPSPort & "/"

set theHTTPAppFileContents to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict> 
	<key>includeFiles</key>
	<array>
		<string>/Library/Server/Web/Config/apache2/" & theApacheFolder & theHTTPConfigName & "</string>
	</array>
	<key>name</key>
	<string>" & theReverseDNSName & theHTTPName & "webapp</string>
	<key>displayName</key>
	<string>Kerio Connect webapp</string>
	<key>installationIndicatorFilePath</key>
	<string>" & theMailserverConf & "</string>
	<key>sslPolicy</key>
	<integer>0</integer>
</dict>
</plist>"

set theHTTPSAppFileContents to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict> 
	<key>includeFiles</key>
	<array>
		<string>/Library/Server/Web/Config/apache2/" & theApacheFolder & theHTTPSConfigName & "</string>
	</array>
	<key>name</key>
	<string>" & theReverseDNSName & theHTTPSName & "webapp</string>
	<key>displayName</key>
	<string>Kerio Connect SSL webapp</string>
	<key>installationIndicatorFilePath</key>
	<string>" & theMailserverConf & "</string>
	<key>sslPolicy</key>
	<integer>0</integer>
</dict>
</plist>"


-- Prompt now for administrator privileges
display dialog "You will now be asked for an administrator username and password to modify the necessary system files."
do shell script "sudo -v" with administrator privileges

-- now lets write them out to disk...

on writeToFile(fileName, fileContents)
	set tempPath to POSIX path of (path to temporary items as string)
	set theTempFile to tempPath & "AppleScriptTempFile.txt"
	set theTempFile to POSIX file theTempFile
	try
		set myFile to open for access theTempFile with write permission
	on error errorMessage number errorNumber
		display dialog "Error " & (errorNumber as string) & " opening " & (theTempFile as string) & return & errorMessage
	end try
	try
		write fileContents to myFile
	on error errorMessage number errorNumber
		display dialog "Error " & (errorNumber as string) & " writing to " & (theTempFile as string) & return & errorNumber
	end try
	try
		close access myFile
	on error errorMessage number errorNumber
		display dialog "Error " & (errorNumber as string) & " closing " & (theTempFile as string) & return & errorMessage
	end try
	try
		do shell script "mv " & (POSIX path of theTempFile as string) & " " & fileName with administrator privileges
	on error errorMessage number errorNumber
		display dialog "Error " & (errorNumber as string) & " moving " & theTempFile & " to " & (fileName as string) & return & errorMessage
	end try
end writeToFile

my writeToFile(theHTTPConfigFile, theHTTPConfigFileContents)
my writeToFile(theHTTPSConfigFile, theHTTPSConfigFileContents)
my writeToFile(theHTTPAppFile, theHTTPAppFileContents)
my writeToFile(theHTTPSAppFile, theHTTPSAppFileContents)
display dialog "All Done. You can now go into Server.app and configure the HTTP and HTTPS web sites with the Kerio Connect webapp" buttons {"OK"}