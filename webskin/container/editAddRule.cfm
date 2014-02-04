<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Add Rule to Container --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- environment variables --->
<cfparam name="url.lRules" default="" />
<cfparam name="url.lExcludedRules" default="" />

<!--- get available rules --->
<cfset qRules = createObject("component","#application.packagepath#.rules.rules").getRules(url.lRules,url.lExcludedRules) />

<!--- 
 // one rule: if there is only one rule then go straight to it 
--------------------------------------------------------------------------------->
<cfif qRules.recordcount eq 1>
	<!--- Setup New Rule --->
	<cfset stDefaultObject = application.fapi.getNewContentObject(qRules.rulename) />
	<cfset application.fapi.getContentType("#qRules.rulename#").setData(stProperties=stDefaultObject) />
	
	<!--- Append new rule to the array of rules in the current container --->
	<cfset arrayappend(stObj.aRules,stDefaultObject.objectID) />
	<cfset setData(stProperties=stObj)>
	<skin:location href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stDefaultObject.objectid#&typename=#stDefaultObject.typename#&method=editInPlace&iframe=1" addtoken="false" />
</cfif>

<!--- 
 // process container update 
--------------------------------------------------------------------------------->
<cfset containerID = replace(stobj.objectid,'-','','ALL') />

<ft:processform action="Cancel" bHideForms="true">
	<skin:onReady>
		<cfoutput>$fc.closeBootstrapModal();</cfoutput>	
	</skin:onReady>
</ft:processform>

<ft:processform action="Add Rule" bHideForms="true">

	<cfparam name="stObj.aRules" default="#arraynew(1)#" />	

	<!--- Setup New Rule --->
	<cfset stDefaultObject = application.fapi.getNewContentObject(form.selectedObjectID) />
	<cfset application.fapi.getContentType("#form.selectedObjectID#").setData(stProperties=stDefaultObject) />
	
	<!--- Append new rule to the array of rules in the current container --->
	<cfset arrayappend(stObj.aRules,stDefaultObject.objectID) />
	<cfset setData(stProperties=stObj)>

	<!--- Locate off to the edit the rule. --->
	<skin:location href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stDefaultObject.objectid#&typename=#stDefaultObject.typename#&method=editInPlace&iframe=1" addtoken="false" />
</ft:processform>


<!--- 
 // view: choose publishing rule 
--------------------------------------------------------------------------------->
<ft:form>
	<cfoutput>
		<table class="table table-hover table-striped">
			<thead>
				<tr>
					<th>&nbsp;</th>
					<th>Publishing Rules</th>
					<th>Description</th>
				</tr>
			</thead>
			<tbody>
	</cfoutput>
	<cfloop query="qRules">
		<cfif not qRules.rulename eq "container">
			<cfoutput>
			<tr>
				<td><i class="fa #qrules.icon# fa-fw"></i></td>
				<td nowrap><ft:button value="Add Rule" text="#qRules.displayName#" rendertype="link" selectedObjectID="#qRules.rulename#" /></td>
				<td>#qRules.hint#</td>
			</tr>
			</cfoutput>
		</cfif>
	</cfloop>
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
</ft:form>

<cfsetting enablecfoutputonly="false" />