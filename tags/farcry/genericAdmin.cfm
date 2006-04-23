<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/genericAdmin.cfm,v 1.14 2003/07/15 07:58:59 brendan Exp $
$Author: brendan $
$Date: 2003/07/15 07:58:59 $
$Name: b131 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: generic admin for all types. If there is a display method called "display" on the type, it can be previewed.... $
$TODO: hoowah -- this is a nasty piece of business that needs cleaning up...GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (paul@daemon.com.au) $

|| ATTRIBUTES ||
$in: [defaultstatus]: optional, default = pending. what is the default status of the object to show up as? $
$in: [header]: optional, default = true. do you want to display the header / footer? $
$in: [user]: optional, a filter by user. $
$in: [metadata]: optional, default = false. show metadata filter? $
$in: [add]: optional, default = false. Allow users to add/delete objects? $
$in: [style]: optional, stStyle to pass into the datasheet $
$in: [admintype]: required, title for the type of admin. $
$in: [typeid]: required, typeid for the type to be administered $
$in: [approve]: optional, default = true, can this person approve? $
--->
<cfsetting enablecfoutputonly="No">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<cfparam name="attributes.typename" type="string">
<Cfparam name="url.module" default="">


<cfoutput>
<HTML lang="en">
	
<head>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css">  	
</head>

<body>

<script>
function confirmDelete(){
	var msg = "Are you sure you wish to delete this item(s) ?";
	if (confirm(msg))
		return true;
	else
		return false;
}				
function confirmApprove(action){
	var msg = "Are you sure you wish to change these objects status to " + action;
	if (confirm(msg))
		return true;
	else
		return false;
}				

</script>

</cfoutput>

<!--- delete multiple objects --->
<cfif isDefined("form.delete")>
	<cfif isDefined("form.objectID")>
		<cfinvoke component="#application.packagepath#.farcry.genericAdmin" method="deleteObjects" returnvariable="msg">
			<cfinvokeargument name="typename" value="#attributes.typename#"/>
			<cfinvokeargument name="lObjectIDs" value="#form.objectID#"/>
		</cfinvoke>
	<cfelse>
		<cfset msg = "No objects were selected for deletion">	
	</cfif>
</cfif>

<!--- change status of objects --->
<cfif isDefined("form.status")>
	<cfif isDefined("form.objectID")>
		<cfscript>
			if (form.status contains "Approve")
				status = 'approved';
			else if (form.status contains "Send to Draft")
				status = 'draft'; 	
			else if (form.status contains 'Request')
				status = 'requestApproval';
			else
				status = 'unknown';
		</cfscript>
		<!--- custom tag to add user comments --->
		<cflocation url="#application.url.farcry#/navajo/objectComment.cfm?status=#status#&objectID=#form.objectID#" addtoken="no">
				
	<cfelse>
		<cfset msg = "No objects were selected for this operation">			
	</cfif>
</cfif>

<!--- dump objects --->
<cfif isdefined("form.dump")>
	<cf_dump lObjectIds = "#form.objectid#">
</cfif>

<cfparam name="attributes.header" default="true"><!--- show the header? you may wish to embed this. --->
<cfparam name="attributes.user" default=""><!--- set this to a specific user and it will only get stuff that they created. --->
<cfparam name="attributes.defaultstatus" default="All">
<cfparam name="attributes.currentstatus" default="All">
<cfparam name="attributes.metadata" default="false"><!--- --->
<cfparam name="attributes.permissionType"><!--- --->
<cfparam name="FORM.currentStatus" default="All"> 
<cfparam name="url.order" default="datetimecreated">
<cfparam name="url.direction" default="desc">


<cfparam name="url.pgno" default="1">
<cfif isdefined("url.status")>
	<cfset form.currentStatus = url.status>
</cfif>

<Cfset attributes.defaultstatus = FORM.currentStatus>

 
<!--- get categories --->
<cfif attributes.metadata>
	<cflock timeout="45" throwontimeout="Yes" type="READONLY" scope="SESSION">
		<cfif isDefined("session.cats")>
			<cfset cats = session.cats>
		<cfelse>	
			<cfset cats = "">
		</cfif>
	</cflock>
</cfif>

<!--- get objects to display --->
<cfinvoke component="#application.packagepath#.farcry.genericAdmin" method="getObjects" returnvariable="recordSet">
	<cfinvokeargument name="typename" value="#attributes.typename#"/>
	<cfinvokeargument name="status" value="#form.currentStatus#"/>
	<cfinvokeargument name="order" value="#url.order#"/>
	<cfinvokeargument name="orderDirection" value="#url.direction#"/>
	<cfif isdefined("form.categoryid")>
		<cfinvokeargument name="lCategories" value="#form.categoryID#"/>
	</cfif>
</cfinvoke>

