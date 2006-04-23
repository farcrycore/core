

<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/tags/display/" prefix="display">

<cfsetting enablecfoutputonly="No">


<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/Attic/genericAdmin.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 
generic admin for all types

|| USAGE ||
If there is a display method called "display" on the type, it can be previewed....

|| PRIMARY DEVELOPER ||
Aaron Shurmer (aaron@daemon.com.au)

|| MODIFICATIONS ||

|| ATTRIBUTES ||
-> [defaultstatus]: optional, default = pending. what is the default status of the object to show up as?
-> [header]: optional, default = true. do you want to display the header / footer?
-> [user]: optional, a filter by user.
-> [metadata]: optional, default = false. show metadata filter?
-> [add]: optional, default = false. Allow users to add/delete objects?
-> [style]: optional, stStyle to pass into the datasheet
-> [admintype]: required, title for the type of admin.
-> [typeid]: required, typeid for the type to be administered
-> [approve]: optional, default = true, can this person approve?

|| HISTORY ||
$Log: genericAdmin.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.20  2002/09/25 05:28:37  geoff
no message

Revision 1.19  2002/09/24 22:49:45  geoff
no message

Revision 1.18  2002/09/24 05:33:30  geoff
no message

Revision 1.17  2002/09/18 05:05:58  geoff
no message

Revision 1.16  2002/09/18 04:33:04  geoff
no message

Revision 1.15  2002/09/18 03:42:35  geoff
no message

Revision 1.14  2002/09/18 03:41:14  geoff
no message

Revision 1.13  2002/09/18 01:03:28  geoff
no message

Revision 1.12  2002/09/12 02:41:57  geoff
no message



|| END FUSEDOC ||
--->
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
		<nj:deleteObjects lObjectIDs="#form.objectID#" typename="#attributes.typename#" rMsg="msg">
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
			else if (form.status contains "Decline")
				status = 'draft'; 	
			else if (form.status contains 'Request')
				status = 'requestApproval';
			else
				status = 'unknown';
		</cfscript>
		
		<nj:objectStatus_dd lObjectIDs="#form.objectID#" status="#status#" rMsg="msg">		
	<cfelse>
		<cfset msg = "No objects were selected for this operation">			
	</cfif>
</cfif>



<!--- TODO?? This is not a generic solution - so for the time being don't have to
dynamically check this stuff - we know whether comments/status exists or not
 --->
 
<!--- cfif structKeyExists(stType.STTYPEPROPERTYDEFINITIONS,"status")>
	<cfset hasStatus=1>
<cfelse>
	<Cfset hasStatus=0>
</cfif>

<cfif structKeyExists(stType.STTYPEPROPERTYDEFINITIONS,"commentLog")>
	<cfset hasComments=1>
<cfelse>
	<Cfset hasComments=0>
</cfif>
 --->

<cfparam name="attributes.header" default="true"><!--- show the header? you may wish to embed this. --->
<cfparam name="attributes.user" default=""><!--- set this to a specific user and it will only get stuff that they created. --->
<cfparam name="attributes.defaultstatus" default="All">
<cfparam name="attributes.currentstatus" default="All">
<cfparam name="attributes.metadata" default="false"><!--- --->
<cfparam name="attributes.permissionType"><!--- --->
<cfparam name="FORM.currentStatus" default="All"> 


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

<cfscript>
	if (isDefined("form.apply") AND isDefined("form.categoryID")){
		sql = "select type.*
				from refObjects refObj 
				join refCategories refCat ON refObj.objectID = refCat.objectID
				join #attributes.typename# type ON refObj.objectID = type.objectID  
				where refObj.typename = '#attributes.typename#' AND refCat.categoryID IN ('#ListChangeDelims(form.categoryID,"','",",")#') ";
		if (FORM.currentStatus IS "all")
			sql = sql & "AND type.status IN ('draft','approved','declined','pending')"; 
		else
			sql = sql & "type.status = '#form.currentStatus#'";			
	}
	else
	{
		sql = "select * from #attributes.typename# where ";
		if (FORM.currentStatus IS "all")
			sql = sql & "status IN ('draft','approved','declined','pending')"; 
		else
			sql = sql & "status = '#form.currentStatus#'";	
	}		
</cfscript>

<cfquery datasource="#application.dsn#" name="recordSet">
	#preserveSingleQuotes(sql)#
</cfquery>
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

