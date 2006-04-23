<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/editContainer.cfm,v 1.11 2003/09/22 04:04:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 04:04:11 $
$Name: b201 $
$Revision: 1.11 $ 

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

<!--- required parameters --->
<cfparam name="URL.containerID">

<!--- default parameters --->
<cfparam name="URL.mode" default="update">
<cfparam name="form.dest" default="">


<!--- 
This is for convenience 
- we set up a list and a query object of the active rules for this object 
- bit clunky i know 
PH
--->
<q4:contentObjectGet typename="#application.packagepath#.rules.container" objectID="#URL.containerID#" r_stObject="stObj">  
<cfset qActiveRules = queryNew("objectID,typename")>
<cfset thisRow = 1>
<cfloop from="1" to="#arrayLen(stObj.aRules)#" index="i">
	<cfset newRow = queryAddRow(qActiveRules,1)>
	<cfinvoke component="farcry.fourq.fourq" returnvariable="rule" method="findType" objectID="#stObj.aRules[i]#">
	<cfset temp = querySetCell(qActiveRules,"objectID",stObj.aRules[i],thisRow)>
	<cfset temp = querySetCell(qActiveRules,"typename",rule,thisRow)>
	<cfset thisRow = thisRow + 1>
</cfloop>
<cfset activeRulesList = valueList(qActiveRules.typename)>

<!---
*********************************************************************
	This gets all core and custom rules
*********************************************************************
 --->
<cfinvoke component="#application.packagepath#.rules.rules" method="getRules" returnvariable="qRules"/>
<!---  <cfdump var="#qRules#"> --->

<!--- A function to make dealing with custom rules slightly less painfull --->
<cffunction name="isCustomRule" returntype="struct">
	<cfargument name="rulename" required="true" hint="the name of the rule i.e. ruleNews,ruleXMLFeed">
	<!--- A query of the qRules query above to determine whether this rule is a custom rule or not --->
	<cfquery name="qIsCustom" dbtype="query">
		SELECT bCustom FROM qRules
		WHERE rulename = '#arguments.rulename#'
	</cfquery>
	
	<cfscript>
		stIsCustom = structNew();
		if(qIsCustom.bCustom){
			stIsCustom.bCustom = 1;
			stIsCustom.typename = application.custompackagepath & '.rules.' & arguments.rulename;
		}else
		{
			stIsCustom.bCustom = 0;
			stIsCustom.typename = application.packagepath & '.rules.' & arguments.rulename;
		}		 
	</cfscript>
	<cfreturn stIsCustom>
</cffunction> 


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
			fbox.options[i].value = "";
			fbox.options[i].text = "";
	   }
	}
	BumpUp(fbox);
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
{	//alert('hey');
	//alert(oRules[rulename].hint);
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
					<option value="#objectID#" <cfif updateType IS objectID>selected</cfif>>#evaluate("application.rules." & typename & ".displayname")#</option>	
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
		<!--- <cfdump var="#qActiveRules#" label="qActiveRules"> --->
		<!---
		*********************************************************************
			Call the update method for the selected rule - this displays the form
		*********************************************************************
		 --->
		<cfoutput><div id="background">
			<cfif NOT evaluate("application.rules." & qGetRuleTypename.typename & ".bCustomRule")>
				<cfinvoke component="#application.packagepath#.rules.#qGetRuleTypename.typename#" method="update" objectID="#updateType#">
			<cfelse>	
				<cfinvoke component="#application.custompackagepath#.rules.#qGetRuleTypename.typename#" method="update" objectID="#updateType#">
			</cfif>
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
		<!--- Go thru and remove any rule types that have been removed - both from the DB and the aRules array --->
		<cfloop query="qActiveRules">
			<cfif NOT listContainsNoCase(form.dest,qActiveRules.typename) AND len(typename) GT 0>
			<cfset stDefineRule = isCustomRule(typename)>
			
			<q4:contentobjectdelete typename="#stDefineRule.typename#" objectID="#qActiveRules.objectID#">	
					
			<cfloop from="#arrayLen(stObj.aRules)#" to="1" index="i" step="-1">
				<cfif stObj.aRules[i] IS objectID>
					<cfset temp = arrayDeleteAt(stObj.aRules,i)>
				</cfif>
			</cfloop>
			</cfif>	
		</cfloop>
		<!--- Now we are checking to see if any new ones have been added to the list - if so we create a new instance of that rule type --->
		<cfloop list="#form.dest#" index="thisType">
			<cfif NOT listContainsNoCase(activeRulesList,thisType)>
			<!--- Get the properties for this type - and create a rule instance --->
			<cfscript>
			 stDefineRule = isCustomRule(thisType);
			 obj = createObject("Component", "#stDefineRule.typename#");
			 typeProps = obj.getProperties();
			 stProps = structNew();
			 stProps.objectid = createUUID();
			</cfscript>
			<cfloop from="1" to="#arrayLen(typeProps)#" index="objID">
				<cfif structKeyExists(typeProps[objID],"default")>
						<cfset "stProps.#typeProps[objID].name#" = "#typeProps[objID].default#">
				</cfif>
			</cfloop>
			<q4:contentObjectCreate typename="#stDefineRule.typename#" stProperties="#stProps#">
			<cfset temp = arrayAppend(stObj.aRules,stProps.objectID)>
			</cfif>
		</cfloop>
		<!--- Now to reorder - man this is a mess --->
		<cfloop from="1" to="#arraylen(stObj.aRules)#" index="i" step="1" >
			<cfinvoke component="farcry.fourq.fourq" returnvariable="thisrulename" method="findType" objectID="#stObj.aRules[i]#">
			<cfset index = listFindNoCase(form.dest,thisrulename)>
			<cfif index GT 0 AND i NEQ index>
				<cfset tmp = arrayswap(stObj.aRules,i,index)>			
			</cfif>
		</cfloop>
		
		<!--- now update the container object --->
		<q4:contentobjectdata typename="#application.packagePath#.rules.container" stProperties="#stObj#" objectID="#stObj.objectID#"> 
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
							<cfif NOT listContainsNoCase(activeRulesList,qRules.rulename)>
								<!--- need check here for displayname key --->
								<option value="#rulename#" >#evaluate("application.rules." & rulename & ".displayname")#
							</cfif>
						</cfloop>
					</select>
				</td>
				<td valign="middle" align="center">
					<input type="button" name="B1" value="   >>>>   " class="normalBttnStyle"  onClick="move(this.form.source,this.form.dest)"><br><br>
					<input class="normalBttnStyle"  type="button" value="   <<<<   " onclick="takeoff(this.form.dest,this.form.source)" name="B2"><br><br>
				</td>
				<td valign="top" align="center">		
						<strong>Active Rules</strong><br>
						<select multiple name="dest" size="8"  style="font-size:7pt;">
						<cfloop query="qActiveRules">
							<!--- need check here for displayname key --->
							<option value="#typename#">#evaluate("application.rules." & typename & ".displayname")#
						</cfloop>
						</select>
				</td>
				<td valign="middle" align="left">
					<input class="normalBttnStyle"  type="button" value="&##8593;"
					onClick="moveindex(this.form.dest.selectedIndex,-1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="&##8595;"
					onClick="moveindex(this.form.dest.selectedIndex,+1)">
				</td>	
			</tr>		
			
			<tr>
				<td colspan="4" align="center">
					<input class="normalbttnstyle" name="update" type="submit" value="OK" onclick="selectAll(this.form.dest);">
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