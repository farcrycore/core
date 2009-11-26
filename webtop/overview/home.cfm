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
$Header: /cvs/farcry/core/webtop/overview/home.cfm,v 1.8.2.6 2006/04/14 06:50:41 geoff Exp $
$Author: geoff $
$Date: 2006/04/14 06:50:41 $
$Name: p300_b113 $
$Revision: 1.8.2.6 $

|| DESCRIPTION ||
$Description: FarCry Overview Page $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="Yes" requestTimeOut="200">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<!--- check for customised myFarCry home page --->
<cfif fileexists(application.path.project & "/customadmin/home.cfm")>
    <cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/home.cfm">
<cfelse>
<!--- otherwise use the default myFarCry overview/home page --->

<!--- set up page header --->
<cfparam name="pending_MaxRecords" default="5">
<cfparam name="pending_objectType" default="All">
<cfparam name="draft_MaxRecords" default="5">
<cfparam name="draft_objectType" default="All">

<!--- <cfdump var="#application.types#">
<cfabort>
 --->
<cfset lMaxRecords = "All,5,10,20">
<cfset aObjectTypes = ArrayNew(1)>
<cfloop item="iType" collection="#application.types#">
<!--- 	todo: 
		bad hack.. to get around content types using status as a property but not flagging it as string
		hack allows you to set metadata in the content type of bSystem="true" to exclude it from being addressed here
		need to just rip out this cancer along with farcry.workflow GB 20060414
 --->	
<cfif NOT structKeyExists(application.types[iType],"bSystem")>
		<cfset application.types[iType].bSystem="false">
	</cfif>
    <cfif StructKeyExists(application.types[iType].stProps,"status") AND NOT application.types[iType].bSystem>
        <cfset ArrayAppend(aObjectTypes,iType)>
    </cfif>
</cfloop>

<cfparam name="url.lockedEndRow" default="5">
<cfset application.factory.oWorkFlow = createObject("component","#application.packagepath#.farcry.workflow")>
<cfset returnstruct = application.factory.oWorkFlow.getLockedObjects(application.security.getCurrentUserID())>
<cfif returnstruct.bSuccess>
    <cfset qLockedObjects = returnstruct.qList>
</cfif>

<cfset ArrayPrepend(aObjectTypes,"All")>

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" bDataRequestorJS="true" onload="doToggleContent(document.frm_pending,'pending');doToggleContent(document.frm_draft,'draft');">
<cfoutput>
<script type="text/javascript">
function doToggleContent(objForm,content_status)
{
    strURL = "#application.url.farcry#/includes/generateWorkFlowXML.cfm";
    var req = new DataRequestor();

    objContentType = eval('objForm.' + content_status + '_objectType');
    lcontent_type = objContentType[objContentType.selectedIndex].value;

    objContentMax = eval('objForm.' + content_status + '_maxRecords');
    maxReturnRecords = objContentMax[objContentMax.selectedIndex].value;

    req.addArg(_GET,"content_status",content_status);
    req.addArg(_GET,"lcontent_type",lcontent_type);
    req.addArg(_GET,"maxReturnRecords",maxReturnRecords);
    req.addArg(_GET,"ajaxmode",'true');
    req.onload = processReqChange;
    req.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
    req.getURL(strURL,_RETURN_AS_TEXT);
}

function processReqChange(data, obj)
{
    var returnstruct = JSON.parse(data);
    if(returnstruct.bsuccess)
        updateTbody(returnstruct.content_status,returnstruct.aitems)
    else
        alert(returnstruct.message);
}

function updateTbody(content_status,arItem){
    clearTbody('tbody_' + content_status);
    var mytable = document.getElementById('table_'+ content_status);
    var mytbody = document.getElementById('tbody_' + content_status);
    var myNewtbody = document.createElement("tbody");
    myNewtbody.id = 'tbody_' + content_status;
    var docFragment = document.createDocumentFragment();
    var trElem, tdElem, txtNode;

    if(arItem.length){
        for (var j = 0; j < arItem.length; j++) {
            /*** CREATE TR ***/
            trElem = document.createElement("tr");
            if(Mod(j,2))
                trElem.setAttribute('class','alt');

            /*** CREATE TD ***/
            tdElem = document.createElement("td");
            tdElem.setAttribute('style','text-align: left;');

            /*** SET TD TEXT ***/
            txtNode = document.createTextNode(arItem[j]['text']);
            newA = document.createElement("a");
            newText = document.createTextNode(arItem[j]['text']);
            newA.setAttribute('href',arItem[j]['editurl']);
            newA.appendChild(newText);

            /*** ADD TD TO TR ***/
            tdElem.appendChild(newA);
            trElem.appendChild(tdElem);

            /*** CREATE TD ***/
            tdElem = document.createElement("td");
            tdElem.setAttribute('style','text-align: left;');

            /*** SET TD TEXT ***/
            txtNode = document.createTextNode(arItem[j]['createdby']);
            /*** ADD TD TO TR ***/
            tdElem.appendChild(txtNode);
            trElem.appendChild(tdElem);

            /*** CREATE TD ***/
            tdElem = document.createElement("td");
            tdElem.setAttribute('style','text-align: left;');

            /*** SET TD TEXT ***/
            txtNode = document.createTextNode(arItem[j]['datetimelastupdated']);
            /*** ADD TD TO TR ***/
            tdElem.appendChild(txtNode);
            trElem.appendChild(tdElem);

            docFragment.appendChild(trElem);
        }
    } else {
        /*** CREATE TR ***/
        trElem = document.createElement("tr");

        /*** CREATE TD ***/
        tdElem = document.createElement("td");
        tdElem.setAttribute('colspan','3');
        tdElem.setAttribute('style','text-align: left;');

        txtNode = document.createTextNode('Currently None In [' + content_status + '] Status');

        tdElem.appendChild(txtNode);
        trElem.appendChild(tdElem);
        docFragment.appendChild(trElem);
    }
    myNewtbody.appendChild(docFragment);
    mytable.replaceChild(myNewtbody, mytbody);
}

