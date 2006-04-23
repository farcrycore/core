<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/editContainer.cfm,v 1.16 2004/01/14 23:47:32 tom Exp $
$Author: tom $
$Date: 2004/01/14 23:47:32 $
$Name: milestone_2-1-2 $
$Revision: 1.16 $ 

|| DESCRIPTION || 
$Description:  $
$TODO: This page started as a test harness for editing container rules - if you are reading this then this page has not actually been rewritten properly :)  PH$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
$Developer: Paul Harrison (paul@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes">

<!--- import tag libraries --->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/admin" prefix="farcry">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<!--- required parameters --->
<cfparam name="URL.containerID">

<!--- default parameters --->
<cfparam name="URL.mode" default="update">
<cfparam name="form.dest" default="">

<cfscript>
	q4 = createObject("component","farcry.fourq.fourq");
	oRules = createObject("component","#application.packagepath#.rules.rules");
	//get the container data
	oCon = createObject("component","#application.packagepath#.rules.container");
	stObj = oCon.getData(objectid=URL.containerID);
	
	qActiveRules = queryNew("objectID,typename");
	for(index=1;index LTE arrayLen(stObj.aRules);index=index+1)
	{
		queryAddRow(qActiveRules,1);
		ruletype = q4.findType(objectid=stObj.aRules[index]);
		querySetCell(qActiveRules,"objectID",stObj.aRules[index]);
		querySetCell(qActiveRules,"typename",ruletype);
	}
	
	//gets all core and custom rules
	qRules = oRules.getRules();
</cfscript>

<!--- //****************************************************************
	Start Presentation & Output
******************************************************************// --->
<cfoutput>
<html>
<head>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<link href="#application.url.farcry#/css/tabs.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../includes/synchtab.js"></script>
</head>
<body>
</cfoutput>
<!---
************************************************************************************
	Javascript to handle ordering, selecting rules
************************************************************************************
$TODO: Move these Javascript functions to an external library and place call in the document HEAD -- GB$
 --->
<cfoutput>
<SCRIPT LANGUAGE="JavaScript">

<!-- Begin
sortitems = 1;  

function moveindex(index,to) {
var list = document.form.dest;
var total = list.options.length-1;
if (index == -1) return false;
if (to == +1 && index == total) return false;
if (to == -1 && index == 0) return false;
var items = new Array;
var values = new Array;
for (i = total; i >= 0; i--) {
	items[i] = list.options[i].text;
	values[i] = list.options[i].value;
}
for (i = total; i >= 0; i--) {
if (index == i) {
	list.options[i + to] = new Option(items[i],values[i], 0, 1);
	list.options[i] = new Option(items[i + to], values[i + to]);
	i--;
}
else {
	list.options[i] = new Option(items[i], values[i]);
   }
}
list.focus();
}

function move(fbox,tbox)
{	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			//fbox.options[i].value = "";
			//fbox.options[i].text = "";
	   }
	}
	//BumpUp(fbox);
}

function takeoff(fbox,tbox)
{	//alert(tempcount);
	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			fbox.options[i].value = "";
			fbox.options[i].text = "";
	   }
	}
	BumpUp(fbox);
}


function BumpUp(box)
{
	for(var i=0; i<box.options.length; i++)
	{
		if(box.options[i].value == "")
		{
			for(var j=i; j<box.options.length-1; j++) {
				box.options[j].value = box.options[j+1].value;
				box.options[j].text = box.options[j+1].text;
			}
		var ln = i;
		break;
   		}
	}
	if(ln < box.options.length)  {
		box.options.length -= 1;
		BumpUp(box);
   }
}

function confirmDelete(){
	var msg = "Are you sure you wish to delete this package ?";
	if (confirm(msg))
		return true;
	else
		return false;
}				


function selectAll(dest){
	for (var i = 0; i < dest.options.length; i++) { 
		dest.options[i].selected = true;
	}
 }
 
 function deleteRule(fbox)
 {
 	if (confirm("Are you sure you wish to delete this rule instance?"))
	{
		 for(var i=0; i<fbox.options.length; i++)
		 {
			if(fbox.options[i].selected)
			{
				fbox.options[i].value = "";
				fbox.options[i].text = "";
		   }
		}
		BumpUp(fbox);	
	}	
 }
 
// build rules structure
oRules = new Object;
<cfloop query="qRules">
	oRules['#qRules.rulename#'] = new Object;
	<cfif structKeyExists(application.rules['#qRules.rulename#'],'hint')>
		oRules['#qRules.rulename#'].hint = '#application.rules[qRules.rulename].hint#';
	<cfelse>
		oRules['#qRules.rulename#'].hint = 	'';
	</cfif>
	
</cfloop>
 
function renderHint(rulename)
{	
	document.getElementById('rulehint').innerHTML = oRules[rulename].hint;
}	
 
 
// End -->
</script>
</cfoutput>


<!--- 
************************************************************************
This is the container header
************************************************************************
 --->
<cfoutput>
<div id="Header">
	<span class="title">#application.config.general.siteTitle#</span><br/>
	<span class="description">#application.config.general.siteTagLine#</span>
	<div class="mainTabArea" align="right">
	<farcry:tabs>
		<cfif URL.mode IS "update">
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="Container Content">
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="Container Content"></cfif>
		<cfif URL.mode IS "configure">
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="Configure Rules List">
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="Configure Rules List">
		</cfif>
	</farcry:tabs>
	</div>
</div>
</cfoutput>

