Kerio-Connect-Webapp-Configurator
=================================

Kerio Connect Webapp Configurator is an AppleScript that helps Server.app and it's pesky Websites configuration play nicely with Kerio Connect.

Prerequisites
-------------
1. In order for this to be of any use, you need to have Mountain Lion or Mavericks with Server.app.
   You need to have launched the Server app at least once for it to have created the required folder structure. This script doesn't create the target folders if they're not there.

2. Kerio Connect is installed and the HTTP and HTTPS services have been set to ports other than 80 and 443 respectively.
   In the script, the defaults are to add 10000 to the port numbers, so HTTP listens on port 10080 and HTTPS listens on port 10443.
3. Kerio Connect has been set up with an SSL Certificate. Either a self-signed or a commercial one - it doesn't matter.
4. There is a hostname in DNS for the mail server (eg mail.example.com) that points to the IP of the OS X Server

How to use the script
---------------------
1. Run the script and enter the requested information.
2. Access the Kerio Connect Administration Console on https://localhost:4040
3. Go into *Configuration* > *SSL Certificates* and export the current active SSL certificate and the private key.
   Ensure that you take appropriate steps to secure these files, in particular the private key.
4. Go into the Server app, go to *Certificates* and *Show All Certificates*
5. *Import a Certificate Identity* and import your SSL private key and certificate from Kerio Connect
6. Still in Server, start up Websites
7. Make a new website with the DNS name that you entered into the script.
8. Go into *Edit Advanced Settings*
9. Tick the checkbox for the *Kerio Connect webapp*
10. Make another new website with the same DNS name
11. From the *SSL Certificate* dropdown menu, select the SSL certificate that you imported earlier
11. Go into *Edit Advanced Settings*
12. Tick the checkbox for the Kerio Connect SSL webapp

Open a browser and be amazed that you can now hit Kerio Connect on ports 80 and 443.

Files
-----
This script creates four files on your computer.
Two Websites configuration .plist files are in /Library/Server/Web/Config/apache2/
- httpd_KerioConnectwebapp.conf
- httpd_KerioConnectSSLwebapp.conf

Two Apache configuration .conf files are in /Library/Server/Web/Config/apache2/webapps
- au.com.automatica.kerioconnectwebapp.plist
- au.com.automatica.kerioconnectsslwebapp.plist

The reverse DNS name au.com.automatica is configurable as a variable in the AppleScript if you want to change it.

Caveats
-------
I'm not a programmer by any stretch of the imagination. This script has minimal error checking and it moves some files around as root. Please read the script and be sure you understand what it does before running it on your system. You are running this script entirely at your own risk. It hasn't broken anything on my system so far, but if it breaks anythng on yours, that's not my fault.

This could break mail clients in strange and unusual ways that I haven't been able to test thoroughly (I'm looking at you, Outlook 2011) - to be on the safe side, you're probably going to be best off configuring mail clients with the real port that Kerio Connect uses. If you use the Kerio Setup Assistant, it will configure the accounts with the actual port that Kerio Connect is on (eg, it will use 10443 instead of 443) as that's what Kerio sees itself as using.