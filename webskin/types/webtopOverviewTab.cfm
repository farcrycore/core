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
<!--- @@displayname: Render Webtop Overview Tab --->
<!--- @@description: Renders the Tabs for main information of the overview  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">


<!--- ENVIRONMENT VARIABLES --->




<!--- WORKFLOW --->
<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
<cfoutput>#workflowHTML#</cfoutput>



<cfoutput>
<table class="layout" style="width:100%;padding:5px;">
<tr>
	<td style="width:50px;"><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" size="48" default="farcrycore" alt="#uCase(application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename))#" /></td>
	<td style="width:50%;"><h1>#stobj.label#</h1></td>
	<td>

		<!--- CONTENT ITEM STATUS --->
		<cfif structKeyExists(stobj,"status")>
			
			
			<cfswitch expression="#stobj.status#">
			<cfcase value="draft">
				
					<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFFF;">
						<cfoutput>
							DRAFT: last updated <a title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
							
							<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
								(<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved" />)
							</cfif>
						</cfoutput>
					</grid:div>
				
			</cfcase>
			<cfcase value="pending">
				
					<grid:div class="webtopOverviewStatusBox" style="background-color:##FFE0C0;">
						<cfoutput>
							PENDING: awaiting approval since <a title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
							
							<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
								(<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved" />)
							</cfif>
						</cfoutput>
					</grid:div>
			</cfcase>
			<cfcase value="approved">
				
					<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFC0;">
						<cfoutput>
							APPROVED: <a title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
							
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
	</td>
</tr>
</table>
</cfoutput>


		
		
		<cfset tabID = "directory#replace(stObj.objectid,'-','','ALL')#" />
		<grid:div id="#tabID#">
			<cfoutput>        	
			<ul>
				<li style="background-image:none;padding:0px;"><a href="##tabs-summary">General</a></li>
				<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
					<li style="background-image:none;padding:0px;"><a href="##tabs-seo">SEO</a></li>
				</cfif>
				<li style="background-image:none;padding:0px;"><a href="##tabs-misc">Miscellaneous</a></li>
			</ul>
            </cfoutput>
			
			<skin:onReady>
				<cfoutput>$j("###tabID#").tabs();</cfoutput>
			</skin:onReady>
			
			<grid:div id="tabs-summary">	
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
			</grid:div>
			
			
			<!--- FRIENDLY URL --->
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<grid:div id="tabs-seo">
					<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSEO" />
				</grid:div>
			</cfif>
			
			
		
			
			<grid:div id="tabs-misc">
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewMisc" />
			</grid:div>
			
		</grid:div>
		
	
<cfsetting enablecfoutputonly="false">
		