<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/plpEdit/categories.cfm,v 1.6 2004/03/24 06:50:52 paul Exp $
$Author: paul $
$Date: 2004/03/24 06:50:52 $
$Name: milestone_2-2-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: dmFacts Type PLP for edit handler - Categorisation Step $
$TODO: clean-up whitespace handling, and formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfif isDefined("form.submit") OR isDefined("form.back")>
	
	<cfparam name="form.categoryid" default="">
	<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
		<cfinvokeargument name="objectID" value="#output.objectID#"/>
		<cfinvokeargument name="lCategoryIDs" value="#form.categoryID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
</cfif>		

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>
	
<tags:plpNavigationMove>

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div></cfoutput>
<div class="FormTitle">Categories</div>

<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lCategoryIds">
	<cfinvokeargument name="objectID" value="#output.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>	

<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">

	<table style="margin-left:50px;" >
		<tr>
			<td id="tree">
			<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
    			<cfinvokeargument name="bShowCheckBox" value="true"> 
				<cfinvokeargument name="lSelectedCategories" value="#lCategoryIds#">
	   	   	</cfinvoke>
			</td>
		</tr>
		<tr>
			<td>
				<tags:plpNavigationButtons>
			</td>
		</tr>
		
	</table>
</form>
<!--- <cfdump var="#output#"> --->
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>



