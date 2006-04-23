<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit/categories.cfm,v 1.7 2005/09/02 05:11:44 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:11:44 $
$Name: milestone_3-0-0 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: dmXMLExport Type PLP for edit handler - Categorisation Step $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
<cfparam name="lSelectedCategoryID" default="">

<cfif isDefined("form.bSubmitted")>
	<cfparam name="form.lSelectedCategoryID" default="">
	<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
		<cfinvokeargument name="objectID" value="#output.objectID#"/>
		<cfinvokeargument name="lCategoryIDs" value="#form.lSelectedCategoryID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
<cfelse>
	<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
		<cfinvokeargument name="objectID" value="#output.objectID#"/>
		<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
	</cfinvoke>
</cfif>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>
	
<widgets:plpAction>

<cfif NOT thisstep.isComplete>

<widgets:plpWrapper>

<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
<h3>#application.adminBundle[session.dmProfile.locale].categories#</h3>
<widgets:categoryAssociation typeName="#output.typename#" lSelectedCategoryID="#lSelectedCategoryID#">

	<input type="hidden" name="bSubmitted" value="1"/>
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form></cfoutput>

</widgets:plpWrapper>

<cfelse>
	<widgets:plpUpdateOutput>
</cfif>