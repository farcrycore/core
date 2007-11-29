<!--- 
THIS IS DEPRICATED PAGE AND SHOULD BE USING navajo/approve.cfm
A CFLOCATION HAS BEEN ADDED TO REDIRECT
 --->



<cfsetting enablecfoutputonly="true">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/conjuror/changestatus.cfm,v 1.3.2.1 2006/02/24 00:31:42 paul Exp $
$Author: paul $
$Date: 2006/02/24 00:31:42 $
$Name: milestone_3-0-1 $
$Revision: 1.3.2.1 $

|| DESCRIPTION || 
$Description: Change status summoner.  
Designed to accept variables as GET/POST submissions and should 
be able to handle multiple objectids. Uses first objectid listed 
to determine content type. ie. not designed to process multiple
content types in one submission. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<!--- imported tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">

<!--- required parameters as FORM or URL variables --->
<cfif isDefined("url.objectid") AND len(url.objectid)>
	<cfset objectid=url.objectid>
<cfelseif isDefined("form.objectid") AND len(form.objectid)>
	<cfset objectid=form.objectid>
<cfelse>
	<cfabort showerror="<strong>Error:</strong> objectid is a required parameter.">
</cfif>
<cfif isDefined("url.typename") AND len(url.typename)>
	<cfset typename=url.typename>
<cfelseif isDefined("form.typename") AND len(form.typename)>
	<cfset typename=form.typename>
<cfelse>
	<cfset typename="">
</cfif>
<cfif isDefined("url.ref") AND len(url.ref)>
	<cfset ref=url.ref>
<cfelseif isDefined("form.ref") AND len(form.ref)>
	<cfset ref=form.ref>
<cfelse>
	<cfset ref="sitetree">
</cfif>
<!--- status: default options include approved, requestapproval, draft --->
<cfif isDefined("url.status") AND len(url.status)>
	<cfset status=url.status>
<cfelseif isDefined("form.status") AND len(form.status)>
	<cfset status=form.status>
<cfelse>
	<cfabort showerror="<strong>Error:</strong> status is a required parameter.">
</cfif>

<farcry:deprecated message="should be using navajo/approve.cfm" />
<cflocation url="#application.url.farcry#/navajo/approve.cfm?objectid=#url.objectid#&status=#url.status#" addtoken="false" />


<!--- finishURL: location to return user post finish --->
<cfif isDefined("url.finishURL") AND len(url.finishURL)>
	<cfset finishURL=url.finishURL>
<cfelseif isDefined("form.finishURL") AND len(form.finishURL)>
	<cfset finishURL=form.finishURL>
<cfelseif isDefined("url.module") AND isDefined("url.plugin")>
	<cfset finishURL = "#application.url.farcry#/admin/customadmin.cfm?module=#url.module#&plugin=#URL.plugin#" />
<cfelseif isDefined("url.module")>
	<cfset finishURL = "#application.url.farcry#/admin/customadmin.cfm?module=#url.module#" />
<cfelse>
	<cfabort showerror="<strong>Error:</strong> finishURL is a required parameter.">
</cfif>

<!--- type lookup if required --->
<cfif len(typename) AND structKeyExists(application.types, typename)>
	<cfset typepath=application.types[typename].typePath>
<cfelse>
	<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
	<cfset typename = q4.findType(objectid=listFirst(objectID))>
	<cfif len(typename)>
		<cfset typepath=application.types[typename].typePath>
	<cfelse>
		<cfabort showerror="<strong>Error:</strong> typename could not be determined for ObjectID: #listFirst(objectID)# please delete it.">
	</cfif>
</cfif>

<!--- check that object actually has status to change --->
<cfif NOT structKeyExists(application.types[typename].stprops, "status")>
	<cfabort showerror="<strong>Error:</strong> content type #typename# does not have a status property." />
</cfif>

