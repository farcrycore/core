<cfsetting enablecfoutputonly="yes" />

<cfif isDefined("request.ver") and request.ver>
	<cfoutput><!-- _genericNav $Revision: 1.3 $ --></cfoutput>
</cfif>


<cfset Request.InHead.prototypeTree = 1>

<cffunction name="nodeicon" output="true">
	<cfargument name="id" type="string" default="">
	<cfargument name="text" type="string" default="">
	<cfargument name="level" type="numeric" default="0">
	<cfargument name="value" type="string" default="">
	<cfargument name="openIcon" type="string" default="branch_top_open">
	<cfargument name="closedIcon" type="string" default="branch_top_closed">
	<cfargument name="state" type="string" default="open">

	<cfif arguments.state EQ "open">
		<cfset variables.useIcon = arguments.openIcon>
	<cfelse>
		<cfset variables.useIcon = arguments.closedIcon>
	</cfif>
	
	<cfsavecontent variable="sreturn">
		<cfoutput>
			<div class="node_table_wrap" id="#arguments.id#_node_table_wrap">
			<table cellspacing="0" cellpadding="0" id="#arguments.id#" style="height:16px;" class="node_table">
			<tr>
				<cfif arguments.level GT 0>
					<cfloop from="1" to="#arguments.level-1#" index="i">
						<td style="background-image: url(#application.url.farcry#/images/treeimages/#levelSpacerIcon['#i#']#.gif); background-repeat: repeat-y;width:16px;"><img width="16"
						    height="16"
						    src="#application.url.farcry#/images/treeimages/#levelSpacerIcon['#i#']#.gif" /></td>
					</cfloop>
				</cfif>
				<td style="width:16px;"><img id='#arguments.id#_icon' src='#application.url.farcry#/images/treeimages/#variables.useIcon#.gif' class='nodeicon' openIcon='#arguments.openIcon#.gif' closedIcon='#arguments.closedIcon#.gif' /></td>
				<td style="width:16px;"><input id="#attributes.ID#" name="#attributes.ID#" type="checkbox" value="#arguments.value#" style="height:16px;width:16px;padding:0px;margin:0px;" <cfif listContainsNoCase(attributes.lSelectedItems,arguments.value)>checked</cfif>></td>
				<td>&nbsp;#arguments.text#</td>
			</tr>
			</table>
			</div>
		</cfoutput>
	</cfsavecontent>
	<cfreturn sreturn>
</cffunction>



<cfscript>
	// 
	// Description:	This incredible piece of code builds nested lists from dmNavigation data
	// Author:		Ben Bishop (ben@daemon.com.au)
	// Version:		1.5
	// 
	// in:
	// 		navID			uuid		parent objectID
	// 		depth			integer		number of descendant levels to query
	// 		id				string		id of UL (typically for CSS)
	// 		class			string		CSS class of UL
	// 		flagfirst		boolean		flag to distinguish the first item
	// 
	// 		functionMethod	string		tree method, defaults to getDescendants
	// 		functionArgs	list		list of arguments for method
	
	// set defaults for attributes not passed
	if(not isDefined("attributes.navID") or len(attributes.navID) neq 35) 
		attributes.navID="E24C915F-D9B2-7474-64BCD5E2BAFF07B2";
	if(not isDefined("attributes.depth") or not isNumeric(attributes.depth)) 
		attributes.depth=1;
	if(not isDefined("attributes.startLevel") or not isNumeric(attributes.startLevel)) 
		attributes.startLevel=0;
	if(not isDefined("attributes.id") or not len(attributes.id)) 
		attributes.id="";
	if(not isDefined("attributes.class") or not len(attributes.class)) 
		attributes.class="";
	if(not isDefined("attributes.bFirst") or not isBoolean(attributes.bFirst)) 
		attributes.bFirst=0;
	if(not isDefined("attributes.bActive") or not isBoolean(attributes.bActive)) 
		attributes.bActive=0;
	if(not isDefined("attributes.bIncludeHome") or not len(attributes.bIncludeHome)) 
		attributes.bIncludeHome=0;
	
	if(not isDefined("attributes.functionMethod") or not len(attributes.functionMethod)) 
		attributes.functionMethod="getDescendants";
	if(not isDefined("attributes.functionArgs") or not len(attributes.functionArgs)) 
		attributes.functionArgs="depth=#attributes.depth#";
	
	if(not isDefined("attributes.bDump") or not isBoolean(attributes.bDump)) 
		attributes.bDump=0;

	// check if Friendly URLs enabled
	if(application.config.plugins.fu)
		fu = createObject("component","#application.packagepath#.farcry.fu");

	// get navigation items
	o = createObject("component", "#application.packagepath#.farcry.tree");
	navFilter=arrayNew(1);
	
	qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, "&attributes.functionArgs&", afilter=navFilter, bIncludeSelf=true)");
	
</cfscript>

<cfparam name="attributes.lSelectedItems" default="" type="string">

<cfif attributes.bDump>
	<cfdump var="#attributes#">
	<cfdump var="#qNav#">