<div class="FormTitle">Administering #attributes.admintype# objects</div>
<form action="" method="post">
<div class="FormTableClear" style="margin-left:0;">
Status of News Object &nbsp; <select class="text-cellheader" name="currentStatus" onChange="this.form.submit();">
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
		<table width="100%" cellspacing="0">
			<tr>
				<td>#recordSet.recordcount# items</td>
				<td align="right" valign="middle">
					<cfif thisPage GT 1>
						<input type="image" src="#application.url.farcry#/navajo/nimages/leftarrownormal.gif" value="prev" name="prev"  onclick="this.form.thisPage.selectedIndex--;this.form.submit();" >
					</cfif>
					Page 
					<select name="thisPage" onChange="this.form.submit();">
						<cfloop from="1" to="#numPages#" index="i">
							<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
						</cfloop>
					</select> of #numPages#
					<cfif thisPage LT numpages>
						<input name="next" type="image" src="#application.url.farcry#/navajo/nimages/rightarrownormal.gif" value="next" onclick="this.form.thisPage.selectedIndex++;this.form.submit();">
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
			<table cellpadding="5" cellspacing="0" border="1">
			<tr class="dataheader">
				<td >&nbsp;</td>
				<td align="center"> Edit </td>
				<td align="center"> View </td>
				<td align="center"> Label </td>
				<td align="center"> Status </td>
				<td align="center"> Publish Date </td>
				<td align="center"> Last Updated </td>
				<td align="center"> By </td>
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
				finishURL = URLEncodedFormat("#application.url.farcry#/navajo/genericAdmin&type=news");
				editObjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=#objectID#&finishUrl=#finishURL#&type=#attributes.typename#";
				previewURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1";
			</cfscript>
			  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#"> 
				<td align="center"><input type="checkbox" name="objectID" value="#objectID#"></td>
				<td align="center"><a href="#editObjectURL#"><img src="#application.url.farcry#/navajo/nimages/edit.gif" border="0"></td>
				<td align="center"><a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/navajo/nimages/preview.gif" border="0"></a></td>
				<td><a href="#editObjectURL#">#label#</a></td>
				<td align="center">#status#</td>
				<td align="center">#dateFormat(publishDate,"dd-mmm-yyyy")#</td>
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
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Create" reference1="PolicyGroup" r_iState="iObjectCreatePermission">
						<cfif iObjectCreatePermission eq 1>
						<input type="button" value="Add" width="100" style="width:100;" class="normalbttnstyle"  onClick="window.location='#application.url.farcry#/navajo/CreateObject.cfm?typename=#attributes.typename#';">
						
					</cfif>
				</td>
				<!--- delete object(s)	 --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Delete" reference1="PolicyGroup" r_iState="iObjectDeletePermission">
				<cfif iObjectDeletePermission eq 1>
				<td>
					<input type="submit" name="delete" value="Delete" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmDelete('delete'));">					
				</td>
				</cfif>
				<!--- Set status to pending 	 --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#RequestApproval" reference1="PolicyGroup" r_iState="iObjectRequestApprovalPermission">
				<cfif iObjectRequestApprovalPermission eq 1>
				<td>
					<input type="submit" name="status" value="Request Approval" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmApprove('pending'));">					
				</td>
				</cfif>
				<!--- set status to approved/draft --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Approve" reference1="PolicyGroup" r_iState="iObjectApprovePermission">
				<cfif iObjectApprovePermission eq 1>
				<td>
					<input type="submit" name="status" value="Approve" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmApprove('approve'));">
				</td>
				<td>
					<input type="submit" name="status" value="Decline" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmApprove('draft'));">
				</td>
				
				
				</cfif>
					
			</tr>
			<tr><td>&nbsp;</td></tr>					
			</table>
			<!--- Determine whether or not the metadata layer is to be displayed or not --->
			<cfparam name="isClosed" default="Yes">
			<cfif isDefined("form.displayHierarchy") OR isDefined("form.apply")>
				<cfset isClosed = "No">
			</cfif>
			<display:openlayer width="400" title="Restrict By Metadata" isClosed="#isClosed#" border="no">
			<table>
				<tr>
					<td>
	<cfinvoke component="#application.packagepath#.farcry.category" method="displayTree" objectID="#createUUID()#"/>
					
					</td>
				</tr>
			</table>
			</display:openlayer>			
			</form>		
		</td> 
	</tr>
</table>
</cfoutput>	
