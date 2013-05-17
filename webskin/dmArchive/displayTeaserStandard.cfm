<cfsetting enablecfoutputonly="true" />
<!--- @@viewbinding: any --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<cfparam name="arguments.stParam.mode" default="select" /><!--- @@options: select, display --->

<cfif structkeyexists(arguments.stParam,"liveObject")>
	
	<cfset stObject = arguments.stParam.liveObject />
	
	<!--- Discard draft permission --->
	<cfif arguments.stParam.mode eq "display">
		<sec:CheckPermission permission="Delete" type="#stObject.typename#" objectid="#stObject.objectid#" result="stLocal.deletePermission" />
	</cfif>
	
	<!--- Event --->
	<cfif structkeyexists(stObject,"status")>
		<cfswitch expression="#stObject.status#">
			<cfcase value="approved">
				<cfset stLocal.event = "Approved" />
			</cfcase>
			<cfcase value="draft">
				<cfset stLocal.event = "Drafted" />
			</cfcase>
			<cfcase value="pending">
				<cfset stLocal.event = "Sent to pending" />
			</cfcase>
		</cfswitch>
	<cfelse>
		<cfset stLocal.event = "Created" />
	</cfif>
	<cfset stLocal.event = application.fapi.getResource("coapi.dmArchive.contants.#lcase(rereplace(stLocal.event,'[^\w]','','all'))#@text",stLocal.event) />
	
	<!--- Username --->
	<cfset stLocal.stProfile = application.fapi.getContentType("dmProfile").getProfile(username=stObject.lastupdatedby) />
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.username = stLocal.stProfile.firstname & " " & stLocal.stProfile.lastname />
	<cfelse>
		<cfset stLocal.username = listfirst(stObject.lastupdatedby,'_') />
	</cfif>
	
	<!--- Date --->
	<cfset stLocal.date = dateformat(stObject.datetimelastupdated,'d mmm yyyy') & " " & timeformat(stObject.datetimelastupdated,'h:mmtt') />
	
	<cfif arguments.stParam.mode eq "select" or not structkeyexists(stObject,"status") or not structkeyexists(stObject,"versionid") or (stLocal.deletePermission and structkeyexists(stObject,"status") and structkeyexists(stObject,"versionid") and stObject.status eq "approved")>
		<admin:resource key="coapi.dmArchive.teaser_displayonly@html" var1="#stLocal.event#" var2="#stLocal.username#" var3="#stLocal.date#"><cfoutput>
			{1} by {2} on {3}
		</cfoutput></admin:resource>
	<cfelse>
		<admin:resource key="coapi.dmArchive.teaser_notapproved@html" var1="#stLocal.event#" var2="#stLocal.username#" var3="#stLocal.date#" var4="#stObject.objectid#"><cfoutput>
			{1} by {2} on {3}<br>
			[<a href="##" class="discard" rel="{4}">Discard</a>]
		</cfoutput></admin:resource>
	</cfif>
	
<cfelse>
	
	<!--- Rollback permission --->
	<cfwddx action="wddx2cfml" input="#stObj.objectWDDX#" output="stLocal.stObject" />
	<cfif structkeyexists(stLocal.stObject,"status")>
		<sec:CheckPermission permission="RequestApproval" type="#stLocal.stObject.typename#" objectid="#stLocal.stObject.objectid#" result="stLocal.rollbackPermission" />
	<cfelse>
		<sec:CheckPermission permission="Edit" type="#stLocal.stObject.typename#" objectid="#stLocal.stObject.objectid#" result="stLocal.rollbackPermission" />
	</cfif>
	
	<!--- Event --->
	<cfif len(stObj.event)><!--- Rolled back | Saved | Published | Deleted | Unpublisehd --->
		<cfset stLocal.event = ucase(left(stObj.event,1)) & mid(stObj.event,2,100) />
	<cfelse>
		<cfset stLocal.event = "Created" />
	</cfif>
	<cfset stLocal.event = application.fapi.getResource("coapi.dmArchive.contants.#lcase(stLocal.event)#@text",stLocal.event) />
	
	<!--- Username --->
	<cfif len(stObj.username)>
		<cfset stLocal.stProfile = application.fapi.getContentType("dmProfile").getProfile(username=stObj.username) />
	<cfelse>
		<cfset stLocal.stProfile = application.fapi.getContentType("dmProfile").getProfile(username=stObj.lastupdatedby) />
	</cfif>
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.username = stLocal.stProfile.firstname & " " & stLocal.stProfile.lastname />
	<cfelse>
		<cfset stLocal.username = listfirst(stObj.lastupdatedby,'_') />
	</cfif>
	
	<!--- Date --->
	<cfset stLocal.date = "#dateformat(stObj.datetimecreated,'d mmm yyyy')#, #timeformat(stObj.datetimecreated,'h:mmtt')#" />
	
	<cfif arguments.stParam.mode eq "display" and stLocal.rollbackPermission>
		<admin:resource key="coapi.dmArchive.teaser_rollback@html" var1="#stLocal.event#" var2="#stLocal.username#" var3="#stLocal.date#" var4="#stObj.objectid#"><cfoutput>
			{1} by {2} on {3}<br>
			[<a href="##" class="rollback" rel="{4}">Rollback</a>]
		</cfoutput></admin:resource>
	<cfelse>
		<admin:resource key="coapi.dmArchive.teaser_displayonly@html" var1="#stLocal.event#" var2="#stLocal.username#" var3="#stLocal.date#"><cfoutput>
			{1} by {2} on {3}
		</cfoutput></admin:resource>
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false" />