<cfswitch expression="#URL.mode#"> 

<cfcase value="update">
	<!---
	 set a default value for 'updateType' 
	 - so we know which update method to invoke when we first get to this page 
	 ie. default to the first rule
	--->
	<cfscript>
		if(arrayLen(stObj.aRules) GT 0 AND NOT isDefined("form.ruleID"))
			updateType = stObj.aRules[1];
		else if(isDefined("form.ruleID"))
			updateType = form.ruleID;	
	</cfscript>	

	<cfoutput>
	<div class="tabTitle" id="EditFrameTitle" align="center">
		<form action="" method="post">
			Active Rules For This Container 
			<select name="ruleID" onChange="form.submit();" class="field">
			<cfif arrayLen(stObj.aRules) GT 0>
				<cfloop query="qActiveRules" >
					<option value="#objectID#" <cfif updateType IS objectID>selected</cfif>><cfif structKeyExists(application.rules[typename],'displayname')>#evaluate("application.rules." & typename & ".displayname")#<cfelse>#typename#</cfif></option>	
				</cfloop>
			<cfelse>
				<option>No rules Selected for this container</option>
			</cfif>
			</select>
		</form>
	</div>
	</cfoutput>
	<!--- 
	*********************************************************************
		Now show the update form 
	*********************************************************************
	--->
	<cfif arrayLen(stObj.aRules) GT 0>
		<!--- get the typename for the current rule --->
		<cfquery dbtype="query" name="qGetRuleTypename">
			SELECT typename FROM qActiveRules where objectID = '#updateType#'
		</cfquery> 
		<!---
		*********************************************************************
			Call the update method for the selected rule - this displays the form
		*********************************************************************
		 --->
		<cfoutput><div id="background">
			<cfinvoke component="#application.rules[qGetRuleTypename.typename].rulepath#" method="update" objectID="#updateType#">
		</div></cfoutput>
	</cfif>	
</cfcase>
<cfdefaultcase>
	
	<!--- 
	*********************************************************************
		This updates the rule list for the container
	*********************************************************************
	 --->
	<cfif isDefined("form.update")>
		<cfscript>
			function IsCFUUID(str)
			{  		
				return REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str);
			}
		
	
			//reinit aRules array for re-sequencing
			stObj.aRules = arrayNew(1); 
			for(i=1;i LTE listLen(form.dest);i=i+1)
			{
				key = listGetAt(form.dest,i);
				if (NOT IsCFUUID(key))
				{
					// Get the properties for this type - and create a rule instance --->
					obj = createObject("Component", application.rules[key].rulePath);
				 	typeProps = obj.getProperties();
			 		stProps = structNew();
			 		stProps.objectid = createUUID();
					for(j=1;j LTE arrayLen(typeProps);j=j+1)
					{
						if (structKeyExists(typeProps[j],"default"))
							"stProps.#typeProps[j].name#" = "#typeProps[j].default#";
					}
					o = createObject("component","#application.rules[key].rulePath#");
					o.createData(stProperties=stProps);
					arrayAppend(stObj.aRules,stProps.objectID);
				}
				else
					arrayAppend(stObj.aRules,key);	
			}
		//now update the container object 
		oCon.setData(stProperties=stObj);
		</cfscript>	
		<cflocation url="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update"> 
		
	</cfif>
	<!--- 
	************************************************************************************				
		Display the interface for selecting, ordering rules	
	************************************************************************************
	 --->
	<cfoutput>
	<div id="background">
	<form name="form" action="" method="post">
	<table  align="center" width="100%">
	<tr>
		<td  align="left">
			<table border="0" cellspacing="0" cellpadding="5" align="center">
			<tr>
				<td  align="center" valign="top">
					<strong>Available Rule Types</strong><br>
					<select name="source" size="8" style="font-size:7pt; border: 0px none;" onchange="renderHint(this.value);" >
						<cfloop query="qRules">
							<option value="#rulename#" ><cfif structKeyExists(application.rules[rulename],'displayname')>#evaluate("application.rules." & rulename & ".displayname")#<cfelse>#rulename#</cfif>
						</cfloop>
					</select>
				</td>
				<td valign="middle" align="center">
					<input type="button" name="B1" value="   >>>>    " class="normalBttnStyle"  onClick="move(this.form.source,this.form.dest)"><br><br>
				</td>
				<td valign="top" align="center">		
						<strong>Active Rules</strong><br>
						<select multiple name="dest" size="8"  style="font-size:7pt;">
						<cfloop query="qActiveRules">
							<!--- need check here for displayname key --->
							<option value="#qActiveRules.objectid#">#evaluate("application.rules." & typename & ".displayname")#
						</cfloop>
						</select>
				</td>
				<td valign="middle" align="left">
					<input class="normalBttnStyle"  type="button" value="&##8593;"
					onClick="moveindex(this.form.dest.selectedIndex,-1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="&##8595;"
					onClick="moveindex(this.form.dest.selectedIndex,+1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="Delete Rule"
					 onClick="deleteRule(this.form.dest);">
				</td>	
			</tr>		
			
			<tr>
				<td colspan="4" align="center">
					<input class="normalbttnstyle" name="update" type="submit" value="Commit Changes" onclick="selectAll(this.form.dest);">
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	</form>
	<!--- Rule hint will be dynamically populated here --->
	<div align="center">
		<span id="rulehint"></span>
	</div>
	
	</div>
	</cfoutput>
</cfdefaultcase>	
</cfswitch>

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">