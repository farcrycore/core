<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/scheduledTasks.cfm,v 1.10 2005/09/15 04:40:32 daniela Exp $
$Author: daniela $
$Date: 2005/09/15 04:40:32 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Manages scheduled tasks $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $


|| ATTRIBUTES ||
--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmCron">

<!--- set up page header --->
<admin:header title="Scheduled Tasks" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

	<!--- set grid to display user details output --->
	<cfscript>
		aGridColumns=arrayNew(1);
		//select
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].select#";
		stCol.columnType = "expression"; 
		stCol.value = "<input type=""checkbox"" name=""objectid"" value=""##recordset.objectid##"">";
		stCol.style="text-align: center;";
		arrayAppend(aGridColumns,stCol);
		
		//edit	
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].edit#";
		stCol.columnType="evaluate";
		stCol.value = "iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0""></a>'))";
		stCol.style="text-align: center;";
		arrayAppend(aGridColumns,stCol);
	
		// run
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].runTask#";
		stCol.columnType = "expression"; 
		stCol.value = "<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&##recordset.parameters##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" border=""0""></a>";
		stCol.style="text-align: center;";
		arrayAppend(aGridColumns,stCol);
		
		//label
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].label#";
		stCol.columnType="evaluate";
		stCol.value="iif(locked and lockedby neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))";
		stCol.style="text-align: left;";
		arrayAppend(aGridColumns,stCol);
		
		// last updated date
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#";
		stCol.columnType="evaluate";
		stCol.value="application.thisCalendar.i18nDateFormat('##datetimelastupdated##',session.dmProfile.locale,application.mediumF)";
		stCol.style="text-align: center;";
		arrayAppend(aGridColumns,stCol);
		
		// last updated by
		stCol=structNew();
		stCol.title="#application.adminBundle[session.dmProfile.locale].by#";
		stCol.columnType = "expression"; 
		stCol.value = "##lastupdatedby##";
		stCol.style="text-align: center;";
		arrayAppend(aGridColumns,stCol); 
	</cfscript>

<widgets:typeadmin 
	typename="dmCron"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].ScheduledTasksAdministration#"
	aColumns="#aGridColumns#"
	bdebug="0">
	
</widgets:typeadmin>

<admin:footer>

