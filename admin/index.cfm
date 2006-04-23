<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/index.cfm,v 1.68.2.1 2005/04/29 03:12:04 guy Exp $
$Author: guy $
$Date: 2005/04/29 03:12:04 $
$Name: milestone_2-1-2 $
$Revision: 1.68.2.1 $

|| DESCRIPTION || 
$Description: Landing page for Farcry. Works out which section to display and associated pages according to permissions. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header onLoad="startTimer();">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<cfparam name="url.section" default="Home">

<!--- ### User Session Details ### --->
<cfoutput>
<div class="countDown">
	Logged in as: <strong>#session.dmSec.authentication.userlogin#</strong><br>	
	<form name="timer" style="display:inline"><input type=hidden name=timer value=""><input class="counter" type="text" name="clock" size="7" value="#application.config.general.sessionTimeOut#:00"> remaining in session</form>
</div>
</cfoutput>

<!--- #### Header ###  --->
<cfoutput>
<div id="Header">
<span class="title" onclick="location.href='index.cfm'" onmouseover="style.cursor='hand'" title="#application.config.general.siteTitle# | Home">#application.config.general.siteTitle#</span><br />
<span class="description" onclick="location.href='index.cfm'" onmouseover="style.cursor='hand'" title="#application.config.general.siteTitle# | Home">#application.config.general.siteTagLine#</span>
</cfoutput>
		
		<cfscript>
			//determine appropriate security priveleges for this user.  These will be used to determine the presence of menu items
			oAuthorisation = request.dmSec.oAuthorisation;
			q4 = createObject("component","farcry.fourq.fourq");
			iMyFarcryTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavMyFarcryTab");
			iSiteTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavSiteTab");
			iContentTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavContentTab");
			iAdminTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavAdminTab");
			iReportingTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavReportingTab");
			iSecurityTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavSecurityTab");
			iHelpTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
				
						
		</cfscript>
				
		<cfoutput><div class="mainTabArea" align="right"></cfoutput>
			<!--- display main tabs in header, and check if tab is active --->
			<admin:tabs>
				<cfif iMyFarcryTab eq 1>
					<cfif url.section eq "home">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Home" target="_top" title="My #application.config.general.siteTitle#" text="My #application.config.general.siteTitle#">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Home" target="_top" title="My #application.config.general.siteTitle#" text="My #application.config.general.siteTitle#">
					</cfif>
				</cfif>
				<cfif iSiteTab eq 1>
					<cfif url.section eq "site">
							<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Site" target="_top" title="Site Tree" text="Site">
						<cfelse>
							<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Site" target="_top" title="Site Tree" text="Site">
					</cfif>
				</cfif>
				<cfif iContentTab eq 1>
					<cfif url.section eq "dynamic">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Dynamic" target="_top" title="Content" text="Content">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Dynamic" target="_top" title="Content" text="Content">
					</cfif>
				</cfif>
				<cfif iAdminTab eq 1>
					<cfif url.section eq "admin">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Admin" target="_top" title="Administration Area" text="Admin">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Admin" target="_top" title="Administration Area" text="Admin">
					</cfif>
				</cfif>
				<!--- 
				************************************************************************
				Custom Admin Tab
				************************************************************************ 
				--->
				
				
				 <cfif isXMLDoc(application.customAdminXML)>
				 	<cftry>
					<cfset parentTabElements = XMLSearch(application.customAdminXML,"/customtabs/parenttab")>
					<cfloop from="1" to="#ArrayLen(parentTabElements)#" index="i">
					 
				  	 <cfscript>
					 	iCustomAdminTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="#application.customAdminXML.customtabs.parenttab[i].xmlattributes.permission#");
					</cfscript> 
										
					<cfif iCustomAdminTab eq 1>
		
						<cfif url.section eq "customadmin" AND URL.parenttabindex EQ i>
							<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=customAdmin&parenttabindex=#i#" target="_top" title="Administration Area" text="#application.customAdminXML.customtabs.parenttab[i].xmltext#">
						<cfelse>
							<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=customAdmin&parenttabindex=#i#" target="_top" title="Administration Area" text="#application.customAdminXML.customtabs.parenttab[i].xmltext#">
						</cfif>
					
					</cfif>
					</cfloop>
						<cfcatch>
							<!--- Do nothing --->
						</cfcatch>
					</cftry>
				</cfif>
					
				<cfif iSecurityTab eq 1>
					<cfif url.section eq "security">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Security" target="_top" title="Security Area" text="Security">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Security" target="_top" title="Security Area" text="Security">
					</cfif>
				</cfif>
				
				<cfif iReportingTab eq 1>
					<cfif url.section eq "reporting">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Reporting" target="_top" title="Reporting Area" text="Reporting">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Reporting" target="_top" title="Reporting Area" text="Reporting">
					</cfif>
				</cfif>
				<cfif iHelpTab eq 1>
					<cfif url.section eq "help">
						<admin:tabitem class="activetab" href="#application.url.farcry#/index.cfm?section=Help" target="_top" title="Help Area" text="Help">
					<cfelse>
						<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?section=Help" target="_top" title="Help Area" text="Help">
					</cfif>
				</cfif>
				<admin:tabitem class="tab" href="#application.url.webroot#/" target="_blank" title="viewSite" text="View Site">
				<admin:tabitem class="tab" href="#application.url.farcry#/index.cfm?logout=1" target="_top" title="Logout" text="Logout">
			</admin:tabs>
		<cfoutput></div>
