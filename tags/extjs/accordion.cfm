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
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START TAG
 ------------------>




<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.id" default="#createUUID()#">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.icon" default="">
	<cfparam name="attributes.aPanels" default="#arrayNew(1)#"><!--- An array of Panels --->
	<cfparam name="attributes.stConfig" default="#structNew()#">
	<cfparam name="attributes.stConfig.width" default="300">
	<cfparam name="attributes.stConfig.height" default="400">
	<cfparam name="attributes.stConfig.shim" default="false">
	<cfparam name="attributes.stConfig.border" default="true">
	<cfparam name="attributes.stConfig.frame" default="true">
	<cfparam name="attributes.stConfig.fill" default="false">

		
	<skin:htmlHead library="extJS" />

		
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset thisTag.GeneratedContent = "" />
	

						

	<cfoutput><div id="#attributes.id#"></cfoutput>
	<cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">
		<cfoutput>
		<div id="menugroup-#attributes.aPanels[i].id#">#attributes.aPanels[i].html#</div>
		</cfoutput>
	</cfloop>
	<cfoutput></div></cfoutput>
	


	<!--- When rendering nested ui elements like tabs and accordions, we need to render the outer elements first. Hence the position="first" attribute. --->
	<skin:htmlHead position="last">
	<cfoutput>
	<script type="text/javascript">
	Ext.BLANK_IMAGE_URL = '#application.url.webtop#/js/ext/resources/images/default/s.gif';
	
	Ext.onReady(function() {

		new Ext.Panel({
			renderTo: '#attributes.id#'
			<cfif len(attributes.title)>,title: '#attributes.title#'</cfif>
            ,layout:'accordion'
            ,layoutConfig: {
                animate:false
            }
			
			<cfif arrayLen(attributes.aPanels)>
				,items: [
	
				<cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">
					{
					    title: '#attributes.aPanels[i].title#'
					    ,contentEl:'menugroup-#attributes.aPanels[i].id#'
					    ,autoScroll:true
					}
					
					<cfif i LT arrayLen(attributes.aPanels)>,</cfif>
		  
		
				</cfloop>
				
				
				]
			</cfif>
			
			<cfif not structIsEmpty(attributes.stConfig)>
		        <cfloop list="#structKeyList(attributes.stConfig)#" index="i">
		        	<cfif len(attributes.stConfig[i])>
			        	,#i#:#attributes.stConfig[i]#
		        	</cfif>
		        </cfloop>
		    </cfif>
		});
		
		



	});
	</script>
	</cfoutput>
	</skin:htmlHead>
	

</cfif>

<cfsetting enablecfoutputonly="false">

