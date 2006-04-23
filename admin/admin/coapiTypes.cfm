<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/coapiTypes.cfm,v 1.17 2004/12/22 04:32:36 brendan Exp $
$Author: brendan $
$Date: 2004/12/22 04:32:36 $

$Name: milestone_2-3-2 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: Managemnt interface for types$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<admin:header title="COAPI Types" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iCOAPITab eq 1>	
	<cfparam name="FORM.action" default="">
	
	<cfscript>
		alterType = createObject("component","#application.packagepath#.farcry.alterType");
		alterType.refreshAllCFCAppData();
		if (isDefined("URL.deploy"))
			alterType.deployCFC(typename=url.deploy);
		switch(form.action){
			case "deleteproperty":
			 {
				alterType.deleteProperty(typename=form.typename,srcColumn=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 case "droparraytable":
			 {
			 	alterType.dropArrayTable(typename=form.typename,property=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 case "deployproperty":
			 {
			 	propMetadata = application.types[form.typename].stProps[form.property].metadata;
				//is the property nullable
				isNullable = false;
				if( isDefined('propMetadata.required') AND NOT propMetadata.required)
					isNullable = true;
				//do we have a default value
				defaultVal = "";
				if ( isDefined('propMetadata.default'))
					defaultVal = propMetadata.default;				
				alterType.addProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.types[form.typename].stProps[form.property].metadata.type),bNull=isNullable,stDefault=defaultVal);
			 	alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }	
			 case "deployarrayproperty":
			 {
			 	alterType.deployArrayProperty(typename=form.typename,property=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }	
			 case "renameproperty":
			 {
			 	alterType.alterPropertyName(typename=form.typename,srcColumn=form.property,destColumn=form.renameto,colType=form.colType,colLength=form.colLength);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			  case "repairproperty":
			 {
			 	alterType.repairProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.types[form.typename].stProps[form.property].metadata.type,true));
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 default:
			 {	//do nothing
			 
			 }
		 }
		
		//if (NOT application.dbType is "ora") //temp mess until oracle compatability introduced
			stTypes = alterType.buildDBStructure();
	</cfscript>
	
	<cfoutput>
	
	<script>
		function updateReport(html,divID){
			em = document.getElementById(divID);
			em.innerHTML = html;
		}
	</script>
	
	<span class="formtitle">#application.adminBundle[session.dmProfile.locale].typeClasses#</span><p></p>
	<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
	<tr>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].integrity#</th>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].component#</th>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].deployed#</th>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].deploy#</th>
	</tr>
	</cfoutput>
	
	<cfloop collection="#application.types#" item="componentName">
	
		<cfoutput>
	
		<cfscript>
			//if (NOT application.dbType is "ora")  //temp mess until oracle compatability introduced
			if (structKeyExists(stTypes,componentname))
				stConflicts = alterType.compareDBToCFCMetadata(typename=componentname,stDB=stTypes['#componentname#']);
			else
				stConflicts['#componentname#'] = structNew();
		</cfscript>
		
		
		<tr <cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>style='background-color:##ccc;color:black;'</cfif>>
			<td align="center">
		
				<cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>
					<img src="#application.url.farcry#/images/no.gif"> #application.adminBundle[session.dmProfile.locale].seeBelow#
				<cfelse>
					<img src="#application.url.farcry#/images/yes.gif">
				</cfif>
			</td>
			<td>#componentName#</td>
			<td align="center">
				<cfif alterType.isCFCDeployed(typename=componentName)>
					<img src="#application.url.farcry#/images/yes.gif">
				<cfelse>
					<img src="#application.url.farcry#/images/no.gif">
				</cfif>
			</td>
			
			<td align="center">
				<cfif NOT alterType.isCFCDeployed(typename=componentName)>
					<a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">#application.adminBundle[session.dmProfile.locale].deploy#</a>
				<cfelse>
					#application.adminBundle[session.dmProfile.locale].notAvailable#
				</cfif>
			</td>
		</tr>
		<cfscript>
			if (structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:red;'><div id='#componentname#_report'>");
				alterType.renderCFCReport(typename=componentname,stCFC=stConflicts['cfc'][componentname]);
				writeoutput("</div></td></tr>");		
				}
			if (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:red;'><div id='#componentname#_report'>");
				alterType.renderDBReport(typename=componentname,stDB=stConflicts['database'][componentname]);
				writeoutput("</div></td></tr>");		
				}
		</cfscript>
		</cfoutput>
	</cfloop>
	
	<cfoutput>
	</table>
	
	<IFRAME WIDTH="400" HEIGHT="400" NAME="idServer" ID="idServer" 
		 FRAMEBORDER="1" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0" style="display:none" SRC="null">
			<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
			 ID="idServer">
			<P>#application.adminBundle[session.dmProfile.locale].browserReqBlurb#</P>
			</ILAYER>
	</IFRAME>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="No">

