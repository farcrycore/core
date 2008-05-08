<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Standard Login Footer --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>

<cfoutput>
		<div class="loginFooter">
			<img src="images/powered_by_farcry_watermark.gif" />
			<h3>Tell it to someone who cares</h3>
			<p><small>Copyright &copy; <a href="http://www.daemon.com.au">Daemon</a> 1997-#year(now())#<br />#createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</small></p>
		</div>
		<br class="clearer" />
	</div>

	</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">