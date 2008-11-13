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
<!--- @@displayname: Renders Tab Display  --->
<!--- @@description: A facade call for layout  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">


<cfparam name="attributes.bGlobalVar" default="true" />
<cfparam name="attributes.id" default="#replace('tab_' & application.fc.utils.createJavaUUID(),'-','_','ALL')#" />
<cfparam name="attributes.renderTo" default="#attributes.id#-div" />
<cfparam name="attributes.activeTab" default="" />
<cfparam name="attributes.width" default="100%" />
<cfparam name="attributes.frame" default="true" />
<cfparam name="attributes.defaults" default="{autoHeight: true}" />
<cfparam name="attributes.stListeners" default="#structNew()#" />

<cfset attributes.container = "TabPanel" />
<cfset attributes.stateEvents = "['tabchange']" />

<cfif not len(attributes.activeTab)>
	<cfset attributes.activeTab = "Ext.state.Manager.get('active_tab_#attributes.id#', 0)" />
</cfif>

<cfsavecontent variable="attributes.stListeners.tabchange">
	<cfoutput>function(){Ext.state.Manager.set('active_tab_#attributes.id#', this.getActiveTab().getId());}</cfoutput>
</cfsavecontent>

<cfif not structIsEmpty(attributes.stListeners)>
	<cfset attributes.listeners = "" />
	<cfloop collection="#attributes.stListeners#" item="listener">
		<cfset attributes.listeners = listAppend(attributes.listeners, "'#listener#': #attributes.stListeners[listener]#")>
	</cfloop>
	
	<cfset attributes.listeners = "{#attributes.listeners#}" />
</cfif>

			
<cfinclude template="layout.cfm" />

<extjs:onReady>
	<cfoutput>Ext.state.Manager.setProvider(new Ext.state.CookieProvider());</cfoutput>
</extjs:onReady>

<cfsetting enablecfoutputonly="false">

