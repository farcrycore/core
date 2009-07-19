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
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<!------------------------------------------------------------
ACTION
------------------------------------------------------------->
<ft:processform action="Reload configuration">
	<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
	<cfset structclear(application.config) />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(configkey) />
	</cfloop>
	
	<skin:bubble title="Configuration has been reloaded" />
</ft:processform>

<ft:processform action="Delete / reset">
	<cfif structkeyexists(form,"objectid") and len(form.objectid)>
		<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
		<cfloop list="#form.objectid#" index="thisconfig">
			<cfset stConfig = oConfig.getData(objectid=thisconfig) />
			<cfset oConfig.delete(objectid=thisconfig) />
			
			<cfset thisform = oConfig.getForm(key=stConfig.configkey) />
			<cfif len(thisform)>
				<cfset application.config[stConfig.configkey] = oConfig.getConfig(key=stConfig.configkey) />
				<cfif structkeyexists(application.stCOAPI[thisform],"displayname")>
					<cfset stConfig.configkey = application.stCOAPI[thisform].displayname />
				</cfif>
				<skin:bubble title="Configuration reset" message="#stconfig.configkey# has been reset" />
			<cfelse>
				<cfset structdelete(application.config,stConfig.configkey) />
				<skin:bubble title="Configuration deleted" message="#stconfig.configkey# has been deleted" />
			</cfif>
		</cfloop>
	<cfelse>
		<skin:bubble title="Error" message="No configurations selected" />
	</cfif>
</ft:processform>

<!------------------------------------------------------------
VIEW
------------------------------------------------------------->
<!--- set up page header --->
<admin:header title="Permission Admin" />

<cfset aCustomColumns = arraynew(1) />

<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].title = "Key" />
<cfset aCustomColumns[1].sortable = true />
<cfset aCustomColumns[1].property = "configkey" />
<cfset aCustomColumns[1].webskin = "displayCellEditLink" />

<cfset aCustomColumns[2] = structnew() />
<cfset aCustomColumns[2].title = "Description" />
<cfset aCustomColumns[2].webskin = "displayCellHint" />

<cfset aButtons = arraynew(1) />

<cfset aButtons[1] = structnew() />
<cfset aButtons[1].value = "Delete / Reset" />
<cfset aButtons[1].permission = 1 />
<cfset aButtons[1].onclick = "" />

<cfset aButtons[2] = structnew() />
<cfset aButtons[2].value = "Reload configuration" />
<cfset aButtons[2].permission = 1 />
<cfset aButtons[2].onclick = "" />

<ft:objectadmin typename="farConfig" 
				title="Manage Configuration" 
				columnList="datetimelastupdated" 
				sqlorderby="configkey asc" 
				sortableColumns="datetimelastupdated" 
				aCustomColumns="#aCustomColumns#" 
				bSelectCol="true" 
				bShowActionList="false"
				aButtons="#aButtons#"
				lButtons="Delete / Reset,Reload configuration" />

<admin:footer />