<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/metadata.cfm,v 1.12 2005/06/11 07:55:24 geoff Exp $
$Author: geoff $
$Date: 2005/06/11 07:55:24 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: dmNews Edit PLP - Categorisation Step $
$TODO: Clean-up whitespace management & formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">

<cfif isDefined("form.bSubmitted")>
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
<!--- get the categoryids for this content item --->
<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lCategoryIds">
	<cfinvokeargument name="objectID" value="#output.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>	

<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].categories#</div>

<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<input type="hidden" name="bSubmitted" value="1"/>
	<table>
		<tr>
			<td><div  id="tree">
				<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
					<cfinvokeargument name="bShowCheckBox" value="true"> 
					<cfinvokeargument name="lSelectedCategories" value="#lCategoryIds#">
				</cfinvoke>
				</div>
			</td>
		</tr>
		<tr>
			<td>
				<tags:plpNavigationButtons>
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>