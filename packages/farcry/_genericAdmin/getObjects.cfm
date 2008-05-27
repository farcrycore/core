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
$Header: /cvs/farcry/core/packages/farcry/_genericAdmin/getObjects.cfm,v 1.15 2004/09/02 03:49:23 paul Exp $
$Author: paul $
$Date: 2004/09/02 03:49:23 $
$Name: milestone_3-0-1 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: get objects recordset for genericAdmin $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendon@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
--->


<cfparam name="arguments.criteria.order" default="datetimecreated">
<cfparam name="arguments.criteria.orderDirection" default="desc">
<cfscript>
	sql = "select type.*";
	// check if restricted by categories 
	if (isdefined("arguments.criteria.lCategories"))
	{
		sql = sql & " from #application.dbowner#refObjects refObj";
		sql = sql & " join #application.dbowner#refCategories refCat ON refObj.objectID = refCat.objectID";
		sql=sql & " join #application.dbowner##arguments.typename# type ON refObj.objectID = type.objectID";  
		sql = sql & " where refObj.typename = '#arguments.typename#' AND refCat.categoryID IN ('#ListChangeDelims(arguments.criteria.lCategories,"','",",")#')";
	}		
	else
		sql = sql & " FROM #application.dbowner##arguments.typename# type WHERE 1=1";
	
	// check if restricted by status 
	if (isdefined("arguments.criteria.currentStatus"))
	{
		if(structKeyExists(application.types[arguments.typename].stProps,'status'))
		{
			if (arguments.criteria.currentStatus IS "all")
				sql = sql & " and type.status IN ('draft','approved','declined','pending')";
			else
				sql = sql & " and type.status = '#arguments.criteria.currentStatus#'";
		}		
	}
	//check for filter --->
	if (isdefined("arguments.criteria.filter") AND len(trim(arguments.criteria.searchtext)))
	{
		if (arguments.criteria.filterType eq "exactly")
			sql = sql & " and #arguments.criteria.filter# = '#arguments.criteria.searchText#'";
		else
			sql = sql & " and #arguments.criteria.filter# like '%#arguments.criteria.searchText#%'";
	}
	
	// check for customfilter
	if (isDefined("arguments.criteria.customfilter"))
		sql = sql & " " & arguments.criteria.customfilter;

	if (isDefined("arguments.criteria.objectid"))
		sql = sql & " and objectid = '#arguments.criteria.objectid#'";
	sql = sql & " ORDER BY type.#arguments.criteria.order# #arguments.criteria.orderDirection#";

</cfscript>
<cfquery name="qGetObjects" datasource="#arguments.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>
