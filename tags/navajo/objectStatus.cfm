<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/objectStatus.cfm,v 1.47.2.5 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name:  $
$Revision: 1.47.2.5 $

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
 
<cfparam name="url.objectId">
<cfparam name="url.status" default="0">
<cfparam name="attributes.lObjectIDs" default="#url.objectId#">


<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header>

<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

<cfset changestatus = true>

<!--- show comment form --->
<cfif not isdefined("form.commentLog") and listlen(attributes.lObjectIDs) eq 1>
	<!--- get object details --->
	<q4:contentobjectget objectid="#attributes.lobjectIDs#" r_stobject="stObj">

	<cfif isdefined("stObj.status")><cfoutput>
<script type="text/javascript">	
function deSelectAll()
{
	if(document.form.lApprovers[0].checked = true){
		for(var i = 1;i < document.form.lApprovers.length;i++)
			document.form.lApprovers[i].checked = false;
	}
	return true;
}
</script>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="form" method="post">
<h3><cfif isDefined("URL.draftObjectID")>#application.adminBundle[session.dmProfile.locale].objStatusRequest#<cfelse>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].setObjStatus,"#url.status#")#</cfif></h3>
	<fieldset>
		<label for="commentLog"><b>#application.adminBundle[session.dmProfile.locale].addCommentsLabel#</b>
			<textarea name="commentLog" id="commentLog" cols="80" rows="10"></textarea><br />
		</label>
	</fieldset>

	<div class="f-submit-wrap">
	<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].submitUC#" class="f-submit" />
	<input type="submit" name="cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit" onClick="location.href='../edittabOverview.cfm?objectid=#attributes.lobjectIDs#';" />
	</div>			

			<!--- display existing comments --->
			<cfif structKeyExists(stObj,"commentLog")>
				<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
					<label><b>#application.adminBundle[session.dmProfile.locale].previousComments#</b>
						#htmlcodeformat(stObj.commentLog)#
					</label>
				</cfif>
			</cfif>
		</form>
		</cfoutput>
		<cfset changestatus = false>
	</cfif>
</cfif>

