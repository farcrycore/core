<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/plpEdit/categories.cfm,v 1.4 2003/12/15 18:20:12 tom Exp $
$Author: tom $
$Date: 2003/12/15 18:20:12 $
$Name: milestone_2-1-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmFacts Type PLP for edit handler - Categorisation Step $
$TODO: clean-up whitespace handling, and formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
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
	oCat = createObject("component","#application.packagepath#.farcry.category");
</cfscript>

<cfswitch expression="#action#">
	<cfcase value="updateMetaData">
		<cfparam name="form.categoryid" default="">
		<!--- <cfdump var="#form#"> --->
		<cfscript>
			stStatus = oCat.assignCategories(objectID=output.objectID,lCategoryIDs=form.categoryID,dsn=application.dsn);
		</cfscript>
		<cfset message = stStatus.message>
	</cfcase>
	<cfdefaultcase>
		<cfset bComplete = true>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>		

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div></cfoutput>
<div class="FormTitle">Categories</div>

<cfscript>
	lCategoryIds = oCat.getCategories(objectID=output.objectID,bReturnCategoryIDs=true);
</cfscript>
<!--- <cfdump var="#lCategoryIds#"> --->


<div align="center" class="FormTableClear">
<form action="" method="post">
	<table align="center"><tr><td id="tree">

		<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
    		<cfinvokeargument name="bShowCheckBox" value="true"> 
			<cfinvokeargument name="lSelectedCategories" value="#lCategoryIds#">
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



