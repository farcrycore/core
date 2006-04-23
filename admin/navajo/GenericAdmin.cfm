<!--- required variables --->
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfparam name="url.type" default="news">

<cfif not IsDefined("url.typename")>
	<h3>Typename not present in URL scope - better fix this link</h3>
	<cfabort>
</cfif>


<!--- 
Give Daemon_Event the same permissions as Daemon_News 
 - saves having to create a whole new permssions set 
--->

<cfset permissionType = "news">

<cfscript>
	typename = "#URL.typeName#";
</cfscript>	
<!--- call generic admin with extrapolation of URL type --->

<nj:genericAdmin permissionType="#permissionType#"  admintype="#url.type#" metadata="True" header="false" typename="#typename#">
