<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
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