<cfparam name="FORM.thisPage" default="1">
<cfscript>
	numRecords = 30;
	thisPage = FORM.thisPage;
	if (recordSet.recordCount GT 0)
	{
		startRow = ((thisPage*numRecords) + 1) - numRecords; //the query row which we start from
		numPages = recordSet.recordcount/numRecords;
		numPages = ceiling(numPages); // the number of 'pages' of results
		if (thisPage GT 1){
			prevPage = thisPage - 1; 
		}	//the next page to advance to  
		if (thisPage LT numPages){
			nextPage = thisPage + 1;
		}	 // the previous page to go back to	
	}else
	{	numpages = 1;
		thispage = 1;
	}
</cfscript>

<cfset comment = false>

<cfoutput>

<div class="FormTitle">Administering #attributes.typename# objects</div>
<form action="" method="post" name="dynamicAdmin">
<div class="FormTableClear" style="margin-left:0;">
Status of #attributes.admintype# Object &nbsp; <select class="text-cellheader" name="currentStatus" onChange="this.form.submit();">
				<option value="draft" <cfif FORM.currentStatus IS "draft">selected</cfif>>draft
				<option value="pending" <cfif FORM.currentStatus IS "pending">selected</cfif>>pending
				<option value="approved" <cfif FORM.currentStatus IS "approved">selected</cfif>>approved
				<option value="declined" <cfif FORM.currentStatus IS "declined">selected</cfif>>declined
				<option value="All" <cfif FORM.currentStatus IS "all">selected</cfif>>All
			</select>
</div>
<cfif isDefined("msg")>
<div class="FormTableClear" style="margin-left:0;">
	<strong>#msg#</strong>
</div>
</cfif>

<table width="100%" cellspacing="1"> 
	<tr>
		<td>
		<table width="90%" cellspacing="0">
			<tr>
				<td>#recordSet.recordcount# items</td>
				<td align="right" valign="middle">
					<cfif thisPage GT 1>
						<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="prev" name="prev"  onclick="this.form.thisPage.selectedIndex--;this.form.submit();" >
					</cfif>
					Page 
					<select name="thisPage" onChange="this.form.submit();">
						<cfloop from="1" to="#numPages#" index="i">
							<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
						</cfloop>
					</select> of #numPages#
					<cfif thisPage LT numpages>
						<input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="next" onclick="this.form.thisPage.selectedIndex++;this.form.submit();">
					</cfif>
				</td>
			</tr>		
		</table>
		</td>
	</tr>
