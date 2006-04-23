<cfsetting enablecfoutputonly="Yes">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header onLoad="startTimer();">

<cfimport taglib="/farcry/tags/" prefix="farcry">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/misc/" prefix="misc">

<cfparam name="url.section" default="Home">

<!--- ### User Session Details ### --->
<cfoutput>
<div class="countDown">
	Logged in as: <cfoutput><strong>#request.stLoggedInUser.userlogin#</strong><br></cfoutput>	
	<form name="timer" style="display:inline"><input type=hidden name=timer value=""><input class="counter" type="text" name="clock" size="7" value="60:00"> remaining in session</form>
</div>
</cfoutput>

<!--- #### Header ###  --->
<cfoutput>
<div id="Header">
<span class="title">FarCry</span><br />
<span class="description">tell it to someone who cares</span>
</cfoutput>

		<!--- 
		determine appropriate security priveleges for this user.  These will
		be used to determine the presence of menu items 
		
		<cf_dmSec2_PermissionCheck
			permissionName="SecurityManagement" 
			reference1="PolicyGroup" 
			r_iState="iSecurityManagementState">
		<cf_dmSec2_PermissionCheck 
			permissionName="ModifyPermissions" 
			reference1="PolicyGroup" 
			r_iState="iModifyPermissionsState">
		<cf_dmSec2_PermissionCheck 
			permissionName="Developer"
			reference1="PolicyGroup" 
			r_iState="iDeveloperState">
		 <cf_dmSec2_PermissionCheck 
			permissionName="RootNodeManagement"
			reference1="PolicyGroup"
			r_iState="iRootNodeManagement"> --->
		
		<cfoutput><div class="mainTabArea" align="right"></cfoutput>
			<!--- display main tabs in header, and check if tab is active --->
			<farcry:tabs>
				<cfif url.section eq "home">
					<farcry:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Home" target="_top" text="Home">
				<cfelse>
					<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Home" target="_top" text="Home">
				</cfif>
				<cfif url.section eq "site">
						<farcry:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Site" target="_top" text="Site">
					<cfelse>
						<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Site" target="_top" text="Site">
				</cfif>
				<cfif url.section eq "dynamic">
					<farcry:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Dynamic" target="_top" text="Dynamic">
				<cfelse>
					<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Dynamic" target="_top" text="Dynamic">
				</cfif>
				<cfif url.section eq "admin">
					<farcry:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Admin" target="_top" text="Admin">
				<cfelse>
					<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Admin" target="_top" text="Admin">
				</cfif>
				<cfif url.section eq "security">
					<farcry:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Security" target="_top" text="Security">
				<cfelse>
					<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Security" target="_top" text="Security">
				</cfif>
				<farcry:tabitem class="tab" href="#application.url.farcry#/index.cfm?logout=1" target="_top" text="Logout">
			</farcry:tabs>
		<cfoutput></div>
