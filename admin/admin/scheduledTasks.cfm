<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/scheduledTasks.cfm,v 1.5 2003/11/03 05:49:40 paul Exp $
$Author: paul $
$Date: 2003/11/03 05:49:40 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Manages scheduled tasks $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $


|| ATTRIBUTES ||
--->

<!--- required variables --->
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>
<cfparam name="url.type" default="news">

<cfset permissionType = "news">

<cfscript>
	typename = "dmCron";
	stGrid = structNew();
	stGrid.finishURL = URLEncodedFormat("#application.url.farcry#/navajo/GenericAdmin&type=dmCron"); //this is the url you will end back at after add/edit operations.
	stGrid.typename = "dmCron";
	
	stGrid.aTable = arrayNew(1);
	st = structNew();
	//select
	st.heading = 'Select';
	st.columnType = 'expression'; 
	st.heading = 'Select';
	st.value = "<input type=""checkbox"" name=""objectid"" value=""##recordset.objectid##"">";
	st.align = "center";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = 'Edit';
	st.align = "center";
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0""></a>'))";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = 'Run Task';
	st.columnType = 'expression'; 
	st.value = "<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&##recordset.parameters##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" border=""0""></a>";
	st.align = "center";
	arrayAppend(stGrid.aTable,st);
		
	st = structNew();
	st.heading = 'Label';
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(locked and lockedby neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))";
	st.align = "left";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = 'Last updated';
	st.columnType = 'eval'; //this will default to objectid of row. 
	st.value = "dateformat('##datetimelastupdated##','dd-mmm-yyyy')";
	st.align='center';
	arrayAppend(stGrid.aTable,st);
	
	
	st = structNew();
	st.heading = 'By';
	st.columnType = 'expression'; //this will default to objectid of row. 
	st.value = "##lastupdatedby##";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);
</cfscript>	
<!--- call generic admin with extrapolation of URL type --->

<farcry:genericAdmin permissionType="#permissionType#"  admintype="#typename#" metadata="True" header="false" typename="#typename#" bDisplayCategories="False" stGrid="#stGrid#">
