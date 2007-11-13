<!--- check if underlying draft version, need to get details of approved object --->
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="stLocal.errormessage" default="">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<nj:getNavigation objectId="#arguments.objectid#" r_ObjectId="stLocal.parentID" r_stObject="stLocal.stParent" bInclusive="1">

<!--- get the correct version of the object to overview --->
<cfset stLocal.stObjectOverview = getData(arguments.objectid)>
<cfif structKeyExists(stLocal.stObjectOverview,"versionID") AND stLocal.stObjectOverview.versionID NEQ "">
	<cfset stLocal.stObjectOverview = getData(stLocal.stObjectOverview.versionID)>
</cfif>

<cfset stLocal.stObjectOverview.parentID = stLocal.parentID>
<cfset stLocal.stObjectOverview.objectID_PreviousVersion = stLocal.stObjectOverview.objectID>

<cfif Application.config.plugins.fu>
	<cfset objectFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	<cfset returnstruct = objectFU.fListFriendlyURL(stLocal.stObjectOverview.objectid,"current")>
	<cfif returnstruct.bSuccess>
		<cfset stLocal.stObjectOverview.qListFriendlyURL = returnstruct.queryObject>
	</cfif>
</cfif>

<cfif StructIsEmpty(stLocal.stObjectOverview)> <!--- no record exist --->
	<cfset errormessage = "Object overview can not be found.<br />">
<cfelse> <!--- generate all data required for the overview html --->
	<!--- check/generate permission --->
	<cfset stLocal.stUser = application.factory.oAuthentication.getUserAuthenticationData()>
	<cfset stLocal.stPermissions = StructNew()>
	
	<cfset stLocal.stPermissions.iDeveloperPermission = application.security.checkPermission(permission="developer")>
	<cfset stLocal.stPermissions.iCreate = application.security.checkPermission(object=stLocal.parentid,permission="create")>
	<cfset stLocal.stPermissions.iEdit = application.security.checkPermission(object=stLocal.parentid,permission="edit")>
	<cfset stLocal.stPermissions.iRequest = application.security.checkPermission(object=stLocal.parentid,permission="RequestApproval")>
	<cfset stLocal.stPermissions.iApprove = application.security.checkPermission(object=stLocal.parentid,permission="Approve")>
	<cfset stLocal.stPermissions.iApproveOwn = application.security.checkPermission(object=stLocal.parentid,permission="CanApproveOwnContent")>
	<cfset stLocal.stPermissions.iObjectDumpTab = application.security.checkPermission(permission="ObjectDumpTab")>
	<cfset stLocal.stPermissions.iDelete = application.security.checkPermission(object=stLocal.parentid,permission="delete")>
	<cfset stLocal.stPermissions.iTreeSendToTrash = application.security.checkPermission(object=stLocal.parentid,permission="SendToTrash")>
			
	<!--- grab draft object overview --->
	<cfset stLocal.stObjectOverviewDraft = StructNew()>
	<cfif structKeyExists(stLocal.stObjectOverview,"versionID") AND structKeyExists(stLocal.stObjectOverview,"status") AND stLocal.stObjectOverview.status EQ "approved">
		<cfset stLocal.oVersioning = createObject("component", "#application.packagepath#.farcry.versioning")>
		<cfset stLocal.qDraft = stLocal.oVersioning.checkIsDraft(objectid=stLocal.stObjectOverview.objectid,type=stLocal.stObjectOverview.typename)>
		<cfif stLocal.qDraft.recordcount>
			<cfset stLocal.stObjectOverviewDraft = getData(stLocal.qDraft.objectid)>
			<cfset stLocal.stObjectOverviewDraft.parentID = stLocal.parentID>
			<cfset stLocal.stObjectOverviewDraft.bHasDraft = 0>
			<!--- object tid of the current live version used by the delete function --->
			<cfset stLocal.stObjectOverviewDraft.objectID_PreviousVersion = stLocal.stObjectOverview.objectID>
			<cfif stLocal.stPermissions.iApproveOwn EQ 1 AND NOT stLocal.stObjectOverviewDraft.lastUpdatedBy EQ stLocal.stUser.userLogin>
				<cfset stLocal.stPermissions.iApproveOwn = 0>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<!--- pass to indicate if this object has a current draft version --->
<cfset stLocal.stObjectOverview.bHasDraft = NOT structIsEmpty(stLocal.stObjectOverviewDraft)>
<!--- always show the edit option regardless of state --->
<cfset stLocal.stObjectOverview.bAlwaysShowEdit = 1>

<cfsavecontent variable="stLocal.html">
<cfif stLocal.errormessage NEQ ""> <!--- check for any errors --->
	<cfoutput><span class="error">Error:</span> #stLocal.errormessage#</cfoutput>
<cfelse><cfset iCounter = 1><cfoutput><!--- all good to display --->
<div class="tab-container" id="container1">
	<!--- TODO: i18n --->
	<ul class="tabs"><cfif StructKeyExists(stLocal.stObjectOverview,"status")><cfif NOT structIsEmpty(stLocal.stObjectOverviewDraft)>
	<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane1-ref">#stLocal.stObjectOverviewDraft.status#</a></li><cfset iCounter = iCounter + 1></cfif>
	<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane2-ref">#stLocal.stObjectOverview.status#</a></li><cfelse>
	<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane2-ref">Approved/Live</a></li></cfif>
	</ul>
	
	<div class="tab-panes"> <!--- panes tabs div ---><cfset iCounter = 1>
<cfif NOT structIsEmpty(stLocal.stObjectOverviewDraft)>
		<a name="pane#iCounter#-ref"></a> <!--- show draft pane --->
		<div id="pane#iCounter#"> <!--- pane1 --->
#fDisplayObjectOverview(stLocal.stObjectOverviewDraft,stLocal.stPermissions)#
		</div> <!--- // pane1 --->
	<cfset iCounter = iCounter + 1>
</cfif>

		<a name="pane#iCounter#-ref"></a> <!--- show approved pane --->
		<div id="pane#iCounter#">
#fDisplayObjectOverview(stLocal.stObjectOverview,stLocal.stPermissions)#
		</div>
	</div> <!--- //panes tabs div --->
</div></cfoutput>
</cfif>	
</cfsavecontent>