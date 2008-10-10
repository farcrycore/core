<!--- 
Merge of ..admin/navajo/approve.cfm and ../tags/navajo/objectstatus.cfm 
--->

<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">

<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/conjuror/approve.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: changes status of tree item $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
 
<cfparam name="url.objectId">
<cfparam name="url.status" default="0">
<cfparam name="attributes.lObjectIDs" default="#url.objectId#">


<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header>
<cfoutput>
<span class="FormTitle">
<cfif isDefined("URL.draftObjectID")>
	<admin:resource key="workflow.messages.objStatusRequest@text">Set content item status for underlying draft content item to 'request'</admin:resource>
<cfelse>	
	<admin:resource key="workflow.messages.setObjStatus@text" variables="url.status">Set content item status to {1}</admin:resource>
</cfif>	
</span><p></p>
</cfoutput>

<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

<cfset changestatus = true>
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
<cfif not isdefined("form.commentLog") and listlen(attributes.lObjectIDs) eq 1>
	<!--- get object details --->
	<q4:contentobjectget objectid="#attributes.lobjectIDs#" r_stobject="stObj">
	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form name="form" action="" method="post">
			<span class="formLabel">#application.rb.getResource("workflow.labels.addComments@label","Add your comments")#:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br />
			
			<!--- if requesting approval, list approvers --->
			<cfif url.status eq "requestApproval">
				
			
			</cfif>
			
			<input type="submit" name="submit" value="#application.rb.getResource('workflow.buttons.submit@label','Submit')#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" name="Cancel" value="#application.rb.getResource('workflow.buttons.cancel@label','Cancel')#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='../edittabOverview.cfm?objectid=#attributes.lobjectIDs#';"></div>     
			<!--- display existing comments --->
			<nj:showcomments objectid="#attributes.lobjectIDs#" typename="#stObj.typename#" />
			</form>
		</cfoutput>
		<cfset changestatus = false>
	</cfif>
