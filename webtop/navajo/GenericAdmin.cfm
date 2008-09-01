<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
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
$Header: /cvs/farcry/core/webtop/navajo/GenericAdmin.cfm,v 1.26 2004/07/15 01:51:08 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:08 $
$Name: milestone_3-0-1 $

|| DESCRIPTION || 
$Description: calls generic admin for all types. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: [url.typename]: object type $
--->

<!--- required variables --->
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfif not IsDefined("url.typename")>
	<cfoutput>
	#application.rb.getResource("errorMissingTypeName")#
	</cfoutput>
	<cfabort>
</cfif>

<cfscript>
/*
 build stGrid for core content types
*/
	if (isDefined('URL.objectid'))
		form.objectid = url.objectid;	
	typename = "#URL.typeName#";
	stGrid = structNew();
	stGrid.typename = URL.typename;
	switch(typename)
	{
		case 'dmNews':
			permissionType = 'news';
			break;
		case 'dmEvent':
			permissionType = 'event';
			break;
		case 'dmLink':
			permissionType = 'link';
			break;	
		case 'dmFacts':
			permissionType = 'fact';
			break;	
		default:
			permissionType = 'news';
			break;
				
	}		
	stGrid.permissionType = permissionType;
	
	// check for edit permission
	iObjectEditPermission = application.security.checkPermission(permission="#stGrid.permissionType#Edit");		
	
	stGrid.finishURL = "#application.url.farcry#/navajo/GenericAdmin.cfm?type=#permissionType#&typename=#typename#"; //this is the url you will end back at after add/edit operations.
	//stGrid.approveURL = "#cgi.server_name#/farcry/index.cfm?section=Dynamic";
	
	stGrid.aTable = arrayNew(1);
	st = structNew();
	//select
	
	st.columnType = 'expression'; 
	st.heading = '#application.rb.getResource("select")#';
	st.value = "<input type=""checkbox"" name=""objectid"" value=""##recordset.objectid##"">";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("edit")#';
	st.align = "center";
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0""></a>'))),DE('<img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0"">'))";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("view")#';
	st.align = "center";
	st.columnType = 'expression'; 
	st.value = "<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" border=""0""></a>";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("stats")#';
	st.align = 'center';
	st.columnType = 'expression'; 
	st.value = "<a href=""javascript:void(0);"" onclick=""window.open('#application.url.farcry#/edittabStats.cfm?objectid=##recordset.objectid##','Stats','scrollbars,height=600,width=620');""><img src=""#application.url.farcry#/images/treeImages/stats.gif"" border=""0""></a>";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("label")#';
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq 'application.security.getCurrentUserID()',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))),DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'))";
	st.align = "left";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("status")#';
	st.columnType = 'expression'; //this will default to objectid of row. 
	st.value = "##status##";
	st.align = "center";
	arrayAppend(stGrid.aTable,st);
		
	st = structNew();
	st.heading = '#application.rb.getResource("lastUpdated")#';
	st.columnType = 'eval'; //this will default to objectid of row. 
	st.value = "application.thisCalendar.i18nDateFormat('##datetimelastupdated##',session.dmProfile.locale,application.mediumF)";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.rb.getResource("by")#';
	st.columnType = 'expression'; //this will default to objectid of row. 
	st.value = "##lastupdatedby##";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);
			
	if (typename IS 'dmnews')
	{
	st = structNew();
	st.heading = '#application.rb.getResource("publishDate")#';
	st.columnType = 'eval'; //this will default to objectid of row. 
	st.value = "application.thisCalendar.i18nDateFormat('##publishdate##',session.dmProfile.locale,application.mediumF)";
	arrayAppend(stGrid.aTable,st);
	
	}
</cfscript>	

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<!--- javascript routines used to integrate global image and file libraries --->
<cfoutput>
<script>
if (parent.frames['treeFrame'].location.href.indexOf('dynamicMenuFrame.cfm') < 0)
{
	parent.frames['treeFrame'].location.href='#application.url.farcry#/dynamic/dynamicMenuFrame.cfm?type=general';
	em = parent.document.getElementById('subTabArea');
	for (var i = 0;i < em.childNodes.length;i++)
	{
		parent.document.getElementById(em.childNodes[i].id).style.display = 'inline';	
	}
	parent.document.getElementById('DynamicFileTab').style.display ='none';
	parent.document.getElementById('DynamicImageTab').style.display ='none';
}	
</script>
</cfoutput>

<farcry:genericAdmin 
	permissionType="#stGrid.permissionType#"
	typename="#typename#"
	stGrid="#stGrid#">

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">
