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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
<!--- @@displayname: ExtJS Tool Tip --->
<!--- @@description: Displays a tool tip on hover.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="attributes.title" default="" /><!--- The title of the message --->
<cfparam name="attributes.toolTip" default="" /><!--- The actual message. This can be replaced with generatedContent --->


<cfif thistag.executionMode eq "Start">
	<!--- IGNORE START MODE --->
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfset toolTipID = createUUID() />	
	
	<cfsavecontent variable="toolTipHTML">
		
		<cfoutput><span id="#toolTipID#">#thisTag.generatedContent#</span></cfoutput>
		
		<skin:htmlHead library="extJS" />
		
		<extjs:onReady>
		<cfoutput>
			 new Ext.ToolTip({   
			   target: Ext.get('#toolTipID#'),
			   title: '#jsStringFormat(attributes.title)#',
			   html: '#jsStringFormat(attributes.toolTip)#',
			   autoHide:true
			   });
		</cfoutput>
		</extjs:onReady>
	
	</cfsavecontent>
	
	<cfset thisTag.generatedContent = toolTipHTML />
	
</cfif>

<cfsetting enablecfoutputonly="false">