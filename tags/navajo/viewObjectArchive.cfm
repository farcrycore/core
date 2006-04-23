<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfsetting enablecfoutputonly="No">

<cfset archiveTypename = "dmArchive">  





<cfoutput>
<HTML lang="en">
	
<HEAD>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/includes/dynamicData.css">  	
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/includes/default.css">  
</head>

<body leftmargin="0" topmargin="0" rightmargin="0" marginwidth="0" marginheight="0">

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



<cfscript>
	sql = "select * from #archiveTypename# where archiveID = '#attributes.objectID#' order by datetimecreated DESC";
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
<form action="" method="post">
<table width="100%" cellspacing="1">
	<tr>
		<td background="#application.url.farcry#/navajo/nimages/dialogbanner.gif" width="100%">
			<strong>Archived Objects For - #attributes.objectID#</strong>
		</td>
	</tr>
	<cfif isDefined("msg")>
	<tr>
		<td  align="center">
			<strong>#msg#</strong>
		</td>
	</tr>	
	</cfif>
	<tr>
		<td>
		<table width="100%" cellspacing="0">
			<tr>
				
				<td class="tableHeader" align="right" valign="middle">
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
			<table width="100%" border="0" cellspacing="1" bgcolor="##999999">
        <tr> 
          <td class="rowsHeader"></td>
          <td class="rowsHeader"> View </td>
          <td class="rowsHeader"> Label </td>
          <td class="rowsHeader"> Archive Date </td>
          <td class="rowsHeader"> By </td>
        </tr></cfoutput>
		<cfif recordSet.recordCount EQ 0 >
		<cfoutput>
		<tr>
			<td class="rows" colspan="5" align="center">
				<strong>No archived records recovered</strong>
			</td>	
		</tr>
		</cfoutput>
		<cfelse>
		<cfoutput query="recordSet" startrow="#startRow#" maxrows="#numRecords#"> 
		<cfscript>
			
			previewURL = "#application.url.farcry#/navajo/displayArchive.cfm?objectID=#objectID#";
		</cfscript>
          <tr> 
            <td class="rows"> 
				<input type="checkbox" name="objectID" value="#objectID#"> 
            </td>
            <td class="rows" align="center"> 
              <a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/navajo/nimages/preview.gif"></a> 
            </td>
            <td class="rows"> 
	             <a href="#previewURL#">#label#</a>
			</td>
            <td class="rows"> 
              #dateFormat(dateTimeCreated,"dd-mmm-yyyy")#
			</td>
            <td class="rows"> 
              #lastUpdatedBy# 
			 </td>
          </tr>
        </cfoutput>
		</cfif>
		<cfoutput> </table>
		</td>	
	</tr>
<!--- 	<tr>
		<td>
			<table class="BorderTable">
			<tr>
				<td nowrap valign="top">
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Create" reference1="PolicyGroup" r_iState="iObjectCreatePermission">
						<cfif iObjectCreatePermission eq 1>
						<input type="button" value="Add" width="100" style="width:100;" class="normalbttnstyle"  onClick="window.location='#application.url.farcry#/navajo/CreateObject.cfm?typeid=#attributes.typeid#';">
						
					</cfif>
				</td>
				<!--- delete object(s)	 --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Delete" reference1="PolicyGroup" r_iState="iObjectDeletePermission">
				<cfif iObjectDeletePermission eq 1>
				<td>
					<input type="submit" name="delete" value="Delete" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmDelete());">					
				</td>
				</cfif>
				<!--- Set status to pending 	 --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#RequestApproval" reference1="PolicyGroup" r_iState="iObjectRequestApprovalPermission">
				<cfif iObjectRequestApprovalPermission eq 1>
				<td>
					<input type="submit" name="status" value="Request Approval" width="100" style="width:100;" class="normalbttnstyle"  onClick="return(confirmApprove(pending));">					
				</td>
				</cfif>
				<!--- set status to approved/draft --->
				<cf_dmSec_PermissionCheck permissionName="#attributes.permissionType#Approve" reference1="PolicyGroup" r_iState="iObjectApprovePermission">
				<cfif iObjectApprovePermission eq 1>
				<td>
					<input type="submit" name="status" value="Approve" width="100" style="width:100;" class="normalbttnstyle"  onClick="confirmApprove(approve);">
				</td>
				<td>
					<input type="button" name="status" value="Decline" width="100" style="width:100;" class="normalbttnstyle"  onClick="confirmApprove(draft);">
				</td>
				
				
				</cfif>
					
			</tr>
			</form>
			</table>			
		</td> 
	</tr>
 ---></table>
</cfoutput>	

