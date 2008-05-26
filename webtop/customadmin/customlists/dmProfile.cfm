<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<ft:processform action="Change password">
	<cfset stProfile = createobject("component",application.stCOAPI.dmProfile.packagepath).getData(form.selectedobjectid) />
	
	<cfif stProfile.userdirectory eq "CLIENTUD">
		<cfset stUser = createobject("component",application.stCOAPI.farUser.packagepath).getByUserID(listfirst(stProfile.username,"_")) />
		<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stUser.objectid#&typename=farUser&method=editPassword&ref=typeadmin&module=customlists/dmProfile.cfm" />
	<cfelse>
		<extjs:bubble title="Error" message="'Change password' only applies to CLIENTUD users." />
	</cfif>
</ft:processform>

<!--- set up page header --->
<admin:header title="User Admin" />

<cfset aCustomColumns = arraynew(1) />

<ft:objectadmin 
	typename="dmProfile"
	permissionset="news"
	title="User Administration"
	columnList="username,userdirectory,firstname,lastname" 
	sortableColumns="userid,userstatus"
	lFilterFields="username"
	sqlorderby="username asc" 
	lCustomActions="Change password" />

<admin:footer />