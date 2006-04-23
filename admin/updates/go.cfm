<cfsetting enablecfoutputonly="yes" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/updates/go.cfm,v 1.2 2005/10/14 00:59:39 geoff Exp $
$Author: geoff $
$Date: 2005/10/14 00:59:39 $
$Name: milestone_3-0-0 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Friendly URL interstitial file for processing friendly urls to parameterised urls $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->

<!--- TODO: using local invocation, move to factory scope when done --->
<cfif StructKeyExists(url,"path")>
	<cfset objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	<cfset returnFU = objFU.fGetFUData(url.path)>
	<cfif returnFU.bSuccess>
		<!--- check if this friendly url is a retired link.: if not then show page --->
		<cfif returnFU.redirectFUURL NEQ "">
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="#returnFU.redirectFUURL#">
			<cfabort>
		<cfelse>
			<cfset url.objectid = returnFU.refobjectid>
			<cfloop index="iQstr" list="#returnFU.query_string#" delimiters="&">
				<cfset url["#listFirst(iQstr,'=')#"] = listLast(iQstr,"=")>
			</cfloop>
	
			<cfinclude template="#application.url.conjurer#">
		</cfif>
	<cfelse>
		<cfinclude template="404.cfm">
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no" />