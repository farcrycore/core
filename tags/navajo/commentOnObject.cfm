<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="true">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
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


<ft:processForm action="Submit" bHideForms="true">
	<cfset stObj.datetimelastupdated = CreateODBCDate(now())>
	<cfset stObj.datetimecreated = CreateODBCDate("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#")>
	
	<!--- Log comments --->
	<farcry:logevent object="#stObj.objectid#" type="types" event="comment" note="#commentLog#" />
	
</ft:processForm>

<ft:processForm action="Submit,Cancel" bHideForms="true">
	<skin:onReady>
		<cfoutput>window.location.href = window.location.href;</cfoutput>
	</skin:onReady>
</ft:processForm>

<cfif application.fapi.getContentTypeMetadata(stobj.typename, "bUseInTree", false)>	
	<nj:getNavigation objectid="#objectID#" r_objectID="parentID" bInclusive="1">	
	<cfif len(parentID)>
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


<admin:header>


<ft:form name="commentOnObject" action="#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#" bAjaxSubmission="true">
	<ft:fieldset>
		<ft:field label="#application.rb.getResource('workflow.buttons.addcomment@label',"Add Comments")#">
			<cfoutput><textarea id="commentLog" name="commentLog" class="textareaInput"></textarea></cfoutput>
		</ft:field>
	</ft:fieldset>
	
	<ft:buttonPanel>
		<ft:button value="Submit" text="#application.rb.getResource('workflow.buttons.submit@label','Submit')#" selectedObjectID="#stObj.objectid#" />
		<ft:button value="Cancel" text="#application.rb.getResource('workflow.buttons.submit@label','Cancel')#" validate="false" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>


<cfsetting enablecfoutputonly="false">
