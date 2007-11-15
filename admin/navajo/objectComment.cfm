<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/navajo/objectComment.cfm,v 1.20 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.20 $

|| DESCRIPTION || 
$Description: add comments to genericadmin items $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfparam name="url.finishURL" default="#application.url.farcry#/navajo/GenericAdmin.cfm">

<cfif isdefined("form.submit")>
	
	<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
	<!--- update status --->
	<cfparam name="form.lApprovers" default="all">
	<nj:objectStatus_dd attributecollection="#form#" lApprovers="" rMsg="msg">
	<!--- return to overview page --->
	<cfif isdefined("form.approveURL")>
		<cfset returnLocation = form.finishURL & "&approveURL=" & form.approveURL>
	<cfelse>
		<cfset returnLocation = form.finishURL>
	</cfif>
	<cflocation url="#returnLocation#" addtoken="no">
<cfelse>
	<cfoutput>
	<script>
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
	
	<!--- get object details --->
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#listgetat(url.objectID,1)#" r_stobject="stObj">

	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form name="form" action="" method="post">
			<!--- hack to pass attributes through form --->
			<input type="hidden" name="objectid" value="#stObj.objectid#">
			<input type="hidden" name="lObjectids" value="#url.objectid#">
			<input type="hidden" name="status" value="#url.status#">
			<input type="hidden" name="typename" value="#stObj.typename#">
			<input type="hidden" name="finishURL" value="#url.finishURL#">
			<cfif isDefined("URL.approveURL")>
				<input type="hidden" name="approveURL" value="#URLEncodedFormat(url.approveURL)#">
			</cfif>
			
			<span class="formTitle">#application.adminBundle[session.dmProfile.locale].addComment#:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br>
			
			<!--- if requesting approval, list approvers --->
			<cfif url.status eq "requestApproval">
	
			</cfif>
			
			<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].submitUC#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#stObj.typename#';"></div>     
			<cfif listlen(url.objectid) eq 1>
				<!--- display existing comments --->
				<cfif structKeyExists(stObj,"commentLog")>
					<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
						<p></p><span class="formTitle">#application.adminBundle[session.dmProfile.locale].prevCommentLog#</span><P></P>
						#htmlcodeformat(stObj.commentLog)#
					</cfif>
				</cfif>
			</cfif>
			</form>
		</cfoutput>
	</cfif>
</cfif>

<!--- setup footer --->
<admin:footer>