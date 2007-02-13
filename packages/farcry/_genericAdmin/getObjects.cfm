<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
