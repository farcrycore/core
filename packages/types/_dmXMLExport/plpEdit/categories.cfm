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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmXMLExport/plpEdit/categories.cfm,v 1.7 2005/09/02 05:11:44 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:11:44 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: dmXMLExport Type PLP for edit handler - Categorisation Step $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
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
<h3>#application.rb.getResource("categories")#</h3>
<widgets:categoryAssociation typeName="#output.typename#" lSelectedCategoryID="#lSelectedCategoryID#">

	<input type="hidden" name="bSubmitted" value="1"/>
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form></cfoutput>

</widgets:plpWrapper>

<cfelse>
	<widgets:plpUpdateOutput>
</cfif>