function clearTbody(content_status) {
    var tbody = document.getElementById(content_status);
    while (tbody.childNodes.length > 0) {
        tbody.removeChild(tbody.firstChild);
    }
}

function Mod(a, b) {
    return a - Math.floor(a / b) * b;
}
</script>

<!--- get objects pending approval --->
<cfset tableStatus_name = "pending">
<cfinclude template="/farcry/core/webtop/includes/overviewStatusTable.cfm">

<!--- get all draft objects --->
<cfset tableStatus_name = "draft">
<cfinclude template="/farcry/core/webtop/includes/overviewStatusTable.cfm">
<!--- get all locked objects --->
<cfif isDefined("qLockedObjects") AND isQuery(qLockedObjects) AND qLockedObjects.recordCount gt 0>
<h3>#application.rb.getResource("workflow.headings.lockedObjects@text","Items you have locked")#</h3>
<br class="clear" />
<table class="objectAdmin" cellspacing="0" id="table_#tableStatus_name#">
<tr>
    <th scope="col">#application.rb.getResource("workflow.labels.contentitem@label","CONTENT ITEM")#</th>
    <th scope="col">#application.rb.getResource("workflow.labels.type@label","TYPE")#</th>
    <th scope="col">#application.rb.getResource("workflow.labels.createdBy@label","CREATED BY")#</th>
    <th scope="col">#application.rb.getResource("workflow.labels.lastUpdated@label","LAST UPDATED")#</th>
    <th scope="col">&nbsp;</th>
</tr><cfloop query="qLockedObjects" startrow="1" endrow="#url.lockedEndRow#">
<tr<cfif (qLockedObjects.currentrow MOD 2)> class="alt"</cfif>>
<!--- <cfif NOT structKeyExists(application.types[qLockedObjects.objectType], "bUseInTree")> --->
    <td><a href="#application.url.farcry#/edittabOverview.cfm?objectid=#qLockedObjects.objectid#&typename=#qLockedObjects.typename#">#qLockedObjects.title#</a></td>

    <!--- <td><a href="#application.url.farcry#/index.cfm?sec=content&objectid=#qLockedObjects.objectid#&status=all" target="_parent">#qLockedObjects.objectTitle#</a></td>
<cfelse>
    <cfif len(qLockedObjects.objectParent)>
    <td><a href="#application.url.farcry#/index.cfm?sec=site&rootobjectid=#qLockedObjects.objectParent#" target="_parent">#qLockedObjects.objectTitle#</a></td>
    <cfelse>
    <td><a href="#application.url.farcry#/index.cfm?sec=content&objectid=#qLockedObjects.objectid#&status=all" target="_parent">#qLockedObjects.objectTitle#</a></td>
    </cfif> --->
<!--- </cfif> --->
    <td>#qLockedObjects.typename#</td>
    <td>#qLockedObjects.createdBy#</td>
    <td>#application.thisCalendar.i18nDateFormat(qLockedObjects.datetimelastupdated,session.dmProfile.locale,application.longF)#</td>
    <td><a href="#application.url.farcry#/navajo/unlock.cfm?objectid=#qLockedObjects.objectid#&typename=#qLockedObjects.typename#&return=home" target="_parent">[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a></td>
</tr></cfloop>
</table>
<!--- show link to all locked Objects --->
<cfif qLockedObjects.recordcount gt url.lockedEndRow>
    <ul><li><strong><a href="#application.url.farcry#/overview/home.cfm?lockedEndRow=#qLockedObjects.recordcount#">#application.rb.getResource("workflow.buttons.showAll@label","Show All")#</a></strong></li></ul>
<cfelseif url.lockedEndRow neq 5>
    <ul><li><strong><a href="#application.url.farcry#/overview/home.cfm?lockedEndRow=5">#application.rb.getResource("workflow.buttons.showRecent5@label","Show most recent 5")#</a></strong></li></ul>
</cfif>
</cfif>
</cfoutput>

<!--- setup footer --->
<admin:footer>
</cfif>
<cfsetting enablecfoutputonly="No">