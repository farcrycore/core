<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="true">
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
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
		
		<!--- Log comments --->
		<farcry:logevent object="#stObj.objectid#" type="types" event="comment" note="#commentLog#" />
	</cfif>
	
	<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
	<cfabort>
<cfelse>

</cfif>

<nj:getNavigation objectid="#objectID#" r_stObject="stNav" bInclusive="1">
<cfif StructKeyExists(application.types[stObj.typename],"bUseInTree") AND application.types[stObj.typename].bUseInTree>
	<cfif StructIsEmpty(stNav)>
		<cfset iCanCommentOnContent = application.security.checkPermission(object=objectID,permission='view')>
	<cfelse>
		<cfset permsissionSet = "news">
		<cfset iCanCommentOnContent = application.security.checkPermission(permission="#permsissionSet#Edit")>
	</cfif>
<cfelse>
	<cfset permsissionSet = "news">
	<cfset iCanCommentOnContent = application.security.checkPermission(permission="#permsissionSet#Edit")>
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
	alert("#application.rb.getResource("cantCommentOnObject")#");
	window.close();
</script></cfoutput><cfabort>
</cfif>
<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" method="post">
<fieldset>
	<label for="commentLog"><b>#application.rb.getResource("addComment")#</b>
		<textarea id="commentLog" name="commentLog"></textarea>
	</label>
</fieldset>
<div class="f-submit-wrap">
	<input type="submit" name="submit" value="#application.rb.getResource("submitUC")#" class="f-submit" />
	<input type="submit" name="cancel" value="#application.rb.getResource("cancel")#" class="f-submit">
</div>
<fieldset>
	<label><b>#application.rb.getResource("prevCommentLog")#</b>
		<nj:showcomments objectid="#stObj.objectid#" typename="#stObj.typename#" />
	</label>
</fieldset>
	<input type="hidden" name="formSubmitted" value="yes">
	<input type="hidden" name="objectid" value="#stObj.objectid#">
</form></cfoutput>
<admin:footer>
