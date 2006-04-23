<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/objectComment.cfm,v 1.14.2.3 2005/06/27 00:11:54 guy Exp $
$Author: guy $
$Date: 2005/06/27 00:11:54 $
$Name: milestone_2-1-2 $
$Revision: 1.14.2.3 $

|| DESCRIPTION || 
$Description: add comments to genericadmin items $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfparam name="url.finishURL" default="#application.url.farcry#/navajo/GenericAdmin.cfm">

<cfif isdefined("form.submit")>
	
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
	<!--- update status --->
	<cfparam name="form.lApprovers" default="all">
	<nj:objectStatus_dd attributecollection="#form#" lApprovers="#form.lApprovers#" rMsg="msg">
	<!--- return to overview page --->
	<cfif isdefined("form.approveURL")>
		<cfset returnLocation = form.finishURL & "&approveURL=" & form.approveURL>
	<cfelse>
		<cfset returnLocation = form.finishURL>
	</cfif>
	<cfset returnLocation = urldecode(returnLocation)>

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
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
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
			
			<span class="formTitle">Add your comments:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br>
			
			<!--- if requesting approval, list approvers --->
			<cfif url.status eq "requestApproval">
				<span class="formLabel">Request Approval From</span><br/>
				
				<input type="checkbox" onclick="if(this.checked)deSelectAll();" name="lApprovers" value="all" checked="true">All approvers<br/>
				
				<!--- get list of approvers for this object --->
				<cfinvoke component="#application.packagepath#.farcry.workflow" method="getNewsApprovers" returnvariable="stApprovers">
					<cfinvokeargument name="objectID" value="#listFirst(url.objectID)#"/>
				</cfinvoke>
				<!--- loop over approvers and display ones that have email profiles --->
				<cfloop collection="#stApprovers#" item="item">
				    <cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail and stApprovers[item].userName neq session.dmSec.authentication.userLogin>
						<input type="checkbox" name="lApprovers" onclick="if(this.checked)document.form.lApprovers[0].checked = false;" value="#stApprovers[item].userName#"><cfif len(stApprovers[item].firstName) gt 0>#stApprovers[item].firstName# #stApprovers[item].lastName#<cfelse>#stApprovers[item].userName#</cfif><br/>
					</cfif>
				</cfloop>
				<p></p>
			</cfif>
			
			<input type="submit" name="submit" value="Submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#stObj.typename#';"></div>     
			<cfif listlen(url.objectid) eq 1>
				<!--- display existing comments --->
				<cfif structKeyExists(stObj,"commentLog")>
					<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
						<p></p><span class="formTitle">Previous Comments</span><P></P>
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