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
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Tabs for each status of the object for the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">

<!------------------ 
START WEBSKIN
 ------------------>



<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />


<ft:form>


		<grid:div style="float:left;margin-right: 0px;width:200px;">
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewActionsPrimary" />
		</grid:div>
		<grid:div style="float:left;margin-right: 0px;width:200px;">
			
			
			<!--- WORKFLOW --->
			<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
			<cfoutput>#workflowHTML#</cfoutput>
			
			
			<!--- CONTENT ITEM STATUS --->
			<cfif structKeyExists(stobj,"status")>
				<!--- grab draft object overview --->
				<cfset stDraftObject = StructNew()>
				
				<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
					<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
					<cfif qDraft.recordcount>
						<cfset stDraftObject = application.fapi.getContentObject(typename="#stobj.typename#", objectid="#qDraft.objectid#")>
					</cfif>
				</cfif>
				
				
				<cfswitch expression="#stobj.status#">
				<cfcase value="draft">
					
						<grid:div style="border:1px solid black;background-color:##C0FFFF;">
							<cfoutput>
								DRAFT: Content Item last updated 4 hours ago.
								
								<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
									(<skin:buildLink	type="#stobj.typename#" 
														objectid="#stobj.versionID#" 
														view="renderWebtopOverview"
														linktext="show approveder" />)
								</cfif>
							</cfoutput>
						</grid:div>
					
				</cfcase>
				<cfcase value="pending">
					
						<grid:div style="border:1px solid black;background-color:##FFE0C0;">
							<cfoutput>
								PENDING: Content Item awaiting approval for 4 days.
								
								<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
									(<skin:buildLink	type="#stobj.typename#" 
														objectid="#stobj.versionID#" 
														view="renderWebtopOverview"
														linktext="show approved" />)
								</cfif>
							</cfoutput>
						</grid:div>
				</cfcase>
				<cfcase value="approved">
					
						<grid:div style="border:1px solid black;background-color:##C0FFC0;">
							<cfoutput>
								PUBLISHED: Content Item approved 23-jul-2009.
								
								<cfif not structIsEmpty(stDraftObject)>
									(<skin:buildLink	type="#stDraftObject.typename#" 
														objectid="#stDraftObject.objectid#" 
														view="renderWebtopOverview"
														linktext="show draft" />)
								</cfif>
							</cfoutput>
						</grid:div>
				</cfcase>
				</cfswitch>
			
			</cfif>
					
			<cfoutput>
			<dl class="dl-style1" style="padding: 10px;font-size:11px;">
				<dt>Label</dt>
				<dd>#stobj.label#</dd>
				
				<cfif structKeyExists(stobj, "displayMethod")>
					<dt>Display Method</dt>
					<dd>#stobj.displayMethod#</dd>
				</cfif>
				<cfif structKeyExists(stobj, "teaser")>
					<dt>Teaser</dt>
					<dd>#stobj.teaser#</dd>
				</cfif>
				<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
					<dt>Friendly URL <a onclick="$fc.openDialogIFrame('Manage Friendly URL\'s for #stobj.label# (#stobj.typename#)', '#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-pencil" style="float:right;">&nbsp;</span></a></dt>
					<dd>#application.fapi.fixURL(application.fc.factory.farFU.getFU(objectid="#stobj.objectid#", type="#stobj.typename#"))#</dd>
				</cfif>
			</dl>
			
			
			
			<ul style="float:left;">
				<cfif application.security.checkPermission("ModifyPermissions") and listcontains(application.fapi.getPropertyMetadata(typename="farBarnacle", property="referenceid", md="ftJoin", default=""), stObj.typename)>
					<!--- <ft:button width="240px" style="" type="button" value="Manage Permissions" rbkey="workflow.buttons.managepermissions" onclick="window.location='#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions&ref=#url.ref#';" /> --->
					<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialogIFrame('Permissions', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Permissions</a></li>
				</cfif>	
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Statistics', '#application.url.farcry#/edittabStats.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Statistics</a></li>
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Audit', '#application.url.farcry#/edittabAudit.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Audit</a></li>
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Archive', '#application.url.farcry#/archive.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Archive</a></li>
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Comments</a></li>
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>System Properties</a></li>
			</ul>
			
			</cfoutput>
			
		</grid:div>
		
			
		<cfoutput><br style="clear:both;" /></cfoutput>

</ft:form>
<!--- 
	<extjs:layout id="webtopOverviewViewport" container="Viewport" layout="border">
		<extjs:item region="center" container="TabPanel" activeTab="0">
			
			<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />
			
			<cfif StructKeyExists(stobj,"status")>
			
				<cfif len(stobj.status)>
					<cfset mainTabStatus = stobj.status />
				<cfelse>
					<cfset mainTabStatus = "NO STATUS" />
				</cfif>
				
				
				
						

						
				<cfif stobj.status NEQ "" AND NOT structIsEmpty(stDraftObject)>
					<extjs:item title="#application.rb.getResource('workflow.constants.#stDraftObject.status#@label',stDraftObject.status)#" container="Panel" layout="border">

 						<extjs:item region="center" container="Panel" layout="border">			
							<extjs:item region="center" autoScroll="true">
				
								<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stDraftObject.objectid#", referenceTypename="#stDraftObject.typename#") />
								<cfoutput>#workflowHTML#</cfoutput>
								<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewSummary" />
							</extjs:item>
						</extjs:item>	
						<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
							<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewActions" />
						</extjs:item>
							

						
					</extjs:item>
				</cfif>	
			<cfelse>
				<cfset mainTabStatus = "Approved/Live" />
			</cfif>
			

	
							
			<extjs:item title="#application.rb.getResource('workflow.constants.#mainTabStatus#@label',mainTabStatus)#" container="Panel" layout="border">
				<extjs:item region="center" container="Panel" layout="border">			
					<extjs:item region="center" autoScroll="true">
						<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
						<cfoutput>#workflowHTML#</cfoutput>
						<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
					</extjs:item>
				</extjs:item>			
				<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
					<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewActions" />
				</extjs:item>	
				
				
			</extjs:item>
		</extjs:item>		
	</extjs:layout>
 --->
<!--- </cfif> --->


<cfsetting enablecfoutputonly="false">

