<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Default Friendly URL --->
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
<cfif len(stobj.fu)>
	<cfoutput>/#stobj.fu#</cfoutput>
<cfelseif len(stobj.title)>
	<cfoutput>/#stobj.title#</cfoutput>
<cfelse>
	<cfoutput>/#stobj.label#</cfoutput>
</cfif>


<cfsetting enablecfoutputonly="false">