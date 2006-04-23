<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/listobjects.cfm,v 1.5 2004/07/30 08:34:40 phastings Exp $
$Author: phastings $
$Date: 2004/07/30 08:34:40 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose object instances (listobjects.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lObjectids" default="">

<cffunction name="cleanUUID">
	<cfargument name="objectID" type="uuid">
	<cfset rObjectID = trim(replace(arguments.objectID,"-","","ALL"))> 
	<cfreturn rObjectID>
</cffunction>


<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
	<script>
	var rowcolor="red";
	function selectRow(id){
		em = document.getElementById(id);
		if (em.style.color != rowcolor)
			em.style.color="red";
		else
			em.style.color="black";
		}
	function toggleDiv(id){
		em = document.getElementById(id);
		if (em.style.display != 'inline'){
			em.style.display = 'inline';
			em = document.getElementById('showintro');
			em.innerHTML = "Hide Intro";
		}	
		else{
			em.style.display = 'none';
			em = document.getElementById('showintro');
			em.innerHTML = "Show Intro";
		}	
	}			
	</script>
</cfoutput>

<!--- The ordering logic for moveup/down --->
<!--- Move array elements up --->
<cfif isDefined("FORM.moveup") AND isDefined("FORM.objectID")>
	<cfset aObjectIDs = listToArray(output.lObjectIDS)>
	<cfset count = 1>
	<cfloop list="#form.objectID#" index="index">
	<cfscript>
		listIndex = listFind(output.lObjectIDs,index);
		formIndex = listFind(form.objectID,index);
		if(listIndex NEQ 1 OR formIndex NEQ count){
			arraySwap(aObjectIDS,listIndex,listIndex-1);
		}	
		count = count+1;	
		</cfscript>
	</cfloop>
	<cfset output.lObjectIDs = arrayToList(aObjectIDs)>
</cfif>

<!--- Move array elements down  --->
<cfif isDefined("FORM.movedown") AND isDefined("FORM.objectID")>
	<cfset aObjectIDs = listToArray(output.lObjectIDS)>
	<cfset aFormObjectIDs = listToArray(form.objectID)>
	<cfscript>
		for(index=arrayLen(aFormObjectIDs);index GTE 1;index=index-1)
		{	
			listIndex = listFind(output.lObjectIDs,aFormObjectIDs[index]);
			formIndex = listFind(form.objectID,aFormObjectIDs[index]);
			if(listIndex LT listLen(output.lObjectIDs) )
				arraySwap(aObjectIDS,listIndex,listIndex+1);
			else
				break;
		}
		</cfscript>
	<cfset output.lObjectIDs = arrayToList(aObjectIDs)>
</cfif>

<!--- delete objects --->
<cfif isDefined("form.delete.x") AND isDefined("FORM.objectID") AND listLen(output.lObjectIDs)>
	<cfloop list="#FORM.objectID#" index="i">
		<cfscript>
			output.lObjectIDs = listDeleteAt(output.lObjectIds,listFind(output.lObjectIDs,i));
		</cfscript>
		<cfset "cookie.hp_#output.cleanobjectID#" = output.lObjectIDs>
	</cfloop>
</cfif>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<!--- Set up default form values. If the form is submitted, update the output struct --->
<cfset index = 1>
<cfloop list="#output.lObjectIDs#" index="i">
	<cfset thisObjectID = cleanUUID(i)>
	<cfparam name="output.method_#thisObjectID#.displayMethod" default="#output.existingObjectWDDX[index].method#"> 
	<cfif isDefined("form.method_#thisObjectID#.displayMethod")>
		<cfset "output.method_#thisObjectID#.displayMethod" = evaluate("form.method_" & thisObjectID & ".displayMethod")>
	</cfif>
	<cfset index = index+1>
</cfloop>

<!--- This moves to the next step in the plp on form submission --->
<tags:plpNavigationMove>

<!--- defaults for this step --->

<cfif NOT thisstep.isComplete>


<cfset query_string = replace(CGI.QUERY_STRING,"&killplp=1","")>
<cfform action="#cgi.script_name#?#query_string#" name="editform" method="post">
<cfoutput>
	<cfif not listLen(output.lObjectIDs)>
	<div class="FormTitle" align="center" >
		#application.adminBundle[session.dmProfile.locale].noRuleObjSelected#<br>
		<a href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&handpickaction=add&ruleid=#output.objectid#&typename=rulehandpicked">Add Articles</a>
	</div>
	<cfelse>	
	
	
	<div class="FormTable" align="center" style="width:500px">
	<a id="showintro" href="javascript:void(0);" onClick="toggleDiv('introdiv');">#application.adminBundle[session.dmProfile.locale].showIntro#</a>
	<div id="introdiv" align="center" style="display:none;">
	<table width="100%" >
	<tr>
		<td align="center">
			Intro <br>
			<textarea rows="5" cols="40" name="intro">#output.intro#</textarea>
		</td>
	</tr>
	</table>
	</div>		
	<table width="100%" style="border:thin solid Black;" >
		
	<tr>
		<td colspan="4">
			<div class="FormTitle" align="center" >
				 #application.adminBundle[session.dmProfile.locale].selectedObj#
			</div>
		<table width="100%">
			<tr><td>
				<table width="100%">
				<tr>
					<td>
						#application.adminBundle[session.dmProfile.locale].Label#
					</td>
					<td>
						#application.adminBundle[session.dmProfile.locale].typeLC#
					</td>
					<td>
						#application.adminBundle[session.dmProfile.locale].displayMethodUC#
					</td>
					<td>
						#application.adminBundle[session.dmProfile.locale].Select#
					</td>
				</tr>
				
				<cfloop list="#output.lObjectIDs#" index="objectID" >
				<!--- retrieve this objects data --->
				<q4:contentobjectget objectID="#objectID#" r_stObject="stThisObject">
				<!--- getting the display templates for this objects 'type' eg dmhtml,dmnews --->
				
				<cfif NOT structIsEmpty(stThisObject)>
				<nj:listTemplates typename="#stThisObject.typename#" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
				<tr id="row#objectID#">
					<td>
						#stThisObject.label#
					</td>
					<td>
						#stThisObject.typename#
					</td>
					<td>
						<cfset thisObjectID = cleanUUID(stThisObject.objectID)>
						<select name="method_#thisObjectID#.displayMethod" size="1" class="field">
						<cfloop query="qDisplayTypes">
							<option value="#methodName#" <cfif evaluate("output.method_" & thisObjectID & ".displayMethod") IS methodname>selected</cfif>>#displayName#</option>
						</cfloop>
						</select>
					</td>
					<td>
						<input name="objectID" type="checkbox" value="#stThisObject.objectID#" onClick="selectRow('row#objectID#');"> 
					</td>
				</tr>
				<cfelse>
					<tr>
					<td colspan="4">
						#application.adminBundle[session.dmProfile.locale].ruleDeletedBlurb#
					</td>
					</tr>
					<cfset output.lObjectIds = listDeleteAt(output.lObjectIds,listFindNoCase(output.lObjectIds,objectid))>
				</cfif>
				</cfloop>
				<tr>
					<td colspan="3">&nbsp;</td>
					<td><input name="delete" type="image" src="#application.url.farcry#/images/treeImages/customIcons/rubbish.gif" alt="Delete Objects"></td>
				</tr>
				</table>
			</td>
			<td valign="middle">
				<input type="submit" value="&uarr;" name="moveup" class="normalbttnstyle" alt="#application.adminBundle[session.dmProfile.locale].moveObjUp#"><br>
				<input type="submit" value="&darr;" name="movedown" class="normalbttnstyle" alt="#application.adminBundle[session.dmProfile.locale].moveObjDown#">
			</td>
			</tr>	
		</table>
		</td>
		</table>	
	</table>
	
	<input type="button" value="#application.adminBundle[session.dmProfile.locale].addObj#" onClick="location.href='#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&handpickaction=add&ruleid=#output.objectid#&typename=rulehandpicked'" class="normalbttnstyle">
	<input type="submit" value="#application.adminBundle[session.dmProfile.locale].applyChanges#" name="submit" class="normalbttnstyle">
	
	</div>

	<input name="lobjectIDs" value="#output.lobjectIDs#" type="hidden">
	</cfif>
	
	</cfoutput>
	
</cfform>	

<cfelse>
	<tags:plpUpdateOutput>
</cfif>
