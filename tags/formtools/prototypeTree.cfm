<cfsetting enablecfoutputonly="yes">

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
|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- Prototype Tree Tag that sets up javascript libraries surrounds the tree with appopriate divs and content divs$


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.ID"  default="pt_#application.fc.utils.createJavaUUID()#">
	<cfparam name="attributes.bAllowRootSelection"  default="false">
	
	<cfset variables.stPrototypeTree = structNew() />
	<cfset variables.stPrototypeTree.ID = attributes.ID />
	<cfset variables.stPrototypeTree.ul = 0 /> <!--- Keeps track of the level of the last node to correctly close out the content divs. --->
	<cfset variables.stPrototypeTree.nPos = 0 /> <!--- Keeps track of the level of the last node to correctly close out the content divs. --->
	<cfset variables.stPrototypeTree.aNodes = ArrayNew(1) /> <!--- Keeps track of the Nodes that need to be rendered. --->

	<!--- // initialise counters --->
	<cfset variables.stPrototypeTree.currentlevel=0> <!--- // nLevel counter --->
	<cfset variables.stPrototypeTree.previouslevel=0>
	<cfset variables.stPrototypeTree.ul=0> <!--- // nested list counter --->

		
	<cfset variables.stPrototypeTree.o = createObject("component","farcry.core.packages.farcry.prototypeTree") />
		
	<cfset Request>
	<cfoutput><div id="treewrap_#attributes.id#"></cfoutput>

</cfif>

<cfif thistag.executionMode eq "End">
		
		
	<cfset stFirstNode = stPrototypeTree.aNodes[1] />
	<cfset stLastNode = stPrototypeTree.aNodes[arrayLen(stPrototypeTree.aNodes)] />
	
	<cfset stLevelSpacerIcon = structNew() />
	
	<cfloop from="1" to="#arrayLen(stPrototypeTree.aNodes)#" index="i">
		
		<cfset stPreviousNode = StructNew() />
		<cfset stCurrentNode = StructNew() />
		<cfset stNextNode = StructNew() />
		
		<!--- SETUP Positional Row Information --->
		<cfset previousNodeRow = i - 1 />
		<cfset currentNodeRow = i />
		<cfset nextNodeRow = i + 1 />
		
		<cfif previousNodeRow GTE 1>
			<cfset stPreviousNode = stPrototypeTree.aNodes[previousNodeRow]>	
		</cfif>
		
		<cfset stCurrentNode = stPrototypeTree.aNodes[currentNodeRow]>
		
		<cfif nextNodeRow LTE arrayLen(stPrototypeTree.aNodes)>
			<cfset stNextNode = stPrototypeTree.aNodes[nextNodeRow]>
		</cfif>
			
		<cfif structKeyExists(stPreviousNode, "nLevel") AND stPreviousNode.nLevel GTE stCurrentNode.nLevel>
			<cfoutput>#repeatString("</div>", stPreviousNode.nLevel - stCurrentNode.nLevel + 1)#</cfoutput>
		</cfif>
			
			

		<cfset openIcon = "bmo">
		<cfset closedIcon = "bmc">
		
		<!--- basic node. No children --->
		<cfif stCurrentNode.nRight - stCurrentNode.nLeft EQ 1>
			<cfset openIcon = "nme">	
			<cfset closedIcon = "nme">				
		</cfif>
		
		<!--- last child. --->
		<cfif NOT structKeyExists(stNextNode, "nLevel") OR  stNextNode.nLevel LT stCurrentNode.nLevel>
			<cfset openIcon = "nbe">	
			<cfset closedIcon = "nbe">				
		</cfif>	
		
		<!--- Very First Node --->
		<cfif stCurrentNode.currentrow EQ 1 >
			<cfset openIcon = "bno">
			<cfset closedIcon = "bnc">
		</cfif>
		
		<!--- Last Child node of each level of Root Node --->
		<cfif stCurrentNode.nRight GT stLastNode.nRight>
			<cfset stLevelSpacerIcon['#stCurrentNode.nLevel#'] = "s">
			
			<cfif stCurrentNode.currentrow NEQ 1 >
				<cfset openIcon = "bbo">
				<cfset closedIcon = "bbc">
			</cfif>
		<cfelse>	
			<cfset stLevelSpacerIcon['#stCurrentNode.nLevel#'] = "c">
						
			<!--- Need to check if this is the last Child. If So, then the spacer needs to be clear, otherwise its the normal line. --->
			<cfloop from="#stCurrentNode.CurrentRow + 1#" to="#arrayLen(stPrototypeTree.aNodes)#" index="i">
				
				<cfif stPrototypeTree.aNodes[i].nLevel EQ stCurrentNode.nLevel>
					<!--- next item on same level so ok to have line --->
					<cfbreak>
				</cfif>
				<cfif stPrototypeTree.aNodes[i].nLevel LT stCurrentNode.nLevel>
					<!--- last Child of parent so need to have blank space --->
					<cfset stLevelSpacerIcon['#stCurrentNode.nLevel#'] = "s">
					
					<!--- Has Children so put in toggle image --->
					<cfif stNextNode.nLevel GT stCurrentNode.nLevel>
						<cfset openIcon = "bbo">
						<cfset closedIcon = "bbc">
					</cfif>
					<cfbreak>
				</cfif>
			</cfloop>			
		</cfif>
		
		<cfif stCurrentNode.nLevel LTE 1>
			<cfset state = "open">
		<cfelse>
			<cfset state = "closed">
		</cfif>

		<!--- If we are not to allow the root node to be selected and this is the root node then set flag to false. --->
		<cfif NOT attributes.bAllowRootSelection AND  stCurrentNode.nLevel EQ stFirstNode.nLevel>
			<cfset bAllowSelection = "false">
		<cfelse>
			<cfset bAllowSelection = "true">
		</cfif>
		
					
			
 		<!---// write the link  --->	
		<cfset node = stPrototypeTree.o.nodeicon(
				id='#attributes.ID#',
				NodeID='#stCurrentNode.NodeID#',
				text='#stCurrentNode.text#',
				openIcon='#openIcon#',
				closedIcon='#closedIcon#',
				state='#state#',
				bAllowSelection='#stCurrentNode.bAllowSelection#',
				stLevelSpacerIcon='#stLevelSpacerIcon#',
				level='#stCurrentNode.nLevel#', 
				value='#stCurrentNode.ID#',
				lSelectedItems='#stCurrentNode.lSelectedItems#', 
				bSelectMultiple='#stCurrentNode.bSelectMultiple#') />
				
			<cfoutput>
				#node#
				<div id="#stCurrentNode.NodeID#_wrap_content" class="node_wrap_content" <cfif stCurrentNode.State EQ "closed"> style="display:none;" </cfif> > 
			</cfoutput>
	</cfloop>
	
	<!--- // end of data, close open items and lists --->
	<cfoutput>#repeatString("</div>",stCurrentNode.nLevel)#</cfoutput>

	<cfoutput></div></cfoutput>
	
	<cfoutput>
	<script language="javascript">
		inittree('treewrap_#attributes.id#');
	</script>

	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">