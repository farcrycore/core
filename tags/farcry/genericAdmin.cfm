<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/genericAdmin.cfm,v 1.72 2005/05/24 02:59:01 gstewart Exp $
$Author: gstewart $
$Date: 2005/05/24 02:59:01 $
$Name: milestone_3-0-1 $
$Revision: 1.72 $

|| DESCRIPTION ||
$Description: generic admin for all types. If there is a display method called "display" on the type, it can be previewed.... $
$TODO:$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (paul@daemon.com.au) $

|| ATTRIBUTES ||
$in: [user]: optional, a filter by user. $
$in: [typename]: required, title for the type of admin. $
$in: [bDisplayCategories]: optional, boolean to show category tree or not $
$in: [permissionType]: required, permission check to make for access to admin $

$TODO: this is a bit half-baked.  I've added some options to make it more flexible but really needs a total overhaul GB031101 $
$in: [criteria]: optional, criteria to pass into genericadmin.getObjects() (includes CURRENTSTATUS, CUSTOMFILTER, FILTER, FILTERTYPE, ORDER, ORDERDIRECTION, SEARCHTEXT, THISPAGE) $

$TODO: the default for this is build regardless of the existence of this attribute.  Should only be built if the attribute is not specified. GB031101 $
$in: [stGrid]: optional, structure to specify grid for admin interface $

$TODO: there shouldn't be anything scoped from outside of the tag! Make this an attribute GB031101 $
--->

<cfsetting enablecfoutputonly="No">

<cfprocessingDirective pageencoding="utf-8">

<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

<!--- default general attributes --->
<cfparam name="attributes.typename" type="string">
<Cfparam name="url.module" default="">
<cfparam name="attributes.user" default=""><!--- set this to a specific user and it will only get stuff that they created. --->
<cfparam name="attributes.permissionType"><!--- --->
<cfparam name="attributes.bDisplayCategories" default="true">
<cfparam name="attributes.criteria" default="#form#">


<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	oType = createObject("component", application.types[attributes.typename].typePath);

	stTypeMetaData = getMetaData(oType);
	bDeprecated = 1;
	finished = false;
	if(structKeyExists(stTypeMetaData,'extends'))
	{
		while(NOT finished)
		{
			if (structKeyExists(stTypeMetaData,'extends') AND NOT structIsEmpty(stTypeMetaData.extends))
			{
				if(stTypeMetaData.extends.name IS 'farcry.core.packages.farcry.genericAdmin')
				{
					bDeprecated = 0;
					finished = true;
				}
				stTypeMetaData = stTypeMetaData.extends;
			}
			else
			{
				finished=true;
			}
		}
	}
	if (bDeprecated)
		oType = createObject("component","#application.packagepath#.farcry.genericAdmin");
</cfscript>


<cfscript>

	//remember to delimit dynamic expressions ##
	//This data structure is used to create the grid

	stGrid = structNew();
	//this is the url you will end back at after add/edit operations
	stGrid.finishURL = "#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#attributes.typename#";
	stGrid.typename = attributes.typename;
	stGrid.permissionType = 'news';

	stGrid.aTable = arrayNew(1);
	st = structNew();
	//select

	st.columnType = 'expression';
	st.heading = '#application.adminBundle[session.dmProfile.locale].select#';
	st.align = "center";
	st.value = "<input type=""checkbox"" name=""objectid"" value=""##recordset.objectid##"">";
	arrayAppend(stGrid.aTable,st);

	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].edit#';
	st.align = "center";
	st.columnType = 'eval';
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#&finishURL=##URLEncodedFormat(stGrid.finishURL)##";
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0""></a>'))),DE('<img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0"">'))";
	arrayAppend(stGrid.aTable,st);

	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].view#';
	st.align = "center";
	st.columnType = 'expression';
	st.value = "<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" border=""0""></a>";
	arrayAppend(stGrid.aTable,st);


	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].label#';
	st.columnType = 'eval';
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))),DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'))";
	st.align = "left";
	arrayAppend(stGrid.aTable,st);


	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#';
	st.columnType = 'eval'; //this will default to objectid of row.
	st.value = "application.thisCalendar.i18nDateFormat('##datetimelastupdated##',session.dmProfile.locale,application.mediumF)";
	st.align='center';
	arrayAppend(stGrid.aTable,st);

	if (structKeyExists(application.types[attributes.typename].stprops, "status")) {
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].status#';
	st.columnType = 'expression'; //this will default to objectid of row.
	st.value = "##status##";
	st.align = "center";
	arrayAppend(stGrid.aTable,st);
	}

	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].by#';
	st.columnType = 'expression'; //this will default to objectid of row.
	st.value = "##lastupdatedby##";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);

	

	// get permissions