</cfif>


	<cfset levelSpacerIcon = structNew()>

	<!--- // initialise counters --->
	<cfset currentlevel=0> <!--- // nLevel counter --->
	<cfset previouslevel=0>
	<cfset ul=0> <!--- // nested list counter --->
	
			
	<cfset lastLevel=qNav.nLevel[qNav.recordcount]>
	<cfset lastLeft=qNav.nLeft[qNav.recordcount]>
	<cfset lastRight = qNav.nRight[qNav.recordcount]>
	
	
	
	<cfoutput><div id="#attributes.id#"></cfoutput>
	<!--- // build menu [bb: this relies on nLevels, starting from nLevel 2] --->
	<cfloop query="qNav" ><!--- for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1) --->
	<!--- { --->
		<cfif qNav.nLevel gte attributes.startLevel>
			
			<cfset NodeID = "#attributes.ID#_node_#qNav.ObjectID#" />
		

			
			<!--- // update counters --->
			<cfset previouslevel=qNav.nLevel[qNav.currentrow-1]>
			<cfset currentlevel=qNav.nLevel>
			<cfset nextlevel = qNav.nLevel[qNav.currentrow+1]>
			
			<cfset previousLeft=qNav.nLeft[qNav.currentrow-1]>
			<cfset currentLeft=qNav.nLeft>
			<cfset nextLeft = qNav.nLeft[qNav.currentrow+1]>
			
			<cfset previousRight=qNav.nRight[qNav.currentrow-1]>
			<cfset currentRight=qNav.nRight>
			<cfset nextRight = qNav.nRight[qNav.currentrow+1]>




			
			
			
			

			
			<cfif (currentlevel gt previouslevel)>
				<!--- // if new level or first item, open new list --->
		 		<!--- <cfoutput><div id="#NodeID#_wrap_outer" class="node_wrap_outer"></cfoutput> --->
		 		<!--- <cfoutput><ul></cfoutput> --->
				<cfset ul=ul+1>
			
			<cfelseif (currentlevel lt previouslevel)>
			
				<!--- // if end of level, close items and lists until at correct level --->
				
				<!--- <cfoutput>#repeatString("</li></ul></li>",previousLevel-currentLevel)#</cfoutput> --->
				<cfset ul=ul-(previousLevel-currentLevel)>
			<cfelse>
				<!--- <cfoutput></div></div><!--- CLOSE node_wrap_inner & node_wrap_content ---></cfoutput> --->
				<!--- // close item --->
				<!--- <cfoutput> </li> </cfoutput> --->
			</cfif>

			<cfif previousLevel GTE currentLevel>
				<cfoutput>#repeatString("</div>",previousLevel-currentLevel+1)#</cfoutput>
			</cfif>
			<!--- <cfoutput><div id="#NodeID#_wrap_inner" class="node_wrap_inner"></cfoutput> --->
			
		<!--- 	<!--- // open a list item --->
			<cfoutput> <li </cfoutput>
			
			<cfif (len(trim(itemclass)))>
				<!--- // add a class --->
				 <cfoutput> class="#trim(itemclass)#" </cfoutput>
			</cfif>
			
			<cfoutput> > </cfoutput>
			 --->
			
			
			<cfset openIcon = "bmo">
			<cfset closedIcon = "bmc">
			
			<!--- basic node. No children --->
			<cfif qNav.nRight - qNav.nLeft EQ 1>
				<cfset openIcon = "nme">	
				<cfset closedIcon = "nme">				
			</cfif>
			
			<!--- last child. --->
			<cfif nextlevel LT currentLevel>
				<cfset openIcon = "nbe">	
				<cfset closedIcon = "nbe">				
			</cfif>	
			
			<!--- Very First Node --->
			<cfif qNav.currentrow EQ 1 >
				<cfset openIcon = "bno">
				<cfset closedIcon = "bnc">
			</cfif>
			
			<!--- Last Child node of each level of Root Node --->
			<cfif currentRight GT lastRight>
				<cfset levelSpacerIcon['#ul#'] = "s">
				
				<cfif qNav.currentrow NEQ 1 >
					<cfset openIcon = "bbo">
					<cfset closedIcon = "bbc">
				</cfif>
			<cfelse>	
				<cfset levelSpacerIcon['#ul#'] = "c">
							
				<!--- Need to check if this is the last Child. If So, then the spacer needs to be clear, otherwise its the normal line. --->
				<cfloop from="#qNav.CurrentRow + 1#" to="#qNav.RecordCount#" index="i">
					
					<cfif qNav.nLevel[i] EQ qNav.nLevel>
						<!--- next item on same level so ok to have line --->
						<cfbreak>
					</cfif>
					<cfif qNav.nLevel[i] LT qNav.nLevel>
						<!--- last Child of parent so need to have blank space --->
						<cfset levelSpacerIcon['#ul#'] = "s">
						
						<!--- Has Children so put in toggle image --->
						<cfif nextlevel GT currentLevel>
							<cfset openIcon = "bbo">
							<cfset closedIcon = "bbc">
						</cfif>
						<cfbreak>
					</cfif>
				</cfloop>			
			</cfif>
			
			<cfif ul LTE 1>
				<cfset state = "open">
			<cfelse>
				<cfset state = "closed">
			</cfif>

			
			<!--- // write the link --->
			<cfoutput>#nodeicon(id='#NodeID#',text='#qNav.ObjectName#',level='#ul#', value='#qNav.objectID#', openIcon='#openIcon#',closedIcon='#closedIcon#', state='#state#')#</cfoutput>
			
			<cfoutput><div id="#NodeID#_wrap_content" class="node_wrap_content" <cfif state EQ "closed"> style="display:none;" </cfif> > </cfoutput>
			
			<!--- <cfoutput> ><a href="#href#">#trim(qNav.ObjectName)#</a> </cfoutput> --->
			
		</cfif>
	</cfloop>
	
	<!--- // end of data, close open items and lists --->
	<cfoutput>#repeatString("</div>",ul)#</cfoutput>
	<!--- <cfoutput>#repeatString("</li></ul>",ul)#</cfoutput> --->

	<cfoutput></div></cfoutput>
	
	<cfoutput>
	<script language="javascript">
		inittree('#attributes.id#');
	</script>
	</cfoutput>

<cfsetting enablecfoutputonly="no" />