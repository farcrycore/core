<cfprocessingDirective pageencoding="utf-8">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<admin:header>

<div class="FormTitle"><cfoutput>#application.adminBundle[session.dmProfile.locale].addComment#</cfoutput></div>
<cfparam name="url.objectid" type="UUID">

<cfif isdefined("form.cancel")>
	<!--- hack to see if pop up window or from overview page --->
	<cfif isdefined("form.windowClose")>
		<cfoutput>
			<script>
				window.close();
			</script>
		</cfoutput>
	<cfelse>
		<q4:contentobjectget objectid="#form.objectId#"  r_stobject="stObj">
		
		<!--- check if object is a underlying draft page --->
		<cfif stobj.typename eq "dmHTML" and len(trim(stObj.versionId))>
			<cfset objId = stObj.versionId>
		<cfelse>
			<cfset objId = stObj.objectId>
		</cfif>
		<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
	</cfif>
	<cfabort>
</cfif>

<nj:getNavigation objectid="#url.objectID#" r_stObject="stNav" bInclusive="1">

<cfif not isstruct(stNav) or not structcount(stNav)>
	<cfoutput>
		<script>alert("#application.adminBundle[session.dmProfile.locale].cantCommentOnObject#");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>

<cfscript>
	oAuthorisation = request.dmSec.oAuthorisation;
	iCanCommentOnContent = oAuthorisation.checkInheritedPermission(objectid=stNav.objectid,permissionName='view');
</cfscript>


<q4:contentobjectget objectid="#url.objectId#"  r_stobject="stObj">


<cfif iCanCommentOnContent eq true and isdefined("stObj.commentLog")>
	<cfif not isdefined("form.commentLog")>
		<cfoutput>
			<form action="" method="post">
			<div><textarea cols="58" rows="3" name="commentLog"></textarea></div>
			<div>
			<input type="hidden" name="objectid" value="#stObj.objectid#">			
			<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].submitUC#" width="80" style="width:80;" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="">
			<input type="submit" name="cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" width="80" style="width:80;" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="">
			</div>
			<cfif len(trim(stObj.commentLog))>
				</div><h4>#application.adminBundle[session.dmProfile.locale].prevCommentLog#</h4><textarea cols="58" rows="12">#stObj.commentLog#</textarea></div>
			</cfif>
			</form>
		</cfoutput>
	<cfelse>	
		<cfscript>
			stObj.datetimelastupdated = createODBCDate(now());
			stObj.datetimecreated = createODBCDate("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#");
			//only if the comment log exists - do we actually append the entry
			if (structkeyexists(stObj, "commentLog")){
				buildLog =  "#chr(13)##chr(10)##session.dmSec.authentication.canonicalName#" & "(#application.thisCalendar.i18nDateFormat(now(),session.dmProfile.locale,application.mediumF)# #application.thisCalendar.i18nTimeFormat(now(),session.dmProfile.locale,application.mediumF)#:#chr(13)##chr(10)# #FORM.commentLog#";
				stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
				}
			// update the OBJECT	
			oType = createobject("component", application.types[stObj.typename].typePath);	
			oType.setData(stProperties=stObj,auditNote="Comment added");	
		</cfscript>
				
		<!--- hack to see if pop up window or from overview page --->
		<cfif isdefined("form.windowClose")>
			<cfoutput><script>window.close();</script></cfoutput>
		<cfelse>
			<!--- check if object is a underlying draft page --->
			<cfif stobj.typename eq "dmHTML" and len(trim(stObj.versionId))>
				<cfset objId = stObj.versionId>
			<cfelse>
				<cfset objId = stObj.objectId>
			</cfif>
			<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
		</cfif>
	</cfif>
<cfelse>
	<!--- hack to see if pop up window or from overview page --->
	<cfif isdefined("form.windowClose")>
		<cfoutput>
			<script>
				alert("#application.adminBundle[session.dmProfile.locale].cantCommentOnContent#");
				window.close();
			</script>
		</cfoutput>
	<cfelse>
		<!--- check if object is a underlying draft page --->
		<cfif stobj.typename eq "dmHTML" and len(trim(stObj.versionId))>
			<cfset objId = stObj.versionId>
		<cfelse>
			<cfset objId = stObj.objectId>
		</cfif>
		<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#objId#" addtoken="no">
	</cfif>
</cfif>
<cfoutput>
</body>
</html>
</cfoutput>