</cfscript>
<cfparam name="attributes.stGrid" default="#stGrid#">
<cfset stGrid = attributes.stGrid>
<cfparam name="stGrid.aCustomButtons" default="#arrayNew(1)#"> 
<cfparam name="stgrid.permissionType" default="news">
<cfif isDefined("attributes.finishURL")>
	<cfset stGrid.finishURL = attributes.finishURL>
</cfif>
<cfif isDefined("attributes.permissionType")>
	<cfset stGrid.permissionType = attributes.permissionType>
</cfif>
<cfif isDefined("URL.approveURL")><!--- yes referring to url params in this tag bad - in here for backwards compatability --->
	<cfset stGrid.approveURL = URL.approveURL>
</cfif>
<cfif isDefined("URL.objectid")><!--- yes referring to url params in this tag bad - in here for backwards compatability --->
	<cfset form.objectid = URL.objectid>
</cfif>

<!--- dump objects --->
<cfif isdefined("form.dump")>
	<cf_dump lObjectIds = "#form.objectid#">
	<cfset structDelete(form,"objectid")>
</cfif>

<cfparam name="stGrid.submit.create.onClick" default="window.location='#application.url.farcry#/navajo/createObject.cfm?typename=#attributes.typename#';">

<cfscript>
	iObjectCreatePermission = application.security.checkPermission(permission="#stGrid.permissionType#Create");
	iObjectDeletePermission = application.security.checkPermission(permission="#stGrid.permissionType#Delete");
	iObjectRequestApprovalPermission = application.security.checkPermission(permission="#stGrid.permissionType#RequestApproval");
	iObjectApprovePermission = application.security.checkPermission(permission="#stGrid.permissionType#Approve");
	iObjectEditPermission = application.security.checkPermission(permission="#stGrid.permissionType#Edit");
	iObjectDumpTab = application.security.checkPermission(permission="ObjectDumpTab");
	iDeveloperPermission = application.security.checkPermission(permission="developer");
</cfscript>
<!--- default sort variables --->

<!--- pagination default variables --->
<cfparam name="url.pgno" default="1">
<cfparam name="FORM.thisPage" default="1">
<!--- default filter values --->

<cfscript>
//delete objects

if(isDefined("form.objectid"))
{
	o = createObject("component", application.types[attributes.typename].typePath);
	for(i=1;i LTE arrayLen(stGrid.aCustomButtons);i=i+1)
	{
		
		if(structKeyExists(form,stGrid.aCustomButtons[i].name))
		{
			evaluate("o." & stGrid.aCustomButtons[i].submitMethod & "(objectid='" & FORM.objectid & "')");
			structDelete(form,'objectid');
		}
	}
}

if (isDefined("form.unlock") AND isDefined("form.objectid"))
{
	
	aObjectids = listToArray(form.objectid);
	for(i = 1;i LTE arrayLen(aObjectids);i=i+1)
	{
		stObj = o.getData(objectid=aObjectids[i],dsn=application.dsn);

		if(stObj.locked)
		{
			permission = false;
			if (stObj.lockedby IS "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#")
			{
				permission = true;
			}
			else
			{
				if (iDeveloperPermission eq 1)
				{
					permission = true;
				}
				else
				{
					permission = false;
					msg = "#application.adminBundle[session.dmProfile.locale].noPermissionUnlockAll#";
				}
			}

			if (permission)
			{

				oLocking = createObject("component",'#application.packagepath#.farcry.locking');
				oLocking.unLock(objectid=aObjectids[i],typename=stObj.typename);
			}
		}
	}
	structDelete(form,'objectid');
}


if (isDefined("form.delete") AND isDefined("form.objectid") AND form.delete EQ 1)
{

	o = createObject("component", application.types[attributes.typename].typePath);
	aObjectids = listToArray(form.objectid);
	if(arrayLen(aObjectids))
	{
		for(i=1;i LTE arrayLen(aObjectids);i=i+1)
		{
			o.delete(objectid=aObjectIds[i]);
		}
		msg = "#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].deleted,'#arrayLen(aObjectIDs)#')#";
	}
	else
		msg = "#application.adminBundle[session.dmProfile.locale].noObjSelectedForDeletion#";
	structDelete(form,'objectid');
}

//Change status

