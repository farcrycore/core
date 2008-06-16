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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
deleteData() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/deleteData.cfm,v 1.10 2003/09/12 06:41:24 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 06:41:24 $
$Name:  $
$Revision: 1.10 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Remove a record instance for a content object and corresponding 
entries in the refObjects and array properties tables
------------------------------------------------------------------------->

<cfscript>
// get table name for db schema
	tablename = arguments.dbowner& this.getTablename();
// get extended properties for this instance
	aProps = this.getProperties();
</cfscript>

<cftransaction>
	<cfquery datasource="#arguments.dsn#" name="qdeleteData">
	DELETE FROM #tablename#
	WHERE objectID = '#arguments.objectID#'
	</cfquery>
	
	<cfquery datasource="#arguments.dsn#" name="qdeleteRefData">
	DELETE FROM #arguments.dbowner#refObjects
	WHERE objectID = '#arguments.objectID#'
	</cfquery>

	<!--- begin: process array data --->
	<cfloop from="1" to="#arraylen(aProps)#" index="i">
		<cfif aProps[i].type eq 'array'>
			<cfquery datasource="#arguments.dsn#" name="qDeleteArrayData">
			DELETE FROM #tablename#_#aProps[i].name#
			WHERE parentid = '#arguments.objectid#'
			</cfquery>
		</cfif>
	</cfloop>
	<!--- end: process array data --->
</cftransaction>