<!--- 	</form>
	<form name="actionForm" action="" method="post"> --->
	<tr>
		<td>
			<table cellpadding="5" cellspacing="0" border="1" width="90%">
			<tr class="dataheader">
				<td >&nbsp;</td>
				<td align="center"> Edit </td>
				<td align="center"> View </td>
				<td align="center"> Stats </td>
				<td align="center"> <a href="#cgi.SCRIPT_NAME#?typename=#attributes.typename#&module=#url.module#&order=label&direction=asc" style="color:white">Label</a> </td>
				<td align="center"> <a href="#cgi.SCRIPT_NAME#?typename=#attributes.typename#&module=#url.module#&order=status&direction=asc" style="color:white">Status</a> </td>
				<cfif structKeyExists(application.types['#attributes.typename#'].stProps,"publishDate")>
					<td align="center"> <a href="#cgi.SCRIPT_NAME#?typename=#attributes.typename#&module=#url.module#&order=publishDate&direction=desc" style="color:white">Publish Date</a> </td>
				</cfif>
				<td align="center"> <a href="#cgi.SCRIPT_NAME#?typename=#attributes.typename#&module=#url.module#&order=dateTimeLastUpdated&direction=desc" style="color:white">Last Updated</a> </td>
				<td align="center"> <a href="#cgi.SCRIPT_NAME#?typename=#attributes.typename#&module=#url.module#&order=createdby&direction=asc" style="color:white">By</a> </td>
			</tr>
         </cfoutput>
		<cfif recordSet.recordCount EQ 0 >
			<cfoutput>
			<tr>
				<td colspan="8" align="center">
					<strong>No records recovered</strong>
				</td>	
			</tr>
			</cfoutput>
		<cfelse>
			<cfoutput query="recordSet" startrow="#startRow#" maxrows="#numRecords#"> 
			<cfscript>
				finishURL = URLEncodedFormat("#application.url.farcry#/navajo/GenericAdmin&type=news");
				editObjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=#objectID#&finishUrl=#finishURL#&type=#attributes.typename#";
				previewURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1";
			</cfscript>
			  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#"> 
				<td align="center"><input type="checkbox" name="objectID" value="#objectID#"></td>
				<td align="center">
					<!--- check if object is locked --->
					<cfif locked and lockedby neq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
						<span style="color:red">Locked</span>
						<cfset locked = true>
					<cfelse>
						<a href="#editObjectURL#"><img src="#application.url.farcry#/images/treeImages/edit.gif" border="0"></a>
					</cfif>
				</td>
				<td align="center"><a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/images/treeImages/preview.gif" border="0"></a></td>
				<td align="center"><a href="##" onClick="window.open('#application.url.farcry#/editTabStats.cfm?objectid=#objectid#','Stats','scrollbars,height=600,width=620');"><img src="#application.url.farcry#/images/treeImages/stats.gif" border="0"></a></td>
				<td>
					<!--- check if object is locked --->
					<cfif locked and lockedby neq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
						#label#
					<cfelse>
						<a href="#editObjectURL#">#label#</a>
					</cfif>
				</td>
				<td align="center">#status#</td>
				<cfif structKeyExists(application.types['#attributes.typename#'].stProps,"publishDate")>
					<td align="center">#dateFormat(publishDate,"dd-mmm-yyyy")#</td>
				</cfif>	
				<td align="center">#dateFormat(dateTimeLastUpdated,"dd-mmm-yyyy")#</td>
				<td><cfif lastUpdatedBy neq "">#lastUpdatedBy#<cfelse>#createdby#</cfif></td>
			  </tr>
			</cfoutput>
		</cfif>
		<cfoutput> </table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
			<table class="BorderTable">
			<tr>
				<td nowrap valign="top">
				<!--- get permissions  --->
				<cfscript>
					oAuthorisation = request.dmSec.oAuthorisation;
					iObjectCreatePermission = oAuthorisation.checkPermission(permissionName="#attributes.permissionType#Create",reference="PolicyGroup");
					iObjectDeletePermission = oAuthorisation.checkPermission(permissionName="#attributes.permissionType#Delete",reference="PolicyGroup");
					iObjectRequestApprovalPermission = oAuthorisation.checkPermission(permissionName="#attributes.permissionType#RequestApproval",reference="PolicyGroup");
					iObjectApprovePermission = oAuthorisation.checkPermission(permissionName="#attributes.permissionType#Approve",reference="PolicyGroup");
					iObjectDumpTab = oAuthorisation.checkPermission(permissionName="ObjectDumpTab",reference="PolicyGroup");
				</cfscript>
				<cfif iObjectCreatePermission eq 1 eq 1>
					<input type="button" value="Add" width="100" style="width:100;" class="normalbttnstyle"  onClick="window.location='#application.url.farcry#/navajo/createObject.cfm?typename=#attributes.typename#';">
				</cfif>
				</td>
				<!--- delete object(s)	 --->
				<cfif iObjectDeletePermission eq 1 eq 1>
				<td>
					<input type="submit" name="delete" value="Delete" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmDelete('delete'));">					
				</td>
				</cfif>
				<!--- Set status to pending --->
				<cfif iObjectRequestApprovalPermission eq 1>
				<td>
					<input type="submit" name="status" value="Request Approval" width="100" style="width:100;" class="normalbttnstyle">					
				</td>
				</cfif>
				<!--- set status to approved/draft --->
				<cfif iObjectApprovePermission eq 1>
				<td>
					<input type="submit" name="status" value="Approve" width="100" style="width:100;" class="normalbttnstyle">
				</td>
				<td>
					<input type="submit" name="status" value="Send to Draft" width="100" style="width:100;" class="normalbttnstyle">
				</td>
				</cfif>
				<!--- dump objects  --->
				<cfif iObjectDumpTab eq 1>
				<td>
					<input type="submit" name="dump" value="Dump" width="100" style="width:100;" class="normalbttnstyle">
				</td>
				</cfif>
				<!--- check if there are locked objects --->
				<cfif isdefined("locked")>
				<td>
					<input type="submit" name="unlock" value="Unlock" width="100" style="width:100;" class="normalbttnstyle"  onClick="dynamicAdmin.action='#application.url.farcry#/unlock.cfm?typename=#attributes.typename#';">					
				</td>
				</cfif>	
			</tr>
			<tr><td>&nbsp;</td></tr>					
			</table>
			<!--- Determine whether or not the metadata layer is to be displayed or not --->
			<cfparam name="isClosed" default="Yes">
			<cfif isDefined("form.categoryid") OR isDefined("form.apply")>
				<cfset isClosed = "No">
			</cfif>
			<display:OpenLayer width="400" title="Restrict By Categories" isClosed="#isClosed#" border="no">
			<table id="tree">
				<tr>
					<td>
					<cfparam name="form.categoryid" default="">
					<cfinvoke component="#application.packagepath#.farcry.category" method="displayTree" bShowCheckBox="true" objectID="#createUUID()#" lSelectedCategories="#form.categoryid#"/>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td align="center"><input type="Submit" value="Restrict" class="normalbttnstyle"></td>
				</tr>
			</table>
			</display:OpenLayer>			
			</form>		
		</td> 
	</tr>
</table>
</cfoutput>	
