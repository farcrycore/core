<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Renders Tab Panel Display  --->
<!--- @@description: A facade call for item  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">

<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfparam name="attributes.id" default="tabPanel-#arrayLen(request.extJS.stLayout.aLayoutItems)#">


<cfoutput>
<cfif structKeyExists(attributes, "autoLoad") AND not findNoCase("ajaxMode", attributes.autoload)>
	<cfif not findNoCase("?", attributes.autoLoad)>
		<cfset attributes.autoLoad = "#attributes.autoLoad#?" />
	</cfif>
	<cfset attributes.autoLoad = "#attributes.autoLoad#&ajaxMode=1" />
	
	<!--- The Following ensures that any ExtJS ajax tabs load javascripts that are returned  --->
	<extjs:onReady>
		<cfoutput>Ext.Updater.defaults.loadScripts = true;</cfoutput>
	</extjs:onReady>

</cfif>
</cfoutput>


<cfinclude template="item.cfm" />

<cfsetting enablecfoutputonly="false">

