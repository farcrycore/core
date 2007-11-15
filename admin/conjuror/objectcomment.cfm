<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/conjuror/objectcomment.cfm,v 1.2 2005/07/14 23:49:33 guy Exp $
$Author: guy $
$Date: 2005/07/14 23:49:33 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: add comments to genericadmin items 
rehash of the old ../navajo/objectcomment.cfm template for typeadmin interface
refactoring WIP 20050614GB
$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
--->
<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">

<!--- imported tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	
<!--- required parameters --->
<cfparam name="url.finishURL">

<!--- optional attributes --->
<cfparam name="form.lApprovers" default="all">

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<!--- status change: change object status and redirect --->
<cfif isdefined("form.submit")>
	<!--- update status --->
	<nj:objectStatus_dd attributecollection="#form#" lApprovers="" rMsg="msg">
	<!--- return to overview page --->
	<cfif isdefined("form.approveURL")>
		<cfset returnLocation = form.finishURL & "&approveURL=" & form.approveURL>
	<cfelse>
		<cfset returnLocation = form.finishURL>
	</cfif>
	<cflocation url="#returnLocation#" addtoken="no">
	
<!--- comments form: build generic comment form and approver list --->
<cfelse>
	<!--- get object details --->
	<q4:contentobjectget objectid="#listgetat(url.objectID,1)#" r_stobject="stObj">

	<!--- js for select all option --->
	<cfoutput>
	<script type="text/javascript">
	function deSelectAll()
	{
		if(document.form.lApprovers[0].checked = true)
		{
			for(var i = 1;i < document.form.lApprovers.length;i++)
			{
				document.form.lApprovers[i].checked = false;
			}
		} 
		return true;
	}	
	</script>
	</cfoutput>

	<!--- show comment form --->
	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form name="form" class="f-wrap-1 wider f-bg-medium" action="" method="post">
			<!--- pass url attributes through form as hidden fields --->
			<input type="hidden" name="objectid" value="#stObj.objectid#">
			<input type="hidden" name="lObjectids" value="#url.objectid#">
			<input type="hidden" name="status" value="#url.status#">
			<input type="hidden" name="typename" value="#stObj.typename#">
			<input type="hidden" name="finishURL" value="#url.finishURL#">
<fieldset>
	<label for="commentLog"><b>#application.adminBundle[session.dmProfile.locale].addComment#:</b>
		<textarea id="commentLog" name="commentLog"></textarea>
	</label>

		</cfoutput>
			<!--- if requesting approval, list approvers --->
			<cfif url.status eq "requestApproval">

			</cfif>
			<cfoutput>
	</label>
</fieldset>
<div class="f-submit-wrap">
	<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].submitUC#" class="f-submit" />
	<input type="submit" name="cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit">
</div>
<cfif StructKeyExists(stObj,"commentLog")>
<fieldset>
	<label><b>#application.adminBundle[session.dmProfile.locale].prevCommentLog#</b>
		<xmp>#stObj.commentLog#</xmp>
	</label>
</fieldset></cfif>
			</form>
		</cfoutput>
	<cfelse>
		<cfabort showerror="Comment on status change requires content type with object STATUS property.">
	</cfif>
	
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">