</cfif>
<cfif changestatus eq true>
	<cfflush>
	<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">
		
		<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		
		
		<cfif not structkeyexists(stObj, "status")>
			<cfoutput><script> alert("#application.rb.getResource('workflow.messages.objNoApprovalProcess@text','This content item type has no approval process attached to it.')#");
				               window.close();
			</script></cfoutput><cfabort>
		</cfif>
		
		<!--- get the navigation root navigation of this object to check permissions on it --->
		<nj:getNavigation objectId="#stObj.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">

		<cfif url.status eq "approved">
			<cfset status = "approved">
			<cfset permission = "approve,canApproveOwnContent">
			<cfset active = 1>
			<!--- send out emails informing object has been approved --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_approved">
				<cfinvokeargument name="objectId" value="#stObj.objectID#"/>
				<cfinvokeargument name="comment" value="#form.commentlog#"/>
			</cfinvoke>

			
		<cfelseif url.status eq "draft">
			<cfset status = 'draft'>
			<cfset permission = "approve,canApproveOwnContent">
			<!--- send out emails informing object has been sent back to draft --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_draft">
				<cfinvokeargument name="objectId" value="#stObj.objectID#"/>
				<cfinvokeargument name="comment" value="#form.commentlog#"/>
			</cfinvoke>
			<cfset active = 0>
			
		<cfelseif url.status eq "requestApproval">
			<cfset status = "pending">
			<cfset permission = "requestApproval">
			<cfset active = 0>
			
			<!--- checkk if underlying draft obejct --->
			<cfif isDefined("URL.draftObjectID")>
				<cfset pendingObject = "#URL.draftObjectID#"/>
			<cfelse>
				<cfset pendingObject = "#stObj.objectID#"/>
			</cfif>
				
		<cfelse>
			<cfoutput><b>#application.rb.formatRBString("workflow.messages.unknownStatusPassed@text",url.status,"Unknown status passed. ({1})")#<b><br></cfoutput><cfabort>
		</cfif>
		
		<cfif isstruct(stNav)>
			<cfscript>
				for(x = 1;x LTE listLen(permission);x=x+1)
				{
					iState = application.security.checkPermission(permission=listGetAt(permission,x),object=stNav.objectId);	
					if(listGetAt(permission,x) IS "canApproveOwnContent" AND iState EQ 1 AND NOT stObj.lastUpdatedBy IS stUser.userLogin)
						iState = 0;
					if(iState EQ 1)
						break;
				}	
			</cfscript>
			
			<cfif iState neq 1>
				<cfoutput><script> alert("#application.rb.formatRBString('security.messages.nosubNodeApprovalPermission@text',stNav.title,'You don''t have approval permission on the subnode {1}')#");
					               window.close();
				</script></cfoutput><cfabort>
			</cfif>
		</cfif>
		<cfif url.status eq "approve">
			<cfscript>
				iState = application.security.checkPermission(permission="CanApproveOwnContent",object=stNav.objectId);	
			</cfscript>
		
			<cfif iState neq 1>
	
				<cfif request.bLoggedIn>
					<cfif session.security.userid eq stObj.attr_lastUpdatedBy>
						<cfoutput>
						<script>
							alert("#application.rb.formatRBString('security.messages.cantApproveOwnContent@text',stNav.title,'You don''t have permission to approve your own content on {1}')#");
							window.close();
						</script>
						</cfoutput>
						<cfabort>
					</cfif>
				<cfelse>
					<cfoutput>
					<script>
						alert("#application.rb.getResource('security.messages.notLoggedIn@text','You''re not logged in')#");
						window.close();
					</script>
					</cfoutput>
					<cfabort>
				</cfif>
				
			</cfif>
		</cfif>
				
		<!--- Call this to get all descendants of this node --->

		<!--- If we are approving the whole branch - then we will be wanting all objectIDS --->
		<cfif isDefined("URL.approveBranch")>
			<cfset keyList = attributes.objectID>
			<cfif isArray(stObj.aObjectIds)>
				<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
			</cfif>
			<cfscript>
				qGetDescendants = application.factory.oTree.getDescendants(objectid=attributes.objectID);
			</cfscript>
						
			<cfset keyList = listAppend(keyList,valueList(qGetDescendants.objectId))>
			<cfloop query="qGetDescendants">
				<q4:contentobjectget objectId="#qGetDescendants.objectId#" r_stObject="stThisObj">
				<cfif isArray(stThisObj.aObjectIds)>
					<cfset keyList = listAppend(keyList,arrayToList(stThisObj.aObjectIds))>
				</cfif>	
			</cfloop>
		<cfelse>  <!--- else - just get the objectIDS in this nodes aObjects array --->
			<cfif isDefined("URL.draftObjectID")>
				<cfset keyList = URL.draftObjectID>
			<cfelse>	
				<cfset keyList = attributes.objectID>
			</cfif>	
			<cfif isdefined("stObj.aObjectIds") and isArray(stObj.aObjectIds)>
				<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
			</cfif>
		</cfif>
						
		
		<cfoutput>Changing status....<br></cfoutput><cfflush>
		
		<!--- update the structure data for object update --->
	
		<cfloop list="#keyList#" index="key">
			<q4:contentobjectget objectId="#key#" r_stObject="stObj">
			
			<!--- prepare date fields --->
			<cfloop collection="#stObj#" item="field">
				<cfif StructKeyExists(application.types[stObj.typeName].stProps, field) and application.types[stObj.typeName].stProps[field].metaData.type eq "date">
					<cfset stObj[field] = CreateODBCDateTime(stObj[field])>
				</cfif>
			</cfloop>
			
			<cfset stObj.datetimelastupdated = createODBCDateTime(now()) />
			<cfset stObj.status = status />
			
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#key#" returnvariable="stRules">
			
			<cfif stRules.bLiveVersionExists and url.status eq "approved">
				 <!--- Then we want to swap live/draft and archive current live --->
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#key#"  stDraftObject="#stObj#" returnvariable="stRules">
				<cfset returnObjectID=stObj.objectid>
			<cfelse>
				<!--- a normal page, no underlying object --->
				<cfscript>
					oType = createobject("component", application.types[stObj.typename].typePath);
					oType.setData(stProperties=stObj,bAudit=false);
				</cfscript>
				
				<cfif stObj.typename neq "dmImage" and stObj.typename neq "dmFile">
					<cfset returnObjectId= url.objectid>
				</cfif>
			</cfif>
			
			<extjs:bubble title="#stObj.label#" message="Status changed to #status#" />
			<farcry:logevent object="#stObj.objectid#" type="types" event="to#status#" notes="#form.commentLog#" />
		</cfloop>
		
	</cfloop>
	<cfif isstruct(stNav)>
	   <nj:updateTree ObjectId="#stNav.objectId#">
	</cfif>
	
	<cfoutput><script>
		if( window.opener && window.opener.parent )	window.close();
		else location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#returnObjectID#';
	</script></cfoutput>

</cfif>                                                                                
<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">

<cfsetting enablecfoutputonly="No">