<!--- // self posting form action --->
<cfif isDefined("form.updatestatus")>
<cfloop list="#objectid#" index="id">
	<cfset oType=createObject("component", "#typepath#")>
	<cfset stobj=otype.getdata(objectid=id)>
	
	<cfswitch expression="#status#">
	<cfcase value="draft">
		<!--- set content item to draft --->
		<cfif stobj.status neq "draft">
			<cfset stresult=oType.statustodraft()>
		</cfif>
	</cfcase>
	
	<cfcase value="requestapproval">
		<!--- set content item to pending --->
		<cfif stobj.status neq "pending"> --->
			<cfset stresult=oType.statustopending()>
			
		</cfif> 

	</cfcase>
	
	<cfcase value="approved">
		<!--- set content item to approved --->
		<cfif stobj.status neq "approved">
			<cfset stresult=oType.statustoapproved()>
		</cfif>
	</cfcase>
	
	<cfdefaultcase>
		<cfabort showerror="<strong>Alert:</strong> hoping to bolt-in custom status change option in here. Nothing available for now.">
	</cfdefaultcase>
	</cfswitch>
</cfloop>

<cflocation url="#finishURL#" addtoken="false">

<!--- // view output --->
<cfelse>

<!--- 
get first content item for display options
 - do this by default as most changes will be for single content items
 - probably needs a little attention for multi-content changes
 --->	
	<cfset oType=createObject("component", "#typepath#")>
	<cfset stobj=otype.getdata(objectid=listfirst(objectid))>

<!--- if requesting approval, get approvers list --->
<cfif status eq "requestApproval">
	
	<cfsavecontent variable="approvers">
	<cfoutput>
	<fieldset>
	</cfoutput>
	<cfoutput></fieldset></cfoutput>
	</cfsavecontent>
</cfif>

	<!--- js for select all option --->
<cfsavecontent variable="js">
<cfoutput>
<script type="text/javascript">
function deSelectAll()
{
	if(document.changestatus.lApprovers[0].checked = true)
	{
		for(var i = 1;i < document.changestatus.lApprovers.length;i++)
		{
			document.changestatus.lApprovers[i].checked = false;
		}
	} 
	return true;
}	
</script>
</cfoutput>
</cfsavecontent>


<!--- output page --->
<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfhtmlhead text="#js#">

<cfoutput>
<h3>Changing status of #stobj.label# (#stobj.status#): #status#</h3>

<form action="" method="post" id="changestatus" name="changestatus" class="f-wrap-1 wider f-bg-medium">
	<!--- hidden fields --->
	<input type="hidden" name="objectid" value="#objectid#">
	<input type="hidden" name="typename" value="#typename#">
	<input type="hidden" name="ref" value="#ref#">
	<input type="hidden" name="status" value="#status#">
	<input type="hidden" name="finishURL" value="#finishURL#">

<fieldset>
<label for="commentLog"><b>#application.adminBundle[session.dmProfile.locale].addComment#:</b>
	<textarea id="commentLog" name="commentLog" rows="10" cols="60"></textarea>
</label>
</fieldset>

<!--- output list of approvers --->
<cfif isDefined("approvers")>#approvers#</cfif>

<div class="f-submit-wrap">
<input type="submit" name="updatestatus" value="#application.adminBundle[session.dmProfile.locale].submitUC#" class="f-submit" />
<input type="submit" name="cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit">
</div>
<cfif StructKeyExists(stObj,"commentLog") and len(stObj.commentLog)>
<fieldset>
	<label><b>#application.adminBundle[session.dmProfile.locale].prevCommentLog#</b>
		<xmp>#stObj.commentLog#</xmp>
	</label>
</fieldset></cfif>
</form>
</cfoutput>

<!--- set up page footer --->
<admin:footer>


</cfif>

<!--- 
<cfdump var="#stobj#">
<cfdump var="#url#">
<cfdump var="#form#">
<cfdump var="#application.types[typename]#" expand="false" label="type metadata">
 --->
<cfsetting enablecfoutputonly="false">