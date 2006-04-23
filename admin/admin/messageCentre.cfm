<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/messageCentre.cfm,v 1.5 2003/12/08 00:20:22 brendan Exp $
$Author: brendan $
$Date: 2003/12/08 00:20:22 $
$Name: milestone_2-2-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Message Centre $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>

	<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">
	
	<cfparam name="stargs.typename" default="dmEmail">
	
	<cffunction name="getAllObjects">
		<cfquery name="q" datasource="#application.dsn#">
			SELECT * FROM #stArgs.typename#
		</cfquery>
		<cfreturn q>
	</cffunction>
	
	
	
	<cfoutput>
	
	<script>
	function editObject(objectID)
	{
		document.dynamicAdmin.objectid = objectID;
	}	
	
	function confirmDelete(objectID){
		var msg = "Are you sure you wish to delete this item(s) ?";
		if (confirm(msg))
		{	
			return true;
		}	
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
	
	
	<cfif isDefined("form.add")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			objectID = o.create();
			o.edit(objectid=objectid);
		</cfscript>
	
	</cfif>
	
	<cfif isDefined("form.edit")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			o.edit(objectid=form.objectid);
		</cfscript>
	</cfif>
	
	<cfif isDefined("form.delete")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			o.delete(objectid=form.objectid);
		</cfscript>
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
	
	
	<cfparam name="FORM.currentStatus" default="All"> 
	<cfparam name="url.order" default="datetimecreated">
	<cfparam name="url.direction" default="desc">
	
	
	<cfparam name="url.pgno" default="1">
	<cfif isdefined("url.status")>
		<cfset form.currentStatus = url.status>
	</cfif>
	
	<!--- get objects to display --->
	<cfinvoke component="#application.types.dmEmail.typePath#" method="getAllObjects" returnvariable="recordSet">
	
	<cfparam name="FORM.thisPage" default="1">
	<cfscript>
		numRecords = application.config.general.genericAdminNumItems;
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
					<form action="" method="post" name="dynamicAdmin">
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
						<cfif isDefined("form.fieldnames")>
						<cfloop list="#form.fieldnames#" index="element">
							<cfif NOT element IS "thisPage">
							<input type="Hidden" name="#element#" value="#evaluate('form.'&element)#">
							</cfif>
						</cfloop>
						</cfif>
						</form>
					</td>
				</tr>		
			</table>
			</td>
		</tr>
	
		<tr>
			<td>
				<table cellpadding="5" cellspacing="0" border="1" width="90%">
				<tr class="dataheader">
					<td align="center"> Subject </td>
					<td align="center"> Edit </td>
					<td align="center"> Preview </td>
					<td align="center"> Send </td>
					<td align="center"> Delete </td>
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
					finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#");
					editObjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=#objectID#&finishUrl=#finishURL#&type=#stArgs.typename#";
					previewURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1";
				</cfscript>
				  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#"> 
					<td align="center">#title#</td>
					<td align="center">
						<form action="" method="post" name="form_#recordset.objectid#">
						<input type="hidden" name="objectid" value="#recordset.objectid#">
						<input type="button" name="edit" value="Edit" onClick="location.href='#editObjectURL#';">
					</td>
					<td align="center">
						<input type="button" name="preview" value="Preview" onClick="window.open('#previewURL#');">
					</td>
					<td align="center">
						<cfif bSent>
							Sent
						<cfelse>
							<input type="button" name="send" value="Send" onClick="location.href='#application.url.farcry#/admin/messageSend.cfm?objectid=#objectid#';">	
						</cfif>
						
					</td>
					<td align="center">
						<input type="submit" name="delete" value="Delete" onClick="return confirmDelete('#recordset.objectid#')">
						</form>
					</td>
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
						<form action="" method="post">
						<cfset finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#")>
						<input type="button" value="Add" width="100" style="width:100;" class="normalbttnstyle" name="add" onClick="window.location='#application.url.farcry#/navajo/createObject.cfm?typename=#stArgs.typename#&finishURL=#finishURL#';" >
						</form>					
					</td>
					</tr>
				<tr><td>&nbsp;</td></tr>					
				</table>
				</form>		
			</td> 
		</tr>
	</table>
	</cfoutput>	

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">