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
	
	<cfset toolTipID = application.fc.utils.createJavaUUID() />	
	
	<cfsavecontent variable="toolTipHTML">
		
		<cfoutput><span id="#toolTipID#">#thisTag.generatedContent#</span></cfoutput>
		
		<skin:loadCSS library="jquery-tools">
		<cfoutput>
		/* tooltip styling. uses a background image (a black box with an arrow) */ 
		div.tooltip { 
		    background:transparent url(#application.url.webtop#/thirdparty/jquery-tools/img/black_arrow_big.png) no-repeat scroll 0 0; 
		    font-size:14px; 
		    height:153px; 
		    padding:30px; 
		    width:310px; 
		    font-size:14px; 
		    display:none; 
		    color:##fff; 
		} 
		 
		/* tooltip title element (h3) */ 
		div.tooltip h3 { 
		    margin:0; 
		    font-size:18px; 
		    color:##fff; 
		}
		</cfoutput>
		</skin:loadCSS>
		
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