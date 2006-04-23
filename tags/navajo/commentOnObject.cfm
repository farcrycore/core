<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="true">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfparam name="objectid" type="UUID">
<cfparam name="formSubmitted" default="no">

<q4:contentobjectget objectid="#objectId#"  r_stobject="stObj">
<!--- check if object is a underlying draft page (used for redirection) --->
<cfif stobj.typename eq "dmHTML" and len(trim(stObj.versionId))>
	<cfset objId = stObj.versionId>
<cfelse>
	<cfset objId = stObj.objectId>
</cfif>
		
<cfif formSubmitted EQ "yes">
	<cfif isDefined("submit")> <!--- added comment if submit button clicked //else just cancel out--->
		<cfset stObj.datetimelastupdated = CreateODBCDate(now())>
		<cfset stObj.datetimecreated = CreateODBCDate("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#")>
		<!--- only if the comment log exists - do we actually append the entry --->
		<cfif structkeyexists(stObj, "commentLog")>
			<cfset buildLog =  "#chr(13)##chr(10)##session.dmSec.authentication.canonicalName#" & "(#application.thisCalendar.i18nDateFormat(now(),session.dmProfile.locale,application.mediumF)# #application.thisCalendar.i18nTimeFormat(now(),session.dmProfile.locale,application.mediumF)#:#chr(13)##chr(10)# #commentLog#">
			<cfset stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog>
		</cfif>
		<!--- update the OBJECT --->
		<cfset oType = createobject("component", application.types[stObj.typename].typePath)>
		<cfset oType.setData(stProperties=stObj,auditNote="Comment added")>
	</cfif>
	
	<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
	<cfabort>
<cfelse>

</cfif>

<cfset oAuthorisation = request.dmSec.oAuthorisation>
<nj:getNavigation objectid="#objectID#" r_stObject="stNav" bInclusive="1">
<cfif StructKeyExists(application.types[stObj.typename],"bUseInTree") AND application.types[stObj.typename].bUseInTree>
	<cfif StructIsEmpty(stNav)>
		<cfset iCanCommentOnContent = oAuthorisation.checkPermission(objectid=objectID,permissionName='view')>
	<cfelse>
		<cfset iCanCommentOnContent = oAuthorisation.checkPermission(permissionName="view",reference="PolicyGroup")>
	</cfif>
<cfelse>
	<cfset permsissionSet = "news">
	<cfset iCanCommentOnContent = oAuthorisation.checkPermission(permissionName="#permsissionSet#Edit",reference="PolicyGroup")>
</cfif>

<cfif iCanCommentOnContent EQ false OR StructIsEmpty(stObj)>
	<cfif stobj.typename eq "dmHTML" and len(trim(stObj.versionId))>
		<cfset objId = stObj.versionId>
	<cfelse>
		<cfset objId = stObj.objectId>
	</cfif>
	<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
</cfif>

<cfsetting enablecfoutputonly="false">

<admin:header>

<cfif iCanCommentOnContent EQ 0><cfoutput>
<script type="text/javascript">
	alert("#application.adminBundle[session.dmProfile.locale].cantCommentOnObject#");
	window.close();
</script></cfoutput><cfabort>
</cfif>
<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" method="post">
<fieldset>
	<label for="commentLog"><b>#application.adminBundle[session.dmProfile.locale].addComment#</b>
		<textarea id="commentLog" name="commentLog"></textarea>
	</label>
</fieldset>
<div class="f-submit-wrap">
	<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].submitUC#" class="f-submit" />
	<input type="submit" name="cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit">
</div><cfif len(trim(stObj.commentLog))>
<fieldset>
	<label><b>#application.adminBundle[session.dmProfile.locale].prevCommentLog#</b>
		<xmp>#stObj.commentLog#</xmp>
	</label>
</fieldset></cfif>
	<input type="hidden" name="formSubmitted" value="yes">
	<input type="hidden" name="objectid" value="#stObj.objectid#">
</form></cfoutput>
<admin:footer>
