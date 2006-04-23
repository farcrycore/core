<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/metadata.cfm,v 1.2 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmEvent Edit PLP - Categorisation Step $
$TODO:$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">

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
<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lCategegoryIds">
	<cfinvokeargument name="objectID" value="#output.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>	


<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">Categories</div>

<div class="FormTableClear">
	<form action="" method="post">
	<table align="center">
	<tr><td><div  id="tree">
			<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
	    		<cfinvokeargument name="bShowCheckBox" value="true"> 
				<cfinvokeargument name="lSelectedCategories" value="#lCategegoryIds#">
	   	   	</cfinvoke>
			</div>
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
</cfoutput>
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>