</div></cfoutput>
	
	<cfif url.section eq "home">
		<cfinclude template="home.cfm">
	<cfelse>
	<cfoutput><div id="background">
		<!--- ### Column 1 ### --->
		<div id="column1" class="tabBox" style="left:0px;" align="left">
			<div class="subTabArea"></cfoutput>
				<farcry:tabs>
					<!--- work out which tabs to display in left hand column --->
					<cfswitch expression="#url.section#">
					
						<!--- Show tabs for the site view (default view) --->
						<cfdefaultcase>
							<cfset url.section = "Site">
							<!--- Get Root Level --->
							<cfinvoke 
							 component="fourq.utils.tree.tree" method="getRootNode" returnvariable="getRootNodeRet">
								<cfinvokeargument name="dsn" value="#application.dsn#"/>
								<cfinvokeargument name="typename" value="dmNavigation"/>
							</cfinvoke>
							
							<!--- Get Level 1 Nodes --->
							<cfinvoke component="fourq.utils.tree.tree" method="getChildren" returnvariable="getChildrenRet">
								<cfinvokeargument name="dsn" value="#application.dsn#"/>
								<cfinvokeargument name="objectid" value="#getRootNodeRet.objectid#"/>
							</cfinvoke>
							
							<!--- Display root tab 
							<farcry:tabitem class="activesubtab" href="navajo/overview_frame.cfm?rootobjectid=#getRootNodeRet.objectid#" target="treeFrame" text="Root"   onclick="synchTab('treeFrame','activesubtab','subtab','#getRootNodeRet.objectid#')" id="#getRootNodeRet.objectid#"> --->
							<!--- Loop over Level 1 nodes and display as tabs --->
							<cfloop query="getChildrenRet">
								<!--- Get details of each node --->
								<q4:contentobjectget objectid="#objectid#" typename="#application.packagepath#.types.dmNavigation" r_stobject="stobj">
								<!--- set up tab --->
								<cfif currentrow eq 1>
									<farcry:tabitem class="activesubtab" href="navajo/overview_frame.cfm?rootobjectid=#stobj.objectid#" target="treeFrame" text="#stobj.title#" onclick="synchTab('treeFrame','activesubtab','subtab','#stobj.objectid#')" id="#stobj.objectid#">
								<cfelse>
									<farcry:tabitem class="subtab" href="navajo/overview_frame.cfm?rootobjectid=#stobj.objectid#" target="treeFrame" text="#stobj.title#" onclick="synchTab('treeFrame','activesubtab','subtab','#stobj.objectid#')" id="#stobj.objectid#">
								</cfif>
								
							</cfloop>
						</cfdefaultcase>
						
						<!--- Show tabs for the dynamic view --->
						<cfcase value="dynamic">
							<farcry:tabitem class="activesubtab" href="dynamic/dynamicMenuframe.cfm" target="treeFrame" text="News">
						</cfcase>
						
						<!--- Show tabs for the admin view --->
						<cfcase value="admin">
							<farcry:tabitem class="activesubtab" href="admin/adminMenuframe.cfm" target="treeFrame" text="Admin">
						</cfcase>
						
						<!--- Show tabs for the security view --->
						<cfcase value="security">
							<farcry:tabitem class="activesubtab" href="security/securityMenuframe.cfm?type=security" target="treeFrame" text="Security" onclick="synchTab('treeFrame','activesubtab','subtab','securityTab')" id="securityTab">
							<farcry:tabitem class="subtab" href="security/securityMenuframe.cfm?type=policy" target="treeFrame" text="Policy" onclick="synchTab('treeFrame','activesubtab','subtab','policyTab')" id="policyTab">
						</cfcase>
					</cfswitch>
				</farcry:tabs>
			<cfoutput></div>
			<div class="tabMain">
				<div class="tabTitle" id="title"></cfoutput>		
					<!--- display section title --->
					<cfoutput>#url.section#&nbsp;</cfoutput>
					<cfif url.section eq "Site">
						<!--- display quick links in dropdown for tree --->
						<cfoutput>
						<form name="zoom" style="display:inline;">
							<select name="QuickZoom" onChange="window.frames.treeFrame.location.href = document.zoom.QuickZoom.options[document.zoom.QuickZoom.options.selectedIndex].value; return false;" class="field">
								<option value="navajo/overview_frame.cfm">-- Quick Zoom --</option>
								<option value="navajo/overview_frame.cfm">Root</option>
								</cfoutput>
								<!--- get descendants to display in dropdown for zooming (only for site admin) --->
								<cfloop query="getChildrenRet">
									<!--- <cfparam name="url.rootobjectid" default="#getRootNodeRet.objectid#"> --->
									<cfinvoke component="fourq.utils.tree.tree" method="getDescendants" returnvariable="getDescendantsRet">
										<cfinvokeargument name="dsn" value="#application.dsn#"/>
										<cfinvokeargument name="objectid" value="#objectid#"/>
									</cfinvoke>
																	
									<cfoutput query="getDescendantsRet">
										<!--- get descendant details --->
										<q4:contentobjectget objectid="#objectid#" typename="#application.packagepath#.types.dmNavigation" r_stobject="stobj">
										<!--- only show items that have a nav alias --->
										<cfif stobj.lnavidalias neq "">
											<option value="navajo/overview_frame.cfm?rootobjectid=#stobj.objectid#">#stobj.lnavidalias#</option>
										</cfif>
									</cfoutput>
								</cfloop>
							<cfoutput></select>
						</form>
						<span style="position: absolute; top:8px; right:5px;"><a href="javascript:window.frames.treeFrame.location.reload();"><img src="images/refresh.gif" alt="Refresh Tree" border="0"></a></span></cfoutput>
					</cfif>
				<cfoutput></div>
				<div class="tabIframeWrapper"></cfoutput>
					<!--- set default load page for the different sections --->
					<cfswitch expression="#url.section#">
						<cfcase value="site">
							<cfif isdefined("url.rootobjectid")>
								<cfset defaultPage="navajo/overview_frame.cfm?rootobjectid=#url.rootobjectid#">
							<cfelse>
								<cfset defaultPage="navajo/overview_frame.cfm?rootobjectid=#getChildrenRet.objectId#">
							</cfif>
						</cfcase>
						<cfcase value="dynamic">
							<cfset defaultPage="dynamic/dynamicMenuframe.cfm">
						</cfcase>
						<cfcase value="admin">
							<cfset defaultPage="admin/adminMenuframe.cfm">
						</cfcase>
						<cfcase value="security">
							<cfset defaultPage="security/securityMenuframe.cfm">
						</cfcase>
					</cfswitch>
					<!-- display left hand content -->
					<cfoutput><iframe class="tabContent" name="treeFrame" src="<cfoutput>#defaultPage#</cfoutput>" frameborder="0" onLoad="startTimer()"></iframe>
				</div>
			</div>
		</div></cfoutput>
		
		<!--- ### Resizer ### --->
		<cfoutput><div id="resizer" onmouseover="this.style.cursor='hand';this.style.background='##FF6600';" onmouseup="resizerup();" onmousemove="resizermove();" onmousedown="resizerdown();" onmouseout="this.style.background='##999';"></div></cfoutput>
		
		<!--- ### Column 2 ### --->
		<cfoutput><div id="column2" class="tabBox" style="right:0px;" align="left">
		  <div class="subTabArea"></cfoutput>
		   <farcry:tabs>
				<!--- work out which tabs to display in right hand column --->
				<cfswitch expression="#url.section#">
					<cfcase value="site">
						<farcry:tabitem class="activesubtab" href="edittabOverview.cfm?objectid=" target="editFrame" text="Overview" id="siteEditOverview" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditOverview');synchTitle('Overview')">
						<farcry:tabitem class="subtab" href="edittabEdit.cfm?objectid=" target="editFrame" text="Edit" id="siteEditEdit" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">	
						<farcry:tabitem class="subtab" href="edittabArchive.cfm?objectid=" target="editFrame" text="Archive" id="siteEditArchive" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditArchive');synchTitle('Archive')">
						<farcry:tabitem class="subtab" href="edittabAudit.cfm?objectid=" target="editFrame" text="Audit" id="siteEditAudit" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditAudit');synchTitle('Audit')">
						<farcry:tabitem class="subtab" href="edittabStats.cfm?objectid=" target="editFrame" text="Stats" id="siteEditStats" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditStats');synchTitle('Stats')">
						<farcry:tabitem class="subtab" href="edittabDump.cfm?objectid=" target="editFrame" text="Dump" id="siteEditDump" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditDump');synchTitle('Dump')">
					</cfcase>
					<cfdefaultcase>
						<farcry:tabitem class="activesubtab" href="##top" target="_self" text="Default">
					</cfdefaultcase>
				</cfswitch>
			</farcry:tabs>
		  <cfoutput></div>
		  <div class="tabMain">
			<div class="tabTitle" id="EditFrameTitle"></div>
			<div class="tabIframeWrapper"></cfoutput>
				<!--- set default load page for the different sections --->
				<cfswitch expression="#url.section#">
					<cfcase value="site">
						<cfset defaultPageRight="navajo/navajoHome.cfm">
					</cfcase>
					<cfcase value="dynamic">
						<cfif isdefined("url.objectid")>
							<cfset defaultPageRight="navajo/GenericAdmin.cfm?type=News&typename=dmNews&status=#url.status#">
						<cfelse>
							<cfset defaultPageRight="navajo/GenericAdmin.cfm?type=News&typename=dmNews">
						</cfif>
					</cfcase>
					<cfcase value="admin">
						<cfset defaultPageRight="admin/adminHome.cfm">
					</cfcase>
					<cfcase value="security">
						<cfset defaultPageRight="security/securityHome.cfm">
					</cfcase>
				</cfswitch>
				<cfoutput><iframe class="tabContent" name="editFrame" src="<cfoutput>#defaultPageRight#</cfoutput>" frameborder="0" onLoad="startTimer()"></iframe>
			</div>
		  </div>
		</div>
	</div></cfoutput>
	</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="No">