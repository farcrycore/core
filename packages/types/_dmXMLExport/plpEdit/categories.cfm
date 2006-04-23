<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit/categories.cfm,v 1.1 2003/07/18 07:31:47 brendan Exp $
$Author: brendan $
$Date: 2003/07/18 07:31:47 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmXMLExport Type PLP for edit handler - Categorisation Step $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfscript>
	/*this page has a number of different form postings. establishing what action to take
	based on the form submitted*/ 
	if (isDefined("form.apply"))
		action = 'updateMetadata';
	else
		action = 'normal';
	thisstep.isComplete = 0;
	thisstep.name = stplp.currentstep;	
</cfscript>

<cfswitch expression="#action#">
	<cfcase value="updateMetaData">
		<cfparam name="form.categoryid" default="">
		<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
			<cfinvokeargument name="objectID" value="#output.objectID#"/>
			<cfinvokeargument name="lCategoryIDs" value="#form.categoryID#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
		<cfset message = stStatus.message>
	</cfcase>
	<cfdefaultcase>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>		

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div></cfoutput>
<div class="FormTitle">Categories</div>

<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lCategegoryIds">
	<cfinvokeargument name="objectID" value="#output.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>	

<div align="center" class="FormTableClear">
<form action="" method="post">
	<table align="center"><tr><td id="tree">

		<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
    		<cfinvokeargument name="bShowCheckBox" value="true"> 
			<cfinvokeargument name="lSelectedCategories" value="#lCategegoryIds#">
   	   	</cfinvoke>
</td></tr>
<tr>
	<td>
		<input type="Submit" name="apply" value="Apply Categories" class="normalbttnstyle">
	</td>
</tr></table>
</form>				

</div>

<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<tags:plpNavigationButtons>
</form>
</div>

<!--- <cfdump var="#output#"> --->
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>