</div>
</cfoutput>
	<cfif url.section eq "home">
		<cfif iMyFarcryTab eq 1>
			<cfinclude template="home.cfm">
		</cfif>
	<cfelse>
	<cfoutput><div id="background">
		<!--- ### Column 1 ### --->
		<div id="column1" class="tabBox" style="left:0px;" align="left">
			<div class="subTabArea" id="subTabArea"></cfoutput>
				<admin:tabs>
					<!--- work out which tabs to display in left hand column --->
					<cfswitch expression="#url.section#">
					
						<!--- Show tabs for the site view (default view) --->
						<cfdefaultcase>
							<cfset url.section = "Site">
							<cfscript>
								// Get Root Level
								getRootNodeRet = request.factory.oTree.getRootNode(typename="dmNavigation");
								// Get Level 1 Nodes
								getChildrenRet = request.factory.oTree.getChildren(objectid=getRootNodeRet.objectid);
								odmNav = createObject("component",application.types.dmNavigation.typePath);
							</cfscript>
								
							<!--- Display root tab 
							<admin:tabitem class="activesubtab" href="navajo/overview_frame.cfm?rootobjectid=#getRootNodeRet.objectid#" target="treeFrame" text="Root"   onclick="synchTab('treeFrame','activesubtab','subtab','#getRootNodeRet.objectid#')" id="#getRootNodeRet.objectid#"> --->
							<!--- Loop over Level 1 nodes and display as tabs --->
							<cfloop query="getChildrenRet">
								<!--- Get details of each node --->
								
							<cfscript>
								stObj = odmNav.getData(objectid=getChildrenRet.objectid);
								//For the user to see any of these tabs - they must have at least one relevant dmNavigation permission on it.
								if(isdefined("application.navid.hidden") and stObj.objectid IS application.navid.hidden)
									lPermissions = 'Edit,Create,Delete,Approve';
								else	
									lPermissions = 'View,Edit,Create,Delete,Approve';
								aPermissions = listToArray(lPermissions);
								
								bHasPerm = 0;
								for (x=1;x LTE arrayLen(aPermissions);x=x+1)
								{	
									bHasPerm = request.dmSec.oAuthorisation.checkInheritedPermission(permissionName=aPermissions[x],objectid=stObj.objectid);
									if(bHasPerm EQ 1)
										break;
								}
							</cfscript>
							
								<!--- set up tab --->
								<cfif bHasPerm EQ 1>
									<admin:tabitem class="subtab" href="navajo/overview_frame.cfm?rootobjectid=#stobj.objectid#" target="treeFrame" text="#stobj.title#" onclick="synchTab('treeFrame','activesubtab','subtab','#stobj.objectid#')" id="#stobj.objectid#">
								</cfif>
							</cfloop>
						</cfdefaultcase>
						
						<!--- Show tabs for the dynamic view --->
						<cfcase value="dynamic">
							<!--- permission checks --->
							<cfscript>
								iContentCategorisationTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ContentCategorisationTab");
								iContentExportTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ContentExportTab");
							</cfscript>
														
							<cfif iContentTab eq 1>	
								<admin:tabitem class="activesubtab" href="dynamic/dynamicMenuFrame.cfm?type=general" target="treeFrame" text="Types" onclick="synchTab('treeFrame','activesubtab','subtab','DynamicTab')" id="DynamicTab">
							</cfif>
							<cfif iContentExportTab eq 1>
								<admin:tabitem class="subtab" href="dynamic/dynamicMenuFrame.cfm?type=export" target="treeFrame" text="Export" onclick="synchTab('treeFrame','activesubtab','subtab','ExportTab')" id="ExportTab">
							</cfif>
							<cfif iContentCategorisationTab eq 1>
								<admin:tabitem class="subtab" href="dynamic/dynamicMenuFrame.cfm?type=categorisation" target="treeFrame" text="Categorisation" onclick="synchTab('treeFrame','activesubtab','subtab','DynamicCategorisationTab')" id="DynamicCategorisationTab">
							</cfif>
							<admin:tabitem class="subtab" style="display:none" href="navajo/overview_frame.cfm?rootobjectid=#application.navid.fileroot#&insertonly=1" target="treeFrame" text="Files" onclick="synchTab('treeFrame','activesubtab','subtab','DynamicFileTab')" id="DynamicFileTab">
							<admin:tabitem class="subtab" style="display:none" href="navajo/overview_frame.cfm?rootobjectid=#application.navid.imageroot#&insertonly=1" target="treeFrame" text="Images" onclick="synchTab('treeFrame','activesubtab','subtab','DynamicImageTab')" id="DynamicImageTab">
						</cfcase>
						
						<!--- Show tabs for the admin view --->
						<cfcase value="admin">
							<!--- permission checks --->
							<cfscript>
								iAdminGeneralTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
								iAdminCOAPITab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
								iAdminSearchTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
							</cfscript>
							
							<cfif iAdminGeneralTab eq 1>
								<admin:tabitem class="activesubtab" href="admin/adminMenuFrame.cfm?type=General" target="treeFrame" text="General" onclick="synchTab('treeFrame','activesubtab','subtab','AdminGeneralTab')" id="AdminGeneralTab">
							</cfif>
							<cfif iAdminSearchTab eq 1>
								<admin:tabitem class="subtab" href="admin/adminMenuFrame.cfm?type=Search" target="treeFrame" text="Search" onclick="synchTab('treeFrame','activesubtab','subtab','AdminSearchTab')" id="AdminSearchTab">
							</cfif>
							<cfif iAdminCOAPITab eq 1>
								<admin:tabitem class="subtab" href="admin/adminMenuFrame.cfm?type=COAPI" target="treeFrame" text="COAPI" onclick="synchTab('treeFrame','activesubtab','subtab','AdminCOAPITab')" id="AdminCOAPITab">
							</cfif>
						</cfcase>
						
						<!--- Custom admin view --->
						<cfcase value="customAdmin">
							<cfparam name="URL.subtabindex" default="1">
							<!--- get the tab elements from the XML Schema --->
							<cfset tabElements = parentTabElements[URL.parentTabIndex].xmlchildren>
							
							<!--- setup for a RHS default custom page --->
							<cfif isDefined("url.defaultPage")>
								<cfscript>
								defaultCustomPage = URLDecode(url.defaultpage);
								host = application.config.general.adminServer;
								if(findnocase(".cfm?",defaultCustomPage))
									append = "&";
								else
									append = "?";
								//Bit of a huge assumption that URL.defaultpage is only present from status change on custom types - but will do for now. PH 
								defaultCustomPage = defaultCustomPage & append & "approveURL=#URLEncodedFormat(host & application.url.farcry & "/index.cfm?" & CGI.query_string)#";								
								</cfscript>
							<cfelse>	
								<cfset defaultCustomPage = "admin/adminHome.cfm">
							</cfif>
							
							<!--- check to see if one has been defined for the tab --->
							<cfif structKeyExists(parentTabElements[URL.parentTabIndex].xmlattributes,"defaultpage")>
								<!--- use the tabs defined default --->
					 			<cfset defaultCustomPage = parentTabElements[URL.parentTabIndex].xmlattributes.defaultpage>
					 		</cfif>
							
						
							<cfloop from="1" to="#ArrayLen(tabElements)#" index="i">
								<cfif structKeyExists(tabElements[i].xmlattributes,"permission")>
									<cfscript>
										iCustomTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="#tabElements[i].xmlattributes.permission#");
										if (structKeyExists(tabElements[i].xmlattributes,"href")) //perhaps user wants to render a URL in the tree frame
											customhref = tabElements[i].xmlattributes.href;
										else	
											customhref = 'admin/customadminMenuframe.cfm?subtabindex=#i#&parenttabindex=#URL.PARENTTABINDEX#';
									</cfscript>
									<cfif iCustomTab eq 1>
										<admin:tabitem class="#IIF(i EQ URL.subtabindex ,DE('activesubtab'),DE('subtab'))#" href="#customhref#" target="treeFrame" text="#tabElements[i].xmltext#" onclick="synchTab('treeFrame','activesubtab','subtab','AdminGeneralTab#i#')" id="AdminGeneralTab#i#">
									</cfif>	
								</cfif>
							</cfloop>
							
						</cfcase>
						
						
						<!--- Show tabs for the security view --->
						<cfcase value="security">
							<!--- permission checks --->						
							<cfscript>
								iSecurityPolicyManagementTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab");
								iSecurityUserManagementTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityUserManagementTab");
							</cfscript>

							<cfif iSecurityUserManagementTab eq 1>
								<admin:tabitem class="activesubtab" href="security/securityMenuFrame.cfm?type=security" target="treeFrame" text="Security" onclick="synchTab('treeFrame','activesubtab','subtab','securityTab')" id="securityTab">
							</cfif>
							<cfif iSecurityPolicyManagementTab eq 1>
								<admin:tabitem class="subtab" href="security/securityMenuFrame.cfm?type=policy" target="treeFrame" text="Policy" onclick="synchTab('treeFrame','activesubtab','subtab','policyTab')" id="policyTab">
							</cfif>
						</cfcase>
						
						<!--- Show tabs for the reporting view --->
						<cfcase value="reporting">
							<!--- permission checks --->						
							<cfscript>
								iReportingStatsTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
								iReportingAuditTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
							</cfscript>

							<cfif iReportingStatsTab eq 1>
								<admin:tabitem class="activesubtab" href="reporting/reportingMenuFrame.cfm?type=stats" target="treeFrame" text="Statistics" onclick="synchTab('treeFrame','activesubtab','subtab','statsTab')" id="statsTab">
							</cfif>
							<cfif iReportingAuditTab eq 1>
								<admin:tabitem class="subtab" href="reporting/reportingMenuFrame.cfm?type=audit" target="treeFrame" text="Audit" onclick="synchTab('treeFrame','activesubtab','subtab','auditTab')" id="auditTab">
							</cfif>
						</cfcase>
						
						<!--- Show tabs for the help view --->
						<cfcase value="help">
							<cfif iHelpTab eq 1> --->
								<admin:tabitem class="activesubtab" href="help/helpMenuFrame.cfm?type=general" target="treeFrame" text="Help" onclick="synchTab('treeFrame','activesubtab','subtab','statsTab')" id="helpTab">
							</cfif>
							
						</cfcase>
					</cfswitch>
				</admin:tabs>
			<cfoutput></div>
			<div class="tabMain">
				<div class="tabTitle" id="title"></cfoutput>		
					<!--- display section title --->
					<cfif url.section eq "customadmin">
						
						<cfoutput>#application.customAdminXML.customtabs.parenttab[url.parenttabindex].xmltext#&nbsp</cfoutput>
					<cfelse>
						<cfoutput>#url.section#&nbsp;</cfoutput>
					</cfif>
					
					<cfif url.section eq "Site">
						<!--- display quick links in dropdown for tree --->
						<cfset aNavalias = listToArray(listSort(structKeyList(application.navid),'textnocase'))>
						<cfoutput>
						<form name="zoom" style="display:inline;">
							<select name="QuickZoom" onChange="reloadTreeFrame()" class="field">
								<option value="0">-- Quick Zoom --</option>
						</cfoutput>
								<!--- check user has permission to see root node --->
								<cfscript>
									iTreeRootNode = oAuthorisation.checkPermission(reference="policyGroup",permissionName="TreeRootNode");
								</cfscript>
							<cfif iTreeRootNode eq 1>
								<cfoutput><option value="navajo/overview_frame.cfm">Root</option></cfoutput>
							</cfif>	
							
							<!--- loop over navid structure in memory -- populated on application init --->
							
							<cfloop from="1" to="#arraylen(aNavalias)#" index="i">
							<cfset key=aNavalias[i]>
							<!--- do not show root nav alias as already set above after permission check --->
							<cfif key neq "root">
								<cfscript>
								if(isdefined("application.navid.hidden") and application.navid[key] IS application.navid.hidden)
									lPermissions = 'Edit,Create,Delete,Approve';
								else	
									lPermissions = 'View,Edit,Create,Delete,Approve';
								aPermissions = listToArray(lPermissions);
								bHasPerm = 0;
								for (x=1;x LTE arrayLen(aPermissions);x=x+1)
								{	
									writeoutput(application.navid[key]);
									bHasPerm = request.dmSec.oAuthorisation.checkInheritedPermission(permissionName=aPermissions[x],objectid=listGetAt(application.navid[key],1));
									if(bHasPerm EQ 1)
										break;
								}
								if (bHasPerm EQ 1)
									writeoutput("<option value=""navajo/overview_frame.cfm?rootobjectid=#application.navid[key]#"">#key#</option>");
								</cfscript>
							</cfif>
							
							</cfloop>
							
							<cfoutput>
							</select>
						</form>
						</cfoutput>
						<!--- If admin permission show uuid search bar --->
						<cfoutput>
						<cfif iAdminTab eq 1>
							<span style="position: absolute; top:5px; right:55px;"><form name="searchTree" method="post"><input type="text" name="searchUUID" value="UUID" style="display:inline;width:40px;" onFocus="document.searchTree.searchUUID.value=''"> <input type="submit" value="Find" onClick="window.frames.treeFrame.location.href = 'navajo/overview_frame.cfm?rootobjectid=' + document.searchTree.searchUUID.value; return false;"></form></span>
						</cfif>
						<span style="position: absolute; top:8px; right:30px;"><a href="javascript:void(0);" onClick="javascript:window.open('legend.cfm','','width=350,height=500,scrollbars=yes,left=200,top=5');"><img src="images/legend.jpg" alt="Legend" border="0"></a></span>
						<span style="position: absolute; top:8px; right:5px;"><a href="javascript:window.frames.treeFrame.location.reload();"><img src="images/refresh.gif" alt="Refresh Tree" border="0"></a></span>
						</cfoutput>
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
								<cfoutput>
								<script>
								synchTab('treeFrame','activesubtab','subtab','#application.navid.home#')
								</script>
								</cfoutput>
							</cfif>
						</cfcase>
						<cfcase value="dynamic">
							<cfset defaultPage="dynamic/dynamicMenuFrame.cfm">
						</cfcase>
						<cfcase value="admin">
							<cfset defaultPage="admin/adminMenuFrame.cfm">
						</cfcase>
						<cfcase value="customadmin">
							<cfscript>
							if (structKeyExists(tabElements[url.subtabindex].xmlattributes,"href")) //perhaps user wants to render a URL in the tree frame
								defaultPage = tabElements[url.subtabindex].xmlattributes.href;
							else	
								defaultPage="admin/customadminMenuFrame.cfm?parenttabindex=#url.parenttabindex#";
							</cfscript>
						</cfcase>
						<cfcase value="security">
							<cfset defaultPage="security/securityMenuFrame.cfm">
						</cfcase>
						<cfcase value="reporting">
							<cfset defaultPage="reporting/reportingMenuFrame.cfm">
						</cfcase>
						<cfcase value="help">
							<cfset defaultPage="help/helpMenuFrame.cfm">
						</cfcase>
					</cfswitch>
					<!-- display left hand content -->
					<cfoutput><iframe class="tabContent" name="treeFrame" src="#defaultPage#" frameborder="0" onLoad="startTimer()"></iframe>
				</div>
			</div>
		</div></cfoutput>
		
		<!--- ### Resizer ### --->
		<cfoutput>
		<div id="resizer" onmouseover="if (!ns6){this.style.cursor='move';this.style.background='##FF6600';}" onmouseup="resizerup();" onmousemove="resizermove();" onmousedown="if(!ns6)resizerdown();" onmouseout="if(!ns6)this.style.background='##999';"></div>
		</cfoutput>
		
		<!--- ### Column 2 ### --->
		<cfoutput><div id="column2" class="tabBox" style="right:0px;" align="left">
		  <div class="subTabArea"></cfoutput>
		   <admin:tabs>
				<!--- work out which tabs to display in right hand column --->
				<cfswitch expression="#url.section#">
					<cfcase value="site">
						<cfscript>
							iObjectEditTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectEditTab");
							iObjectOverviewTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectOverviewTab");
							iObjectStatsTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectStatsTab");
							iObjectDumpTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectDumpTab");
							iObjectAuditTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectAuditTab");
							iObjectArchiveTab = oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectArchiveTab");
						</cfscript>
												
						<cfif iObjectOverviewTab eq 1>
							<admin:tabitem class="activesubtab" href="edittabOverview.cfm?objectid=" target="editFrame" text="Overview" title="Overview" id="siteEditOverview" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditOverview');synchTitle('Overview')">
						</cfif>
						<cfif iObjectEditTab eq 1>
							<admin:tabitem class="subtab" href="edittabEdit.cfm?objectid=" target="editFrame" text="Edit" title="Edit this item" id="siteEditEdit" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">	
						</cfif>	
						<cfif iObjectArchiveTab eq 1>
							<admin:tabitem class="subtab" href="edittabArchive.cfm?objectid=" target="editFrame" text="Archive" title="View archive" id="siteEditArchive" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditArchive');synchTitle('Archive')">
						</cfif>
						<cfif iObjectAuditTab eq 1>
							<admin:tabitem class="subtab" href="edittabAudit.cfm?objectid=" target="editFrame" text="Audit" title="View audit information" id="siteEditAudit" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditAudit');synchTitle('Audit')">
						</cfif>
						<cfif iObjectStatsTab eq 1>
							<admin:tabitem class="subtab" href="edittabStats.cfm?objectid=" target="editFrame" text="Stats" title="Statistics" id="siteEditStats" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditStats');synchTitle('Stats')">
						</cfif>
						<admin:tabitem class="subtab" href="edittabRules.cfm?objectid=" target="editFrame" text="Publishing Rules" title="Publishing Rules" id="siteEditRules" style="display: none" onclick="synchTab('editFrame','activesubtab','subtab','siteEditRules');synchTitle('Publishing Rules')">
						<cfif iObjectDumpTab eq 1>
							<admin:tabitem class="subtab" href="edittabDump.cfm?objectid=" target="editFrame" text="Dump" title="Dump object properties" id="siteEditDump" style="visibility: hidden" onclick="synchTab('editFrame','activesubtab','subtab','siteEditDump');synchTitle('Dump')">
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<admin:tabitem class="activesubtab" href="##top" target="_self" text="Default">
					</cfdefaultcase>
				</cfswitch>
			</admin:tabs>
		  <cfoutput></div>
		  <div class="tabMain">
			<div class="tabTitle" id="EditFrameTitle">
				<script>
					function toggleColumn(id){
						var column1 = document.getElementById('column1');
						var column2 = document.getElementById('column2');
						var resizer = document.getElementById('resizer');
						var contract = document.getElementById('contract');
						var expand = document.getElementById('expand');
						if (id == 'contract')
						{
							column1.style.visibility='hidden';
							resizer.style.visibility='hidden';
							contract.style.display='none';
							expand.style.display='inline';
							column2.style.width='100%';
						}else if (id == 'expand'){
							column1.style.visibility='visible';
							resizer.style.visibility='visible';
							expand.style.display='none';
							contract.style.display='inline';
							if (ns6)
								column2.style.width='73%';	
							else	
								column2.style.width='69.7%';
						}
					}		
							
						
				</script>
				<a href="##" id="contract" onclick="toggleColumn(this.id);"><img src="images/contract.gif" alt="Expand to full width" border="0" /></a><a href="##"  id="expand" style="display='none';" onclick="toggleColumn(this.id);"><img src="images/expand.gif" alt="Restore layout" border="0" /></a>
		
				<div id="DisplayTitle"></div>
			</div>
			<div class="tabIframeWrapper"></cfoutput>
				<!--- set default load page for the different sections --->
				<cfswitch expression="#url.section#">
					<cfcase value="site">
						<cfset defaultPageRight="legend.cfm">
					</cfcase>
					<cfcase value="dynamic">
						<cfif isdefined("url.objectid")>
							<cfscript>
								typename = q4.findtype(url.objectid);
							</cfscript>
							<cfset defaultPageRight="navajo/GenericAdmin.cfm?type=News&typename=#typename#&status=#url.status#&objectid=#URL.objectid#">
						<cfelse>
							<cfset defaultPageRight="navajo/GenericAdmin.cfm?type=News&typename=dmNews">
						</cfif>
					</cfcase>
					<cfcase value="admin">
						<cfset defaultPageRight="admin/adminHome.cfm">
					</cfcase>
					<cfcase value="customadmin">
						<cfif isdefined("url.objectid")>
							<cfset defaultPageRight="#defaultCustomPage#&objectid=#URL.objectid#">
						<cfelse>
							<cfset defaultPageRight="#defaultCustomPage#">
						</cfif>
					</cfcase>
					<cfcase value="security">
						<cfset defaultPageRight="security/securityHome.cfm">
					</cfcase>
					<cfcase value="reporting">
						<cfset defaultPageRight="reporting/reportingHome.cfm">
					</cfcase>
					<cfcase value="help">
						<cfset defaultPageRight="help/helpHome.cfm">
					</cfcase>
				</cfswitch>
				<cfoutput><iframe class="tabContent" name="editFrame" src="#defaultPageRight#" frameborder="0" onLoad="startTimer()"></iframe>
			</div>
		  </div>
		</div>
	</div></cfoutput>
	</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="No">