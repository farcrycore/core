<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: shows rules associated with this object $

|| DEVELOPER ||
$DEVELOPER: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4" />

<!--- environment variables --->
<cfparam name="URL.action" default="">

<cfset oCon = createObject("component","#application.packagepath#.rules.container") />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" />

<cfoutput>
<script language="JavaScript">
function executeRuleUpdate(typename,ruleid)
{  
	//collapse the rule listings
	document.getElementById('maindiv').style.display = 'none';
	document.getElementById('editruleframe').style.display = 'inline';
	document.getElementById('editrulemsg').innerHTML = 'You are editing rule id ' + ruleid;
	strURL = '#application.url.farcry#/admin/editRule.cfm?ruleid=' + ruleid + '&typename=' + typename;
	if( document.all )//ie
		document.ruleFrame.location = strURL;
	else//ns
		document.getElementById("ruleFrame").contentDocument.location = strURL;	

}	
function reinstateRuleListing()
{
	document.getElementById('maindiv').style.display = 'inline';
	document.getElementById('editruleframe').style.display = 'none';
	document.getElementById('editrulemsg').innerHTML = '';
	strURL = '#application.url.farcry#/admin/editRule.cfm';
	if( document.all )//ie
		document.ruleFrame.location = strURL;
	else//ns
		document.getElementById("ruleFrame").contentDocument.location = strURL;	

}
</script>

<div id="maindiv">
<br>
</cfoutput>

<cfswitch expression="#url.action#">
	
	<cfcase value="edit">
		<cfscript>
			o = createObject("component", application.rules[url.typename].rulePath);
			if (url.typename eq "ruleHandpicked")
			{
				o.update(objectid=URL.ruleid,cancelLocation="#application.url.farcry#/edittabRules.cfm?");
			}
			else
				o.update(objectid=URL.ruleid);
		</cfscript>
	</cfcase>
	
	<cfcase value="delete">
		<cfscript>
			o = createObject("component", application.rules[url.typename].rulePath);
			//o.delete(objectid=URL.ruleid);
			stCon = oCon.getData(objectid=url.containerid,dsn=application.dsn);
			for (i = arrayLen(stCon.aRules);i GTE 0; i = i-1)
			{
				if(stCon.aRules[i] IS url.ruleid)
				{
					arrayDeleteAt(stCon.aRules,i);
					break;
				}	
			}
			oCon.setData(stProperties=stCon,dsn=application.dsn);
		</cfscript>
		
		<cfoutput>
		<div align="center" class="formtitle">#application.adminBundle[session.dmProfile.locale].publishingRuleDeleted#</div>
		</cfoutput>
	</cfcase>
	
	<cfdefaultcase>
		<cfif isDefined("url.objectid")>
			<cfscript>
				ofourq = createObject("component","farcry.farcry_core.fourq.fourq");
				q = oCon.getContainersByObject(objectid=URL.objectid,dsn=application.dsn);
			</cfscript>
			<!--- Get all the containers that are more than likely associated with this object. Relies on correct naming of containers at the moment which is not zehr gut. --->
			<cfquery name="q" datasource="#application.dsn#">
				SELECT * FROM #application.dbowner#container
				where label LIKE ('%#URL.objectid#%')
			</cfquery>
			
			<cfoutput query="q">
				<!--- Now get the rules --->
				<cfscript>
					stCon = oCon.getData(objectid=q.objectid,dsn=application.dsn);
				</cfscript>
				<cfif arrayLen(stCon.aRules)>
					<cfoutput>
					<span class="FormTitle" style="margin-left:30px;">#q.label#</span><br>
					<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;margin-top:5px" width="400">
					<tr class="dataheader">
						<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].ruleType#</strong></td>
						<td align="center" width="75"><strong>#application.adminBundle[session.dmProfile.locale].edit#</strong></td>
						<td align="center" width="75"><strong>#application.adminBundle[session.dmProfile.locale].delete#</strong></td>
					</tr>
					</cfoutput>
					
					<cfloop from="1" to="#arrayLen(stCon.aRules)#" index="i">
					<cfscript>
						typename = oFourq.findType(objectid=stCon.aRules[i],dsn=application.dsn);
					</cfscript>
					<cfoutput>
					<tr>
						<td>#typename#</td>
						<td align="center">
							<a onclick="executeRuleUpdate('#typename#','#stCon.aRules[i]#')" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].edit#</a> 
						</td>
						<td align="center">
							<a href="#cgi.script_name#?action=delete&ruleid=#stCon.aRules[i]#&containerid=#stCon.objectid#&typename=#typename#">#application.adminBundle[session.dmProfile.locale].delete#</a>
						</td>
					</tr>
					</cfoutput>
					</cfloop>
					
					<cfoutput>
					</table>
					<p>&nbsp;</p>
					</cfoutput>
				</cfif>
			</cfoutput>
		</cfif>
	</cfdefaultcase>
</cfswitch>

<cfoutput>
</div>
<div id="editruleframe" style="display:none">
	<span id="editrulemsg"></span>. <a onclick="reinstateRuleListing()" href="javascript:void(0)">#application.adminBundle[session.dmProfile.locale].returnRuleList#</a>
	<iframe name="ruleFrame" id="ruleFrame" src="#application.url.farcry#/admin/editrule.cfm" frameborder="0" width="100%" height="100%"></iframe>
</div>
</cfoutput>

<!--- setup footer --->
<admin:footer />

<cfsetting enablecfoutputonly="false" />