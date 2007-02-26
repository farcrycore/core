<cfcomponent displayName="Prototype Collapsible Tree" output="false" hint="Creates a Node in a Collapsible Tree built using the Prototype library.">


	<cffunction name="nodeicon" output="true">
		<cfargument name="id" type="string" default="">
		<cfargument name="NodeID" type="string" default="">
		<cfargument name="text" type="string" default="">
		<cfargument name="level" type="numeric" default="0">
		<cfargument name="value" type="string" default="">
		<cfargument name="openIcon" type="string" default="branch_top_open">
		<cfargument name="closedIcon" type="string" default="branch_top_closed">
		<cfargument name="state" type="string" default="open">
		<cfargument name="bSelectMultiple" type="boolean" default="true">
		<cfargument name="bAllowSelection" type="boolean" default="true"> <!--- Should we render the checkbox/radio formfield? --->
		<cfargument name="lSelectedItems" type="string" default=""><!--- list of items currently selected in the tree --->		
		<cfargument name="stlevelSpacerIcon" type="struct" default="#structNew()#"><!--- name of icon (minus suffix) located in /farcry/images/treeimages/ --->
	
		<cfset var.useIcon = arguments.openIcon>
		<cfset var.inputType = "checkbox">
	
<!---		<cfif not structKeyExists(arguments.stLevelSpacerIcon,level)>
			<cfset arguments.stLevelSpacerIcon[level] = "s" /> <!--- Defaults to empty shim image --->
		</cfif>	 --->
		
		<cfset Request.InHead.prototypeTree = 1>
		
		<cfif arguments.state EQ "open">
			<cfset useIcon = arguments.openIcon>
		<cfelse>
			<cfset useIcon = arguments.closedIcon>
		</cfif>	
		
		<cfif arguments.bSelectMultiple>
			<cfset inputType = "checkbox">
		<cfelse>
			<cfset inputType =  "radio">
		</cfif>
		
		<cfsavecontent variable="sreturn">
			<cfoutput>
				<div class="node_table_wrap" id="#arguments.NodeID#_node_table_wrap">
				<table cellspacing="0" cellpadding="0" id="#arguments.NodeID#" style="height:16px;" class="node_table">
				<tr>
					<cfif arguments.level GT 0>
						<cfloop from="1" to="#arguments.level-1#" index="i">
							<td style="background-image: url(#application.url.farcry#/images/treeimages/#arguments.stLevelSpacerIcon[i]#.gif); background-repeat: repeat-y;width:16px;"><img width="16"
							    height="16"
							    src="#application.url.farcry#/images/treeimages/#arguments.stLevelSpacerIcon[i]#.gif" /></td>
						</cfloop>
					</cfif>
					<td style="width:16px;"><img id='#arguments.NodeID#_icon' src='#application.url.farcry#/images/treeimages/#variables.useIcon#.gif' class='nodeicon' openIcon='#arguments.openIcon#.gif' closedIcon='#arguments.closedIcon#.gif' /></td>
			</cfoutput>
			
			<cfif arguments.bAllowSelection>
					<cfoutput><td style="width:16px;"><input id="#arguments.ID#" name="#arguments.ID#" type="#inputType#" value="#arguments.value#" style="height:16px;width:16px;padding:0px;margin:0px;" <cfif listContainsNoCase(arguments.lSelectedItems,arguments.value)>checked</cfif>></td>
					<td>&nbsp;#arguments.text#</td></cfoutput>
			<cfelse>
					<cfoutput><td colspan="2">&nbsp;#arguments.text#</td></cfoutput>
			</cfif>
					
				<cfoutput></tr>
				</table>
				</div></cfoutput>
				
		</cfsavecontent>
		<cfreturn sreturn>
	</cffunction>
	
	
</cfcomponent>