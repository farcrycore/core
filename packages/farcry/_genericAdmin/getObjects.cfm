<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_genericAdmin/getObjects.cfm,v 1.5 2003/03/19 00:38:48 geoff Exp $
$Author: geoff $
$Date: 2003/03/19 00:38:48 $
$Name: b131 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: get objects recordset for genericAdmin $
$TODO: I don't think this component should exist -- we need to think 
harder about how to get multiple objects of same type. GB $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendon@daemon.com.au) $
--->

<cfquery name="qGetObjects" datasource="#stArgs.dsn#">
	select type.objectid, type.title, type.locked, type.lockedby, type.status
		<cfif structKeyExists(application.types['#stArgs.typename#'].stProps,"publishDate")>
			, type.publishdate
		</cfif>
		, type.datetimelastupdated, type.lastupdatedby, type.label
	<!--- check if restricted by categories --->
	<cfif isdefined("stArgs.lCategories")>
		from #application.dbowner#refObjects refObj 
		join #application.dbowner#refCategories refCat ON refObj.objectID = refCat.objectID
		join #application.dbowner##stArgs.typename# type ON refObj.objectID = type.objectID  
		where refObj.typename = '#stArgs.typename#' AND refCat.categoryID IN ('#ListChangeDelims(stArgs.lCategories,"','",",")#') AND
	<cfelse>
		FROM #application.dbowner##stArgs.typename# type
		WHERE 
	</cfif>
	<!--- check if restricted by status --->
	<cfif (stArgs.Status IS "all")>
		type.status IN ('draft','approved','declined','pending')
	<cfelse>
		type.status = '#stArgs.Status#'
	</cfif>
	ORDER BY type.#stArgs.order# #stArgs.orderDirection#
</cfquery>