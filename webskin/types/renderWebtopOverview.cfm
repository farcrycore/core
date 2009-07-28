<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Tabs for each status of the object for the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<!------------------ 
START WEBSKIN
 ------------------>
<cfif structKeyExists(stobj,"versionID") AND stobj.versionID NEQ "">
	<!--- IF THIS IS A VERSION OF ANOTHER OBJECT, RUN THIS WEBSKIN WITH THE MAIN VERSION --->
	<cfset html = getView(objectid="#stobj.versionid#", template="renderWebtopOverview", alternateHTML="") />
	<cfif len(html)>
		<cfoutput>#html#</cfoutput>
	<cfelse>
		<cfoutput><h1>OBJECT REFERENCES A VERSION THAT DOES NOT EXIST</h1></cfoutput>
	</cfif>
<cfelse>

	<!--- grab draft object overview --->
	<cfset stDraftObject = StructNew()>
	
	<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset stDraftObject = getData(qDraft.objectid)>
		</cfif>
	</cfif>

<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />


<skin:onReady>
	<cfoutput>
	$j("##tabs").tabs();
	
	$fc.openDialog = function(title,url,width,height){
		var fcDialog = $j("<div></div>")
		w = width ? width : 600;
		h = height ? height : $j(window).height()-50;
		$j("body").prepend(fcDialog);
		$j(fcDialog).dialog({
			bgiframe: true,
			modal: true,
			title:title,
			width: w,
			height: h,
			close: function(event, ui) {
				$j(fcDialog).dialog( 'destroy' );
				$j(fcDialog).remove();
			}
			
		});
		$j(fcDialog).dialog('open');
		$j.ajax({
			type: "POST",
			cache: false,
			url: url, 
			complete: function(data){
				$j(fcDialog).html(data.responseText);			
			},
			dataType: "html"
		});
	};	
	
	
	$fc.openDialogIFrame = function(title,url,width,height){
		var fcDialog = $j("<div><iframe style='width:99%;height:99%;border-width:0px;'></iframe></div>")
		w = width ? width : 600;
		h = height ? height : $j(window).height()-50;
		$j("body").prepend(fcDialog);
		$j(fcDialog).dialog({
			bgiframe: true,
			modal: true,
			title:title,
			width: w,
			height: h,
			close: function(event, ui) {
				$j(fcDialog).dialog( 'destroy' );
				$j(fcDialog).remove();
			}
			
		});
		$j(fcDialog).dialog('open');
		$j('iframe',$j(fcDialog)).attr('src',url);
	};		
	</cfoutput>
</skin:onReady>

<ft:form>
<cfoutput>
<div id="tabs" style="width:100%;height:100%;">
	<ul>
		<li><a href="##tabs-1">Approved</a></li>
		<li><a href="##tabs-2">Draft</a></li>
	</ul>
	<div id="tabs-1">
		<ft:buttonPanel style="margin:0px;padding:2px;">
			<ft:button value="edit" />
			<ft:button value="delete" />
			<ft:button value="approve" />
		</ft:buttonPanel>
		
		
		<dl class="dl-style1" style="padding: 10px;font-size:11px;">
			<dt>Label</dt>
			<dd>#stobj.label#</dd>
			
			<cfif structKeyExists(stobj, "displayMethod")>
				<dt>Display Method</dt>
				<dd>#stobj.displayMethod#</dd>
			</cfif>
			<cfif structKeyExists(stobj, "teaser")>
				<dt>Teaser</dt>
				<dd>#stobj.teaser#</dd>
			</cfif>
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<dt>Friendly URL <a onclick="$fc.openDialogIFrame('Manage Friendly URL\'s for #stobj.label# (#stobj.typename#)', '#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-pencil" style="float:right;">&nbsp;</span></a></dt>
				<dd>#application.fapi.fixURL(application.fc.factory.farFU.getFU(objectid="#stobj.objectid#", type="#stobj.typename#"))#</dd>
			</cfif>
		</dl>
		
		
		
		<ul style="float:left;">
			<cfif application.security.checkPermission("ModifyPermissions") and listcontains(application.fapi.getPropertyMetadata(typename="farBarnacle", property="referenceid", md="ftJoin", default=""), stObj.typename)>
				<!--- <ft:button width="240px" style="" type="button" value="Manage Permissions" rbkey="workflow.buttons.managepermissions" onclick="window.location='#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions&ref=#url.ref#';" /> --->
				<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialogIFrame('Permissions', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Permissions</a></li>
			</cfif>	
			<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Statistics', '#application.url.farcry#/edittabStats.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Statistics</a></li>
			<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Audit', '#application.url.farcry#/edittabAudit.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Audit</a></li>
			<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Archive', '#application.url.farcry#/archive.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Archive</a></li>
			<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>Comments</a></li>
			<li style="display:block;padding-left:0px;background:none;"><a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#')"><span class="ui-icon ui-icon-newwin" style="float:left;">&nbsp;</span>System Properties</a></li>
		</ul>
		
		<br style="clear:both;" />
		
		
	</div>
	
	<div id="tabs-2">
		
	</div>
</div>

</cfoutput>
</ft:form>
<!--- 
	<extjs:layout id="webtopOverviewViewport" container="Viewport" layout="border">
		<extjs:item region="center" container="TabPanel" activeTab="0">
			
			<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />
			
			<cfif StructKeyExists(stobj,"status")>
			
				<cfif len(stobj.status)>
					<cfset mainTabStatus = stobj.status />
				<cfelse>
					<cfset mainTabStatus = "NO STATUS" />
				</cfif>
				
				
				
						

						
				<cfif stobj.status NEQ "" AND NOT structIsEmpty(stDraftObject)>
					<extjs:item title="#application.rb.getResource('workflow.constants.#stDraftObject.status#@label',stDraftObject.status)#" container="Panel" layout="border">

 						<extjs:item region="center" container="Panel" layout="border">			
							<extjs:item region="center" autoScroll="true">
				
								<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stDraftObject.objectid#", referenceTypename="#stDraftObject.typename#") />
								<cfoutput>#workflowHTML#</cfoutput>
								<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewSummary" />
							</extjs:item>
						</extjs:item>	
						<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
							<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewActions" />
						</extjs:item>
							

						
					</extjs:item>
				</cfif>	
			<cfelse>
				<cfset mainTabStatus = "Approved/Live" />
			</cfif>
			

	
							
			<extjs:item title="#application.rb.getResource('workflow.constants.#mainTabStatus#@label',mainTabStatus)#" container="Panel" layout="border">
				<extjs:item region="center" container="Panel" layout="border">			
					<extjs:item region="center" autoScroll="true">
						<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
						<cfoutput>#workflowHTML#</cfoutput>
						<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
					</extjs:item>
				</extjs:item>			
				<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
					<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewActions" />
				</extjs:item>	
				
				
			</extjs:item>
		</extjs:item>		
	</extjs:layout>
 --->
</cfif>


<cfsetting enablecfoutputonly="false">

