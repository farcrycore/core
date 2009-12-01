
<cfsetting enablecfoutputonly="true" />


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />


<!--- CONTENT ITEM STATUS --->
<cfif structKeyExists(stobj,"status")>
	
	
	<cfswitch expression="#stobj.status#">
	<cfcase value="draft">
		
			<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFFF;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
				<cfoutput>
					DRAFT: last updated <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
					<skin:toolTip id="webtop-overview-lastupdated">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
					
					<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
						(<skin:buildLink objectid="#stobj.versionID#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show approved" urlParameters="showdraft=0" />)
					</cfif>
				</cfoutput>
			</grid:div>
		
	</cfcase>
	<cfcase value="pending">
		
			<grid:div class="webtopOverviewStatusBox" style="background-color:##FFE0C0;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
				<cfoutput>
					PENDING: awaiting approval since <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
					<skin:toolTip id="webtop-overview-lastupdated">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
					
					<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
						(<skin:buildLink objectid="#stobj.versionID#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show approved" urlParameters="showdraft=0" />)
					</cfif>
				</cfoutput>
			</grid:div>
	</cfcase>
	<cfcase value="approved">
		
			<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFC0;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
				<cfoutput>
					APPROVED: <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
					<skin:toolTip id="webtop-overview-lastupdated"
						configuration="position:'bottom center',relative:true" style="width:300px;">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
					
					<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
						<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
						<cfif qDraft.recordcount>
							(<skin:buildLink objectid="#qDraft.objectid#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show draft" urlParameters="showdraft=1" />)
						</cfif>
					</cfif>	
				</cfoutput>
			</grid:div>
	</cfcase>
	</cfswitch>

</cfif>	
			
			

<cfsetting enablecfoutputonly="false" />