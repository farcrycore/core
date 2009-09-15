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

			<grid:div style="float:right;padding:10px;">
				<admin:icon icon="#application.stCOAPI[stobj.typename].icon#" usecustom="true" />
			</grid:div>

		<grid:div id="webtopOverviewActions" style="float:left;margin-right: 0px;width:190px;">
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewActionsPrimary" />
		</grid:div>
		<grid:div style="margin-left:200px;margin-right: 70px;">
			
			
			<!--- WORKFLOW --->
			<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
			<cfoutput>#workflowHTML#</cfoutput>
			
			<cfoutput><h1>#uCase(application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename))#: #stobj.label#</h1></cfoutput>

			<cfif application.fapi.getContentTypeMetadata(stobj.typename, "bUseInTree", false)>		
				<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">
				
				<cfif len(parentID)>
					<cfif stobj.typename EQ "dmNavigation">
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=false) />
					<cfelse>
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=true) />
					</cfif>
					
					<cfif qAncestors.recordCount>
						<cfloop query="qAncestors">
							<skin:buildLink href="#application.url.webtop#/editTabOverview.cfm" urlParameters="objectID=#qAncestors.objectid#" linktext="#qAncestors.objectName#" />
							<cfoutput>&nbsp;&raquo;&nbsp;</cfoutput>
						</cfloop>
						<cfoutput>#stobj.label#</cfoutput>
					</cfif>
				</cfif>
			</cfif>	
			<!--- CONTENT ITEM STATUS --->
			<cfif structKeyExists(stobj,"status")>
				
				
				<cfswitch expression="#stobj.status#">
				<cfcase value="draft">
					
						<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFFF;">
							<cfoutput>
								DRAFT: Content Item last updated 4 hours ago.
								
								<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
									(<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved" />)
								</cfif>
							</cfoutput>
						</grid:div>
					
				</cfcase>
				<cfcase value="pending">
					
						<grid:div class="webtopOverviewStatusBox" style="background-color:##FFE0C0;">
							<cfoutput>
								PENDING: Content Item awaiting approval for 4 days.
								
								<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
									(<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved" />)
								</cfif>
							</cfoutput>
						</grid:div>
				</cfcase>
				<cfcase value="approved">
					
						<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFC0;">
							<cfoutput>
								PUBLISHED: Content Item approved 23-jul-2009.
								
								<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
									<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
									<cfif qDraft.recordcount>
										(<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#qDraft.objectid#" linktext="show draft" />)
									</cfif>
								</cfif>	
							</cfoutput>
						</grid:div>
				</cfcase>
				</cfswitch>
			
			</cfif>
			
			<grid:div class="webtopSummarySection">
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
			</grid:div>
			
			<!--- FRIENDLY URL --->
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<grid:div class="webtopSummarySection">
					<cfoutput>
					<h2>FRIENDLY URL</h2>
					#application.fapi.fixURL(application.fc.factory.farFU.getFU(objectid="#stobj.objectid#", type="#stobj.typename#"))#
					|
					<a onclick="$fc.openDialogIFrame('Manage Friendly URL\'s for #stobj.label# (#stobj.typename#)', '#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stobj.objectid#')">
						Manage
					</a>
					</cfoutput>
				</grid:div>
			</cfif>
			
			
			
			<!--- CATEGORISATION --->
			<cfset lCatProps = "" />
			<cfset lCats = "" />
			
			<cfloop list="#structKeyList(application.stcoapi[stobj.typename].stProps)#" index="iProp">
				<cfif application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftType", "") EQ "category">
					<cfset lCatProps = listAppend(lCatProps, iProp) />
				</cfif>
			</cfloop>
			
			<cfif listLen(lCatProps)>
				<grid:div class="webtopSummarySection">
					<cfoutput>
					<h2>CATEGORISATION</h2>
					<cfloop list="#lCatProps#" index="iProp">
						<div>
							<strong>#application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftLabel", iProp)#:</strong>
							<cfif listLen(stobj[iProp])>
								<cfloop list="#stobj[iProp]#" index="catid">		
									<cfset lCats = listAppend(lCats,application.factory.oCategory.getCategoryNameByID(catid)) />
								</cfloop>
							</cfif>
							#lCats#
						</div>
					</cfloop>
					</cfoutput>
				</grid:div>
			</cfif>
			
			<!--- COMMENTS --->
			<grid:div class="webtopSummarySection">
				<cfoutput><h2>COMMENTS</h2></cfoutput>
				
				<cfset events = structnew() />
				<cfset events.comment = "Comment" />
				<cfset events.toapproved = "Approved" />
				<cfset events.topending = "Requested approval" />
				<cfset events.todraft = "Sent to draft" />
			
				<cfset qComments = application.fapi.getContentType("farLog").filterLog(objectid=stobj.objectid,event='comment,topending,toapproved,todraft') />
				
				<cfif qComments.recordcount>
					<cfoutput>
						<cfloop query="qComments" startrow="1" endrow="1">
							<cfset stProfile = application.fapi.getContentType("dmProfile").getProfile(username=qComments.userid) />
							
							<div>
								#dateformat(qComments.datetimecreated,"yyyy-mm-dd")# #timeformat(qComments.datetimecreated,"hh:mm tt")# - #events[qComments.event]#
					
								<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
									(#stProfile.firstname# #stProfile.lastname#)
								<cfelse>
									(#listfirst(qComments.userid,'_')#)
								</cfif>
							</div>
							
							<cfif len(qComments.notes)>
								<div>#qComments.notes#</div>
							</cfif>
						</cfloop>
					
						
					</cfoutput>
				</cfif>
				
				
				<cfoutput>
					<div>
						<a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#')">Add Comment</a>
						<cfif qComments.recordcount>
							|
							<a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#')">All Comments (#qComments.recordcount#)</a>
						</cfif>
					</div>
				</cfoutput>
			</grid:div>
			
			<grid:div class="webtopSummarySection">
				<cfoutput>
				<h2>SYSTEM INFORMATION</h2>
				CREATED: #application.thisCalendar.i18nDateTimeFormat(stobj.datetimecreated,session.dmProfile.locale,application.mediumF)#<br />
				
				LAST UPDATED: #application.thisCalendar.i18nDateTimeFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#
				(
					<a onclick="$fc.openDialog('Audit', '#application.url.farcry#/edittabAudit.cfm?objectid=#stobj.objectid#')">Audit Trail</a>
					|
					<a onclick="$fc.openDialog('Archive', '#application.url.farcry#/archive.cfm?objectid=#stobj.objectid#')">Rollback</a>
				)
				<br />
				
				OBJECTID: #stobj.objectid#
				<br />
				
				<a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#')">Show All Properties</a>

				</cfoutput>
			</grid:div>
			
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

