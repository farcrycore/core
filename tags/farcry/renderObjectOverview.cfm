<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.objectid" default="">
<cfparam name="errormessage" default="">
<cfset objectid = trim(attributes.objectid)>
<cfif objectid EQ "">
	<cfset errormessage = "Invalid ObjectID: object overview can not be render.<br />">
<cfelse>								
	<cfset q4 = createObject("component","farcry.farcry_core.packages.fourq.fourq")>
	<cfset typename = q4.findType(url.objectid)>
	<cfset objType = createObject("component",application.types['#typename#'].typepath)>
	
	<!--- getObjectOverview() function can be overwritten in the contents cfc and filled with what ever display it may need --->
	<!--- get the correct version of the object to overview --->
	<cfset stObjectOverview = objType.getObjectOverview(objectid)>
	<cfif structKeyExists(stObjectOverview,"versionID") AND stObjectOverview.versionID NEQ "">
		<cfset stObjectOverview = objType.getObjectOverview(stObjectOverview.versionID)>
	</cfif>

	<!--- check permission --->
	<cfset stUser = request.dmsec.oAuthentication.getUserAuthenticationData()>
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
	<nj:getNavigation objectId="#objectid#" r_ObjectId="parentID" r_stObject="stParent" bInclusive="1">
	<cfset stPermissions = StructNew()>
	<cfset stPermissions.iDeveloperPermission = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer")>
	<cfset stPermissions.iEdit = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="edit")>
	<cfset stPermissions.iRequest = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="RequestApproval")>
	<cfset stPermissions.iApprove = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="Approve")>
	<cfset stPermissions.iApproveOwn = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="CanApproveOwnContent")>
	<cfset stPermissions.iObjectDumpTab = request.dmSec.oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="ObjectDumpTab")>
	<cfset stPermissions.iDelete = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="delete")>
									
	<!--- grab draft object overview --->
	<cfset stObjectOverviewDraft = StructNew()>
	<cfif structKeyExists(stObjectOverview,"versionID") AND structKeyExists(stObjectOverview,"status") AND stObjectOverview.status EQ "approved">
		<cfset oVersioning = createObject("component", "#application.packagepath#.farcry.versioning")>
		<cfset qDraft = oVersioning.checkIsDraft(objectid=stObjectOverview.objectid,type=stObjectOverview.typename)>
		<cfif qDraft.recordcount>
			<cfset stObjectOverviewDraft = objType.getObjectOverview(qDraft.objectid)>
			<cfif stPermissions.iApproveOwn EQ 1 AND NOT stObjectOverviewDraft.lastUpdatedBy EQ stUser.userLogin>
				<cfset stPermissions.iApproveOwn = 0>
			</cfif>
		</cfif>
	</cfif>
		
	<cfif StructIsEmpty(stObjectOverview)>
		<cfset errormessage = "Object overview can not be found.<br />">
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">

<cfif errormessage NEQ ""> <!--- check for any errors --->
	<cfoutput><span class="error">Error:</span> #errormessage#</cfoutput>
<cfelse> <!--- all good to display --->
<div class="tab-container" id="container1">

	<!--- TODO: i18n --->
	<ul class="tabs"><cfif NOT structIsEmpty(stObjectOverviewDraft)>
	<li onclick="return showPane('pane1', this)" id="tab1"><a href="#pane1-ref"><cfoutput>#stObjectOverviewDraft.status#</cfoutput></a></li></cfif>
	<li onclick="return showPane('pane2', this)" id="tab2"><a href="#pane2-ref"><cfoutput>#stObjectOverview.status#</cfoutput></a></li>
	</ul>

	<div class="tab-panes"> <!--- panes tabs div --->
<cfif NOT structIsEmpty(stObjectOverviewDraft)>
		<a name="pane1-ref"></a> <!--- show draft pane --->
		<div id="pane1"> <!--- pane1 --->
<!--- <cfoutput>#fDisplayObjectOverview(stObjectOverviewDraft,stPermissions)#</cfoutput> --->
		</div> <!--- // pane1 --->
</cfif>

		<a name="pane2-ref"></a> <!--- show approved pane --->
		<div id="pane2">
<!--- <cfoutput>#fDisplayObjectOverview(stObjectOverview,stPermissions)#</cfoutput> --->
		</div>
	</div> <!--- //panes tabs div --->
</div>
</cfif>

<cffunction name="fDisplayObjectOverview" output="false" returntype="string">
	<cfargument name="stObject" required="true" type="struct">
	<cfargument name="stPermissions" required="true" type="struct">

	<cfset stObject = arguments.stObject>
	<cfset stPermissions = arguments.stPermissions>
	
	<cfsavecontent variable="displayContent"><cfoutput>
<div class="wizard-nav">
<!--- work out different options depending on object status --->
<cfif StructKeyExists(stObject,"status")>
<cfswitch expression="#stObject.status#">
	<cfcase value="draft"> <!--- DRAFT STATUS --->
		<!--- check user can edit --->
		<cfif stPermissions.iEdit EQ 1>
<a href="edittabEdit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].editObj#</a><br />
<a onclick="confirmRestore('#parentid#','#stObject.objectid#');" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].restoreLiveObj#</a><br />
		</cfif>
		<!--- Check user can request approval --->
		<cfif stPermissions.iRequest eq 1>
