<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">


<!--- ENVIRONMENT VARIABLES --->
<cfset stLocal.qTabs = getWebskins(typename=stObj.typename,prefix="webtopOverviewTab") />
<cfset stLocal.stTabs = structnew() />


		
			
			
<!--- WORKFLOW --->
<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
<cfoutput>#workflowHTML#</cfoutput>

<skin:htmlHead>
<cfoutput>
<style type="text/css">
	.draft {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.pending {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.approved {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	
	.draft a,
	.pending a,
	.approved a {
		background:transparent;
		text-shadow: none;
		color:inherit;
	}
	
	.draft a:hover,
	.pending a:hover,
	.approved a:hover {
		color:inherit;
	}
</style>
</cfoutput>
</skin:htmlHead>

<cfoutput>

	<!--- CONTENT ITEM STATUS --->
	<cfif structKeyExists(stobj,"status")>			
		
		<cfswitch expression="#stobj.status#">
		<cfcase value="draft">
			
			<cfoutput>
				<div class="draft alert alert-error pull-right">
					<div>DRAFT</div>
					<div style="font-size:11px;">last updated <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
					
					<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
						<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#stobj.versionID#" linktext="show approved version" /></div>
					</cfif>
				</div>
			</cfoutput>
			
		</cfcase>
		<cfcase value="pending">
			<cfoutput>
			<div class="pending alert alert-warning pull-right">
				<div>PENDING</div>
				<div style="font-size:11px;">awaiting approval since <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
				
				<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
					<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#stobj.versionID#" linktext="show approved version" /></div>
				</cfif>
			</div>
			</cfoutput>
		</cfcase>
		<cfcase value="approved">
			<cfoutput>
			<div class="approved alert alert-success pull-right">
				<div>APPROVED</div> 
				<div style="font-size:11px;">last approved <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
				
				<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
					<cfset qDraft = application.factory.oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
					<cfif qDraft.recordcount>
						<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#qDraft.objectid#" linktext="show #qDraft.status# version" /></div>
					</cfif>
				</cfif>
				</div>
			</cfoutput>
		</cfcase>
		</cfswitch>
	
	</cfif>	

	<h1>
		<cfif len(application.stCOAPI[stobj.typename].icon)>
			<i class="fa #application.stCOAPI[stobj.typename].icon#"></i>
		<cfelse>
			<i class="fa fa-file"></i>
		</cfif>
		#stobj.label#
	</h1>

</cfoutput>

			
			
		<cfset tabID = "directory#replace(stObj.objectid,'-','','ALL')#" />
		<admin:tabs id="#tabID#">
			<cfoutput>  
			<admin:tabItem id="tabs-summary" title="General">
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
			</admin:tabItem>      
			
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<admin:tabItem id="SEO">
					<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSEO" />
				</admin:tabItem>     
			</cfif>	
		
			<cfloop query="stLocal.qTabs">
				<cfif stLocal.qTabs.methodname neq "webtopOverviewTab" and isdefined("application.stCOAPI.#stObj.typename#.stWebskins.#stLocal.qTabs.methodname#.displayname")>
					<admin:tabItem id="#tabID#-custom-#stLocal.qTabs.currentRow#" 
									title="#application.stCOAPI[stObj.typename].stWebskins[stLocal.qTabs.methodname].displayname#">
								
							<skin:view typename="#stobj.typename#" objectid="#stObj.objectid#" webskin="#stLocal.qTabs.methodname#">
					
					</admin:tabItem>
				</cfif>
			</cfloop>
			 </cfoutput>
		</admin:tabs>
	
<cfsetting enablecfoutputonly="false">
		