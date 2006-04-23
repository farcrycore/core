<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_category/Attic/getCategories.cfm,v 1.4 2003/09/17 23:40:47 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 23:40:47 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Return Categories $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- getCategories --->
<cfquery datasource="#application.dsn#" name="qGetCategories">
	SELECT <cfif arguments.bReturnCategoryIDs>cat.categoryID<cfelse>cat.categoryLabel</cfif>
	FROM #application.dbowner#categories cat,#application.dbowner#refCategories ref
	WHERE cat.categoryID = ref.categoryID
	AND ref.objectID = '#arguments.objectID#'
</cfquery> 

<cfif arguments.bReturnCategoryIDs>
	<cfset lCategoryIDs = valueList(qGetCategories.categoryID)>
<cfelse>
	<cfset lCategoryIDs = valueList(qGetCategories.categoryLabel)>
</cfif>	