if (isDefined("form.status"))
{
	if (isDefined("form.objectID"))
	{
		if (form.status contains application.adminBundle[session.dmProfile.locale].approve)
			status = 'approved';
		else if (form.status contains application.adminBundle[session.dmProfile.locale].sendToDraft)
			status = 'draft';
		else if (form.status contains application.adminBundle[session.dmProfile.locale].requestApproval)
			status = 'requestApproval';
		else
			status = 'unknown';
		// custom tag to add user comments
		statusurl = "#application.url.farcry#/navajo/objectComment.cfm?status=#status#&objectID=#form.objectID#&finishURL=#URLEncodedFormat(stGrid.finishURL)#";
		if (isDefined("stgrid.approveURL"))
			statusurl = statusurl & "&approveURL=#URLEncodedFormat(stGrid.approveURL)#";
		location(url=statusurl);

		structDelete(form,'objectid');
	}
	else
		msg = "#application.adminBundle[session.dmProfile.locale].noObjSelected#";
}

//get the recordset to display

recordset = oType.getObjects(dsn=application.dsn,typename=attributes.typename,criteria=attributes.criteria);

//now if restricting by category - get categorised data and perform a union with existing filtered content
if(isDefined("form.categoryid"))
{
	recordSet_restricted = oCat.getData(lcategoryids=form.categoryid,typename=attributes.typename);
	if (recordSet_restricted.recordcount) {
		sql = "select * from recordset where objectid IN (#quotedValueList(recordset_restricted.objectid)#)";
		recordset = queryofquery(sql=sql);
	}
}

// pagination
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
} else {
	numpages = 1;
	thispage = 1;
}
</cfscript>

<!--- ### display page ### --->
<cfoutput>
<!--- javascript functions --->
<script>
	function confirmDelete(){
		var msg = "#application.adminBundle[session.dmProfile.locale].confirmDeleteItem#";
		if (confirm(msg))
			return true;
		else
			return false;
	}
	function confirmApprove(action){
		var msg = "#application.adminBundle[session.dmProfile.locale].confirmObjStatusChange#" + action;
		if (confirm(msg))
			return true;
		else
			return false;
	}
</script>

<div class="FormTitle">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].adminObj,"#attributes.typename#")#</div>
<form action="" method="post" name="dynamicAdmin">
<!--- check if object uses status --->

