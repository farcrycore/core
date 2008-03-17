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
		<br style="clear:both;" />
		<h3><img src="images/powered_by_farcry_watermark.gif" />Tell it to someone who cares</h3>

		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>#createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</small></p>
	</div>

	</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">