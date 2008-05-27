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
<!------------------------------------------------------------------------
findType() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/core/packages/fourq/_fourq/findType.cfm,v 1.8 2003/09/12 06:41:24 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 06:41:24 $
$Name:  $
$Revision: 1.8 $

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
