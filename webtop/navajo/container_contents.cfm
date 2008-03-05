<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/navajo/container_contents.cfm,v 1.8 2005/10/27 05:09:22 guy Exp $
$Author: guy $
$Date: 2005/10/27 05:09:22 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $ 

|| DESCRIPTION || 
$Description: Container management editing interface, this page is specificall for listing the availables and selected rules for this container only. $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->
<cfparam name="containerID" default="">
<cfparam name="errormessage" default="">
<cfparam name="formSubmitted" default="no">
<cfparam name="ruleID" default="">
<cfparam name="ruleTypeName" default="">

<cfif containerID NEQ "">
	<!--- get the container data --->
	<cfset stObj = oCon.getData(objectid=containerID)>
	<cfif StructIsEmpty(stObj)>
		<cfset errormessage = errormessage & "Invalid Container ID: [#containerID#]">
	</cfif>
	
	<cfif formSubmitted EQ "yes" AND errormessage EQ ""> <!--- form is submitted --->
	<!--- reinit aRules array for re-sequencing  --->

	</cfif>

	<cfset qActiveRules = queryNew("objectID,typename")>
	<cfloop index="i" from="1" to="#arrayLen(stObj.aRules)#">
		<cfset queryAddRow(qActiveRules,1)>
		<cfset ruletype = oCon.findType(objectid=stObj.aRules[i])>
		<cfset querySetCell(qActiveRules,"objectID",stObj.aRules[i])>
		<cfset querySetCell(qActiveRules,"typename",ruletype)>
	</cfloop>

	<cfif StructKeyExists(form,"ruleid")>
		<cfset variables.RuleID = form.ruleid />
	<cfelseif StructKeyExists(url,"ruleid") >
		<cfset variables.RuleID = URL.RuleID />
	<cfelseif StructKeyExists(session,"RuleID")>
		<cfset variables.RuleID = session.RuleID>
	</cfif>

	<cfquery name="currentRule" dbtype="query">
	SELECT * FROM qActiveRules
	WHERE ObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.RuleID#">
	</cfquery>
	<cfif currentRule.recordcount EQ 1>
		<cfset selectedRuleTypeName = currentRule.TypeName[1] />
	<cfelse>
		<cfset selectedRuleTypeName = qActiveRules.TypeName[1] />
		<cfset variables.ruleID = qActiveRules.ObjectID[1] />
	</cfif>

	<!--- create rule object for display method --->
	<cfset objRule = createObject("component", application.rules[selectedRuleTypeName].rulepath)>
<cfelse>
	<cfset errormessage = errormessage & "Invalid Container ID: [not passed]">
</cfif>

<cfsetting enablecfoutputonly="false">
<cfoutput>
<!--- form for the rule selection only --->
<form name="frm" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2 f-bg-3">
	<fieldset>
	<cfif errormessage NEQ ""> <!--- display error --->
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	<cfelse> <!--- all good show form --->
		<label for="selectedRuleid"><b>#application.rb.getResource("containerActiveRules")#:</b>
		<select id="ruleID" name="ruleID" onchange="document.frm.submit();"><cfset iCounter = 0><cfif arrayLen(stObj.aRules) EQ 0>
		<option value="">#application.rb.getResource("noContainerRules")#</option><cfelse><cfloop query="qActiveRules" ><cfset iCounter = iCounter + 1>
		<option value="#qActiveRules.objectID#"<cfif ruleID EQ qActiveRules.objectID>selected="selected"</cfif>>[#iCounter#] <cfif structKeyExists(application.rules[qActiveRules.typename],'displayname')>#application.rules[qActiveRules.typename].displayname#<cfelse>#qActiveRules.typename#</cfif></option></cfloop></cfif>
		</select><br />
		</label>
	</cfif>
	<input type="hidden" name="reflectionID" value="">
	</fieldset>
</form></cfoutput>

<!--- generate rules editform --->
<cfset objRule.update(objectid=variables.ruleID)>