<cfif changestatus eq true>
	<cfflush>

	<cfif isDefined("form.submit")> <!--- check that they hit submit --->
		<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">
			<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
			
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#stObj.objectid#" returnvariable="stRules">

			<cfif not structkeyexists(stObj, "status")>
				<cfoutput>
				<script type="text/javascript">
					alert("#application.adminBundle[session.dmProfile.locale].objNoApprovalProcess#");
					window.close();
				</script>
				</cfoutput>
				<cfabort>
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

				<!--- 
				// Set Friendly URL 
				 - TODO: this is going to cause issues if the approval process fails or is not confirmed GB20060123
				--->
				<!--- versioned objects use parent live object for fu --->
				<cfif StructKeyExists(stObj,"versionid") AND len(stobj.versionid)>
					<cfset fuoid=stobj.versionid>
				<!--- use objectid if no versionid --->
				<cfelse>
					<cfset fuoid=stobj.objectid>
				</cfif>
				
				<!--- make sure objectid is not specifically excluded from FU --->
				<cfset bExclude = 0>
				<cfif ListFindNoCase(application.config.fusettings.lExcludeObjectIDs,fuoid)>
					<cfset bExclude = 1>
				</cfif>
				
				<!--- make sure content type requires friendly url --->
				<cfif NOT StructKeyExists(application.types[stObj.typename],"bFriendly") OR NOT application.types[stObj.typename].bFriendly>
					<cfset bExclude = 1>
				</cfif> 
				
				<!--- set friendly url --->
				<cfif NOT bExclude>
					<cfset objTypes = CreateObject("component","#application.types[stObj.typename].typepath#")>
					<cfset stresult_friendly = objTypes.setFriendlyURL(objectid=fuoid)>
				</cfif>

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
				<cfoutput><b>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].unknownStatusPassed,"#url.status#")#<b><br></cfoutput><cfabort>
			</cfif>
	
			<cfif isstruct(stNav)>
				<cfscript>
					for(x = 1;x LTE listLen(permission);x=x+1)
					{
						iState = application.security.checkPermission(permission=listGetAt(permission,x),object=stNav.objectId);	
						if(listGetAt(permission,x) IS "canApproveOwnContent" AND iState EQ 1 AND NOT stObj.lastUpdatedBy IS application.security.getCurrentUserID())
							iState = 0;
						if(iState EQ 1)
							break;
					}	
				</cfscript>
				
				<cfif iState neq 1><cfoutput>
					<script type="text/javascript">
						alert("#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].nosubNodeApprovalPermission,"#stNav.title#")#");
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
						<cfif session.security.userid eq stObj.attr_lastUpdatedBy><cfoutput>
							<script type="text/javascript">
								alert("#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].canApproveOwnContent,stNav.title)#");
								window.close();
							</script></cfoutput><cfabort>
						</cfif>
					<cfelse><cfoutput>
						<script type="text/javascript">
							alert("#application.adminBundle[session.dmProfile.locale].notLoggedIn#");
							window.close();
						</script></cfoutput><cfabort>
					</cfif>
					
				</cfif>
			</cfif>
			<!--- Call this to get all descendants of this node --->
	
			<!--- If we are approving the whole branch - then we will be wanting all objectIDS --->
			<cfif isDefined("URL.approveBranch")>
				<cfset keyList = attributes.objectID>
				<cfif stObj.typename EQ "dmNavigation">
					<cfif isArray(stObj.aObjectIds)>
						<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
					</cfif>
				</cfif>
				<cfscript>
					qGetDescendants = application.factory.oTree.getDescendants(objectid=attributes.objectID);
				</cfscript>
							
				<cfset keyList = listAppend(keyList,valueList(qGetDescendants.objectId))>
				<cfloop query="qGetDescendants">
					<q4:contentobjectget objectId="#qGetDescendants.objectId#" r_stObject="stThisObj">
					<cfif stObj.typename EQ "dmNavigation">
						<cfif isArray(stThisObj.aObjectIds)>
							<cfset keyList = listAppend(keyList,arrayToList(stThisObj.aObjectIds))>
						</cfif>	
					</cfif>
				</cfloop>
			<cfelse>  <!--- else - just get the objectIDS in this nodes aObjects array --->
				<cfif isDefined("URL.draftObjectID")>
					<cfset keyList = URL.draftObjectID>
				<cfelse>	
					<cfset keyList = attributes.objectID>
				</cfif>	
				<cfif stObj.typename EQ "dmNavigation">
					<cfif isdefined("stObj.aObjectIds") and isArray(stObj.aObjectIds)>
						<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
					</cfif>
				</cfif>
			</cfif>
									
			<cfoutput>Changing status....<br></cfoutput>
			<cfflush>
			
			<!--- update the structure data for object update --->
			<cfloop list="#keyList#" index="key">
				<q4:contentobjectget objectId="#key#" r_stObject="stObj">
				<cfif NOT structIsEmpty(stObj)>
					<cfif stObj.label NEQ "(incomplete)"> <!--- incompletet items check .: dont send incomplete items live --->
						
						
						<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#key#" returnvariable="stRules">
						
						<!--- If the user is trying to approve or request approval an approved object, we will assume they are trying to change the status the draft object if there is one. --->
						<cfif (url.status eq "approved" OR url.status eq "requestApproval") AND stobj.status EQ "approved" and stRules.bDraftVersionExists AND len(stRules.draftobjectID)>
							<q4:contentobjectget objectId="#stRules.draftobjectID#" r_stObject="stObj">
							<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#stObj.objectid#" returnvariable="stRules">
						</cfif>
						
						<!--- prepare date fields --->
						<cfloop collection="#stObj#" item="field">
							<cfif StructKeyExists(application.types[stObj.typeName].stProps, field) AND application.types[stObj.typeName].stProps[field].metaData.type EQ "date">
								<cfif IsDate(stObj[field])>
									<cfset stObj[field] = CreateODBCDateTime(stObj[field])>
								<cfelse>
									<cfset tempdate = CreateDate(year(Now()),month(Now()),day(Now()))>
									<cfset stObj[field] = CreateODBCDateTime(tempdate)>
								</cfif>
							</cfif>
						</cfloop>
						
						<cfscript>
							stObj.datetimelastupdated = createODBCDateTime(now());
			
							//only if the comment log exists - do we actually append the entry
							if (isDefined("FORM.commentLog")) {
								if (structkeyexists(stObj, "commentLog")){
									buildLog =  "#chr(13)##chr(10)##session.dmSec.authentication.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)#     Status changed: #stobj.status# -> #status##chr(13)##chr(10)# #FORM.commentLog#";
									stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
									}
							}
							stObj.status = status;	
						</cfscript>
						

	
	<!--- 
						<cfif stRules.bLiveVersionExists and url.status eq "approved">
							 <!--- Then we want to swap live/draft and archive current live --->
							<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#key#"  stDraftObject="#stObj#" returnvariable="stRules">
							<cfset returnObjectID=stObj.objectid>
						<cfelse>
							
							<cfset oType = createobject("component", application.types[stObj.typename].typePath) />
							
							<!--- Delete the current draft object if one exists. --->
							<cfif stRules.bDraftVersionExists and len(stRules.draftObjectID)>
								<cfset stResult = oType.delete(objectid=stRules.draftObjectID) />
							</cfif>
							
							<!--- a normal page, no underlying object --->
							<cfset oType.setData(stProperties=stObj,auditNote="Status changed to #stObj.status#") />
							
							<cfif stObj.typename neq "dmImage" and stObj.typename neq "dmFile">
								<cfset returnObjectId = url.objectid>
							</cfif>
						</cfif>
						 --->
						

						
						
						<!---  <cfdump var="#stobj#" expand="false" label="stobj" />
						<cfdump var="#stRules#" expand="false" label="stRules" />
						<cfabort showerror="debugging" />	 --->
						<cfif stRules.bLiveVersionExists and url.status eq "approved">
							 <!--- Then we want to swap live/draft and archive current live --->
							<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#stObj.objectid#"  stDraftObject="#stObj#" returnvariable="stRules">
							<cfset returnObjectID=stObj.objectid>
						<cfelse>
							<!--- a normal page, no underlying object --->
							<cfscript>
								oType = createobject("component", application.types[stObj.typename].typePath);
								oType.setData(stProperties=stObj,auditNote="Status changed to #stObj.status#");
							</cfscript>
							
							<cfif stObj.typename neq "dmImage" and stObj.typename neq "dmFile">
								<cfset returnObjectId = url.objectid>
							</cfif>
						</cfif>
						
					</cfif> <!--- // incomplete items check  --->
				
				
		
				
				
				
				</cfif>
			</cfloop>
		</cfloop>

		<cfif isstruct(stNav)>
			<nj:updateTree ObjectId="#stNav.objectId#">
		</cfif>
	</cfif><!--- // check that they hit submit --->

	<cfparam name="returnObjectId" default="#url.objectId#"><cfoutput>
<script type="text/javascript">
if(window.opener && window.opener.parent)
	window.close();
else{
	//if(parent['sidebar'].frames['sideTree'])
	location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#returnObjectId#";
}
</script></cfoutput>
</cfif>                                                                                
<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">