<!--- General settings --->
<cfset config = StructNew() />
<cfset config['general.engine'] = 'GoogleSpell' />		<!--- GoogleSpell | PSpellShell --->

<!--- GoogleSpell settings --->
<cfset config['GoogleSpell.ignoreDigits'] = 1 />
<cfset config['GoogleSpell.ignoreAllCaps'] = 1 />

<!--- <cfhttp> proxy settings
		Only necessary when using GoogleSpell if your server doesn't
		have a direct connection to the internet --->
<cfset config['cfhttp.proxyServer'] = '' />
<cfset config['cfhttp.proxyPort'] = '80' />
<cfset config['cfhttp.proxyUser'] = '' />
<cfset config['cfhttp.proxyPassword'] = '' />

<!--- PSpellShell settings (Linux/Unix) --->
<!---  
<cfset config['PSpellShell.aspell'] = '/usr/bin/aspell' />
<cfset config['PSpellShell.tmp'] = '/tmp' />
 ---> 

<!--- PSpellShell settings (Windows) --->
<!--- 
<cfset config['PSpellShell.cmd'] = '' />	<!--- Specify location of cmd.exe if not c:\windows\system32\cmd.exe --->
<cfset config['PSpellShell.aspell'] = 'c:\Program Files\Aspell\bin\aspell.exe' />
<cfset config['PSpellShell.tmp'] = 'c:\temp' />
 --->