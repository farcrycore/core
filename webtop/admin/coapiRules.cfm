<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/coapiRules.cfm,v 1.16 2005/09/06 10:19:00 paul Exp $
$Author: paul $
$Date: 2005/09/06 10:19:00 $
$Name: milestone_3-0-1 $
$Revision: 1.16 $

|| DESCRIPTION || 
$Description: Managemnt interface for rules$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="#application.rb.getResource('coapiadmin.headings.COAPIrules@text','COAPI Rules')#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfoutput><h3>#application.rb.getResource("coapiadmin.headings.ruleClasses@text","Rule Classes")#</h3></cfoutput>
	
	<cfparam name="FORM.action" default="">
	
	<cfscript>
		alterType = createObject("component","#application.packagepath#.farcry.alterType");
		alterType.refreshAllCFCAppData();
		if (isDefined("URL.deploy"))
			alterType.deployCFC(typename=url.deploy,scope='rules');
		switch(form.action){
			case "deleteproperty":
			 {
				alterType.deleteProperty(typename=form.typename,srcColumn=form.property);
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }
			 case "droparraytable":
			 {
			 	alterType.dropArrayTable(typename=form.typename,property=form.property);
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }
			 case "deployproperty":
			 {
			 	alterType.addProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.rules[form.typename].stProps[form.property].metadata.type));
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }	
			 case "deployarrayproperty":
			 {
			 	alterType.deployArrayProperty(typename=form.typename,property=form.property,scope='rules');
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }	
			 case "renameproperty":
			 {
			 	alterType.alterPropertyName(typename=form.typename,srcColumn=form.property,destColumn=form.renameto,colType=form.colType,colLength=form.colLength);
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }
			  case "repairproperty":
			 {
			 	alterType.repairProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.rules[form.typename].stProps[form.property].metadata.type),scope='rules');
				alterType.refreshCFCAppData(typename=form.typename,scope='rules');
				break;
			 }
			 default:
			 {	//do nothing
			 
			 }
		 }
		
		//if (NOT application.dbType is "ora") //temp mess until oracle compatability introduced
			stTypes = alterType.buildDBStructure(scope='rules');
	</cfscript>
	
	<cfoutput>
	<!--- TODO: what is this??  Can we remove it?? GB --->
	<script>
		function updateReport(html,divID){
			em = document.getElementById(divID);
			em.innerHTML = html;
		}
	</script>
	
	<table class="table-5" cellspacing="0">
	<tr>
		<th>#application.rb.getResource("coapiadmin.labels.integrity@text","Integrity")#</th>
		<th>#application.rb.getResource("coapiadmin.labels.component@text","Component")#</th>
		<th>#application.rb.getResource("coapiadmin.labels.deployed@text","Deployed")#</th>
		<th style="border-right:none">#application.rb.getResource("coapiadmin.labels.deploy@text","Deploy")#</th>
	</tr>
	</cfoutput>
	
	<cfloop collection="#application.Rules#" item="componentName">
		<cfscript>
			if (structKeyExists(stTypes,componentname))
				stConflicts = alterType.compareDBToCFCMetadata(typename=componentname,stDB=stTypes['#componentname#'],scope='rules');
			else
				stConflicts['#componentname#'] = structNew();
		</cfscript>
		
		<cfoutput>		
		<tr <cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>style='color:##000;'</cfif>>
			<td align="center">
				<!--- i18n:  yes/no images? check vs x ok across all locales?  --->
				<cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>
					<img src="#application.url.farcry#/images/no.gif" /> #application.rb.getResource("coapiadmin.labels.seeBelow@label","See Below")#
				<cfelse>
					<img src="#application.url.farcry#/images/yes.gif" />
				</cfif>
			</td>
			<td>#componentName#</td>
			<td>
				<!--- i18n:  yes/no images? check vs x ok across all locales?  --->
				<cfif alterType.isCFCDeployed(typename=componentName)>
					<img src="#application.url.farcry#/images/yes.gif" />
				<cfelse>
					<img src="#application.url.farcry#/images/no.gif" />
				</cfif>
			</td>
			
			<td style="border-right:none">
				<cfif NOT alterType.isCFCDeployed(typename=componentName)>
					<a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">#application.rb.getResource("coapiadmin.buttons.deploy@label","Deploy")#</a>
				<cfelse>
					#application.rb.getResource("coapiadmin.labels.notAvailable@label","n/a")#
				</cfif>
			</td>
		</tr>
		<cfscript>
			if (structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderCFCReport(typename=componentname,stCFC=stConflicts['cfc'][componentname],scope='rules');
				writeoutput("</div></td></tr>");		
				}
			if (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderDBReport(typename=componentname,stDB=stConflicts['database'][componentname],scope='rules');
				writeoutput("</div></td></tr>");		
				}
		</cfscript>
		</cfoutput>
	</cfloop>
	
	<cfoutput>
	</table>
	
	</cfoutput>
</sec:CheckPermission>

<admin:footer>
<cfsetting enablecfoutputonly="No">