<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=requestapproval">#application.adminBundle[session.dmProfile.locale].requestApproval#</a><br />
		</cfif>
		<!--- check user can approve object --->
		<cfif stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1>
<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br />
		</cfif>
	</cfcase>

	<cfcase value="pending"> <!--- PENDING STATUS --->
		<cfif stPermissions.iApprove eq 1> <!--- check user can approve object --->
<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br />
		<!--- send back to draft --->
<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=draft">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a><br />
		</cfif>
	</cfcase>
	<cfcase value="approved">
APPROVED OPS
	</cfcase>
</cfswitch></cfif>
<!--- preview object --->
<a href="#application.url.webroot#/index.cfm?objectid=#stObject.objectid#&flushcache=1&showdraft=1" target="_winPreview">#application.adminBundle[session.dmProfile.locale].preview#</a><br />

<cfif stPermissions.iDelete eq 1> <!--- delete object --->
[DO DELETE OPTION]
<!--- <a href="edittabEdit.cfm?objectid=#stobj.objectid#&deleteDraftObjectID=#stObject.ObjectID#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].deleteDraftVersion#</a><br /> --->
</cfif>
							
</div><cfset tIconName = LCase(Right(stObject.typename,len(stObject.typename)-2))><cfoutput>
<img src="#application.url.farcry#/images/icons/#tIconName#.png" alt="alt text" class="icon" /></cfoutput>

<dl class="dl-style1">
<dt>#application.adminBundle[session.dmProfile.locale].objTitleLabel#</dt>
<dd><cfif stObject.label NEQ "">
	#stObject.label#<cfelse>
	<i>#application.adminBundle[session.dmProfile.locale].undefined#</i></cfif>
</dd>
<dt>#application.adminBundle[session.dmProfile.locale].objTypeLabel#</dt>
<dd><cfif structKeyExists(application.types[stObject.typename],"displayname")>
	#application.types[stObject.typename].displayname#<cfelse>
	#stObject.typename#</cfif>
</dd>
<dt>#application.adminBundle[session.dmProfile.locale].createdByLabel#</dt>
<dd>#stObject.createdby#</dd>
<dt>#application.adminBundle[session.dmProfile.locale].dateCreatedLabel#</dt>
<dd>#application.thisCalendar.i18nDateFormat(stObject.datetimecreated,session.dmProfile.locale,application.shortF)#</dd>
<dt>#application.adminBundle[session.dmProfile.locale].lockingLabel#</dt>
<dd><cfif stObject.locked and stObject.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
		<!--- locked by current user --->
		<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stObject.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
	<span style="color:red">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].locked,tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stObject.objectid#&typename=#stObject.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a>
	<cfelseif stObject.locked>
		<!--- locked by another user --->
		<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stObject.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stObject.lockedby#')>
	#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].lockedBy,subS)#
		<!--- check if current user is a sysadmin so they can unlock --->
		<cfif stPermissions.iDeveloperPermission eq 1><!--- show link to unlock --->
		<a href="navajo/unlock.cfm?objectid=#stObject.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unlockUC#]</a>
		</cfif><cfelse><!--- no locking --->
		#application.adminBundle[session.dmProfile.locale].unlocked#</cfif>
</dd><cfif IsDefined("stObject.displaymethod")>
<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedLabel#</dt>
<dd>#application.thisCalendar.i18nDateFormat(stObject.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedByLabel#</dt>
<dd>#stObject.lastupdatedby#</dd>
<dt>#application.adminBundle[session.dmProfile.locale].currentStatusLabel#</dt>
<dd>#stObject.status#</dd>
<dt>#application.adminBundle[session.dmProfile.locale].templateLabel#</dt>
<dd>#stObject.displaymethod#</dd></cfif><cfif IsDefined("stObject.teaser")>
<dt>#application.adminBundle[session.dmProfile.locale].teaserLabel#</dt>
<dd>#stObject.teaser#</dd></cfif><cfif IsDefined("stObject.thumbnailimagepath") AND stObject.thumbnailimagepath NEQ "">
<dt>#application.adminBundle[session.dmProfile.locale].thumbnailLabel#</dt>
<dd><img src="#application.url.webroot#/images/#stObject.thumbnail#"></dd></cfif><cfif stPermissions.iDeveloperPermission eq 1>
<dt>ObjectID</dt>
<dd>#stObject.objectid#</dd></cfif>
</dl>
<hr />
<ul>
	<!--- add comments --->
	<li><a href="navajo/commentOnContent.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].addComments#</a></li>
	<!--- view comments --->
	<li><a href="##" onClick="commWin=window.open('#application.url.farcry#/navajo/viewComments.cfm?objectid=#stObject.objectid#', 'commWin', 'width=400,height=450');commWin.focus();">#application.adminBundle[session.dmProfile.locale].viewComments#</a></li><cfif stPermissions.iObjectDumpTab>
	<!--- dump content --->
	<li><a href="##" onClick="commWin=window.open('#application.url.farcry#/edittabDump.cfm?objectid=#stObject.objectid#', 'commWin', 'width=800,height=600');commWin.focus();">Dump</a></li></cfif>
</ul>
	</cfoutput></cfsavecontent>
	<cfreturn displayContent>
</cffunction>