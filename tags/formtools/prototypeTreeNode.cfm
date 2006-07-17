<cfsetting enablecfoutputonly="yes">

 <!---
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->


<cfset ParentTag = GetBaseTagList()>
<cfif NOT ListFindNoCase(ParentTag, "cf_prototypeTree")>
	<cfabort showerror="You cant use the the ft:prototypeTreeNode outside of an ft:prototypeTree...">
</cfif>
<cfset stBaseTag = GetBaseTagData("cf_prototypeTree")>
<cfset stPrototypeTree = stBaseTag.stPrototypeTree>



<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id" default="#createUUID()#"><!--- This is the id that will be used in the form field. --->
	<cfparam name="attributes.text" default="default text"><!--- The text that will be displayed in the tree node. --->
	<cfparam name="attributes.lSelectedItems" default=""><!--- The list of items that have already been selected in the tree. --->
	<cfparam name="attributes.bSelectMultiple" default="true"><!--- Can the user select multiple items in the tree.. --->
	<cfparam name="attributes.openIcon" default="branch_top_open">
	<cfparam name="attributes.closedIcon" default="branch_top_closed">
	<cfparam name="attributes.state" default="open">
	<cfparam name="attributes.bAllowSelection"  default="true"> <!--- Should we render the checkbox/radio formfield? --->
		
	<!--- We need to increment the level of the tree we are currently at. --->
	<cfset stPrototypeTree.UL = stPrototypeTree.UL + 1>
	<cfset stPrototypeTree.nPos = stPrototypeTree.nPos + 1>
	
	<!--- Create the structure containing the details for this node. --->	
	<cfset stNode = StructNew() />
	<cfset stNode.ID = attributes.ID /><!--- ObjectID of the node. --->
	<cfset stNode.NodeID = "#stPrototypeTree.ID#_node_#attributes.ID#" /><!--- This will identify the actual node we are rendering. --->
	<cfset stNode.CurrentRow = ArrayLen(stPrototypeTree.aNodes) + 1 />
	<cfset stNode.nLevel = stPrototypeTree.UL />
	<cfset stNode.nLeft = stPrototypeTree.nPos />	
	
	<cfset stNode.text = attributes.text />
	<cfset stNode.lSelectedItems = attributes.lSelectedItems /><!--- The list of items that have already been selected in the tree. --->
	<cfset stNode.bSelectMultiple = attributes.bSelectMultiple /><!--- Can the user select multiple items in the tree.. --->
	<cfset stNode.openIcon = attributes.openIcon />
	<cfset stNode.closedIcon = attributes.closedIcon />
	<cfset stNode.state = attributes.state />
	<cfset stNode.bAllowSelection = attributes.bAllowSelection /> <!--- Should we render the checkbox/radio formfield? --->
	
		
	<cfset ArrayAppend(stPrototypeTree.aNodes,stNode) />
	
	<cfif NOT structKeyExists(stPrototypeTree,"stFirstNode")>		
		<cfset stPrototypeTree.stFirstNode = stNode>
	</cfif>
	
	<cfset stPrototypeTree.stLastNode = stNode>
	
<!--- 		<!---// write the link  --->	
		<cfset node = stPrototypeTree.o.nodeicon(id='#NodeID#',text='#attributes.text#',
				openIcon='#attributes.openIcon#',
				closedIcon='#attributes.closedIcon#',
				state='#attributes.state#',
				bAllowSelection='#attributes.bAllowSelection#',
				levelSpacerIcon='#attributes.levelSpacerIcon#',
				level='#stPrototypeTree.UL#', 
				value='#attributes.ID#',
				lSelectedItems='#attributes.lSelectedItems#', 
				bSelectMultiple='#attributes.bSelectMultiple#') /> --->
		
<!---		<cfoutput>
			#node#
			<div id="#NodeID#_wrap_content" class="node_wrap_content" <cfif attributes.State EQ "closed"> style="display:none;" </cfif> > 
		</cfoutput> --->

</cfif>

<cfif thistag.executionMode eq "End">
	<!---<cfoutput></div></cfoutput> --->
	
	
	<cfset stPrototypeTree.UL = stPrototypeTree.UL - 1>
	<cfset stPrototypeTree.nPos = stPrototypeTree.nPos + 1>
	<cfset stNode.nRight = stPrototypeTree.nPos />
	
	
</cfif>

<cfsetting enablecfoutputonly="no">
