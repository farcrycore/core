<!------------------------------------------------------------------------
findType() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/core/packages/fourq/_fourq/findType.cfm,v 1.8 2003/09/12 06:41:24 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 06:41:24 $
$Name:  $
$Revision: 1.8 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Function to lookup the type of a given objectid
------------------------------------------------------------------------->

<!--- 
DEPRECATED -> moved code into the fourq.cfc

<cfquery datasource="#arguments.dsn#" name="qgetType">
select typename from refObjects
where objectID = '#arguments.objectID#'
</cfquery>

<cfif NOT len(qgetType.typename)>
	<cfabort showerror="<b>Invalid reference:</b> object #arguments.objectID# is not in reObjects table">
</cfif>

<cfset r_typename = qgetType.typename>

 --->
