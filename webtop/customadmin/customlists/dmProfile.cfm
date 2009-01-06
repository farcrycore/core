<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
	title="User Administration"
	columnList="username,userdirectory,firstname,lastname" 
	sortableColumns="userid,userstatus"
	lFilterFields="username"
	sqlorderby="username asc" 
	lCustomActions="Change password" />

<admin:footer />