<table width="100%" cellspacing="1">
	<!--- show number of items returned --->
	<tr>
		<td>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].items,"#recordSet.recordcount#")#</td>
	</tr>
	<tr>
		<td>
			<table width="98%" cellspacing="0">
			<tr>
				<td>
					<!--- search filter rendered here --->
					<cfscript>
						writeoutput(oType.renderSearchFields(criteria=form,typename=attributes.typename));
					</cfscript>

				</td>
				<td align="right" valign="middle">
					<!--- pagination --->
					<cfif thisPage GT 1>
						<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].prev#" name="prev"  onclick="this.form.thisPage.selectedIndex--;this.form.submit();" >
					</cfif>
					#application.adminBundle[session.dmProfile.locale].pageLC#
					<select name="thisPage" onChange="this.form.submit();">
						<cfloop from="1" to="#numPages#" index="i">
							<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
						</cfloop>
					</select> #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].pageOfPages,"#numPages#")#
					<cfif thisPage LT numpages>
						<input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].next#" onclick="this.form.thisPage.selectedIndex++;this.form.submit();">
					</cfif>
				</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td>
			<!--- main table --->
			<table cellpadding="5" cellspacing="0" border="1" width="98%">
			<!--- header row --->
			<tr class="dataheader">
				<cfscript>
					for(i = 1;i LTE arrayLen(stGrid.aTable);i=i+1)
					{
						if (structKeyExists(stGrid.aTable[i],'heading'))
							writeoutput("<td align=""center""> #stGrid.aTable[i].heading#</td>");
					}

				</cfscript>
			</tr>
         	</cfoutput>
			<cfif recordSet.recordCount EQ 0 >
				<cfoutput>
				<tr>
					<td colspan="8" align="center">
						<strong>#application.adminBundle[session.dmProfile.locale].noRecsRecovered#</strong>
					</td>
				</tr>
				</cfoutput>
			<cfelse>

				<cfoutput query="recordSet" startrow="#startRow#" maxrows="#numRecords#">

				  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">

				  	<cfscript>
						currentrow = recordset.currentrow;
						//locked is a core type property - if any record is locked, we will give the option to unlock
						if (listFindNoCase(recordset.columnlist,'locked'))
						{
							if( recordset.locked)
								bUnlock = true;
						}


						for(i=1;i LTE arrayLen(stGrid.aTable);i=i+1)
						{
							if (structKeyExists(stGrid.aTable[i],'columnType'))
							{
								switch("#stGrid.aTable[i].columnType#")
								{
									case 'eval':
									{
										writeoutput("<td");
										if (structKeyExists(stGrid.aTable[i],'align'))
											writeoutput(" align='#stGrid.aTable[i].align#'");
										writeoutput(">");
										if (structKeyExists(stGrid.aTable[i],'value'))
											writeoutput(evaluate(stGrid.aTable[i].value));
										else
											writeoutput("#application.adminBundle[session.dmProfile.locale].valueKeyRequired#");
										writeoutput("</td>");
										break;
									}

									default :
									{
										writeoutput("<td");
										if (structKeyExists(stGrid.aTable[i],'align'))
											writeoutput(" align='#stGrid.aTable[i].align#'");
										writeoutput(">");
										if (structKeyExists(stGrid.aTable[i],'value'))
											writeoutput(evaluate(DE(stGrid.aTable[i].value)));
										else
											writeoutput("#application.adminBundle[session.dmProfile.locale].valueKeyRequired#");
										writeoutput("</td>");
										break;
										break;
									}

								}
							}
						}
					</cfscript>


				  </tr>
				</cfoutput>
			</cfif>
			<cfoutput>
		 	</table>
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
				<!--- add button --->
				<cfif iObjectCreatePermission eq 1 eq 1>
					<input type="button" value="#application.adminBundle[session.dmProfile.locale].add#" width="100" style="width:100;" class="normalbttnstyle"  onClick="#stGrid.submit.create.onClick#">
				</cfif>
				</td>
				<!--- delete object(s)	 --->
				<cfif iObjectDeletePermission eq 1 eq 1>
				<td>
					<input name="delete" type="Hidden" value="0">
					<input type="button" value="#application.adminBundle[session.dmProfile.locale].delete#" width="100" style="width:100;" class="normalbttnstyle" onClick="if(confirmDelete('delete')){document['dynamicAdmin']['delete'].value = 1;this.form.submit();}">
				</td>
				</cfif>
				<!--- check if object uses status --->
				<cfif structKeyExists(application.types['#attributes.typename#'].stProps,"status")>
					<!--- Set status to pending --->
					<cfif iObjectRequestApprovalPermission eq 1>
					<td>
						<input type="submit" name="status" value="#application.adminBundle[session.dmProfile.locale].requestApproval#" width="100" style="width:100;" class="normalbttnstyle">
					</td>
					</cfif>
					<!--- set status to approved/draft --->
					<cfif iObjectApprovePermission eq 1>
					<td>
						<input type="submit" name="status" value="#application.adminBundle[session.dmProfile.locale].approve#" width="100" style="width:100;" class="normalbttnstyle">
					</td>
					<td>
						<input type="submit" name="status" value="#application.adminBundle[session.dmProfile.locale].sendToDraft#" width="100" style="width:100;" class="normalbttnstyle">
					</td>
					</cfif>
				</cfif>
				<!--- dump objects  --->
				<cfif iObjectDumpTab eq 1>
				<td>
					<input type="submit" name="dump" value="#application.adminBundle[session.dmProfile.locale].dump#" width="100" style="width:100;" class="normalbttnstyle">
				</td>
				</cfif>
				<!--- check if there are locked objects --->
				<cfif isdefined("bUnlock")>
				<td>
					<input type="Submit" name="unlock" value="#application.adminBundle[session.dmProfile.locale].unlockUC#" width="100" style="width:100;" class="normalbttnstyle" >
				</td>
				</cfif>
				<cfloop from="1" to="#arrayLen(stGrid.aCustomButtons)#" index="i">
				<td>
					<!--- First check if they have permission to see this button --->
					<cfif structKeyExists(stGrid.aCustomButtons[i],'permission')>
						<cfset bCustomPerm = application.security.checkPermission(permission=stGrid.aCustomButtons[i].permission) />
					<cfelse> <!--- Just assume everyone can use it --->
						<cfset bCustomPerm = 1>
					</cfif>
					<cfif bCustomPerm>
						<input type="submit" name="#stGrid.aCustomButtons[i].name#" value="#stGrid.aCustomButtons[i].value#" class="normalbttnstyle">
					</cfif>
				</td>
				</cfloop>
			</tr>
			<tr><td>&nbsp;</td></tr>
			</table>
			<!--- Determine whether or not the metadata layer is to be displayed or not --->

			<cfif attributes.bDisplayCategories>
				<cfparam name="isClosed" default="Yes">
				<cfif isDefined("form.categoryid") OR isDefined("form.apply")>
					<cfset isClosed = "No">
				</cfif>

				<table id="tree">
					<tr>
						<td>
						<cfparam name="form.categoryid" default="">
						<!--- display tree --->
						<cfinvoke component="#application.packagepath#.farcry.category" method="displayTree" bShowCheckBox="true" objectID="#createUUID()#" lSelectedCategories="#form.categoryid#"/>
						</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td align="center"><input type="Submit" value="#application.adminBundle[session.dmProfile.locale].restrict#" class="normalbttnstyle"></td>
					</tr>
				</table>

			</cfif>

			</form>
		</td>
	</tr>
</table>
</cfoutput>
