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
getAll() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/getAll.cfm,v 1.7 2003/09/12 06:41:24 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 06:41:24 $
$Name:  $
$Revision: 1.7 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Deprecate this function...
------------------------------------------------------------------------->
<!--- 
TODO:
this method should not really be in the fourq suite.  Needs to be removed 
post prototyping! A custom tag or something would be better
eg. contentobjectgetmultiple
GB 20020518
got to move metadata into a more persistent scope
 --->
<cfset starttime = gettickcount()>
<cfset md = getMetaData(this)>
<!--- <cfdump var="#md#" expand="no"> 
<cfset exectime = starttime - gettickcount()>
<cftrace inline="#request.debug.trace#" text="getMetaData() exectime: #exectime#">
--->
  
 
<cfscript>
// get table name for db schema
	tablename = this.getTablename();
// get extended properties for this instance
	stProps = variables.tableMetadata.getTableDefinition();
</cfscript>

<cfquery datasource="#arguments.dsn#" name="qgetData">
select * from #tablename#
</cfquery>

<!--- <cfdump var="#qgetData#"> --->
<cfset aObj = ArrayNew(1)>
<cfloop query="qGetData">
<!--- convert query to structure --->
<cfloop list="#qGetData.columnlist#" index="key">
	<cfset stObj[key]= Evaluate("qGetData.#key#")>
</cfloop>
<cfset null = arrayAppend(aObj,duplicate(stObj))>
</cfloop>

<cfset stReturn = structNew()>
<cfset stReturn.aObjects = aObj>

<!--- <cfdump var="#stObj#"> --->

<!--- begin: process array data --->
<!--- determine array properties --->
<cfset lArrayProps="">
<cfloop collection="#stProps#" item="prop">
	<cfif stProps[prop].type contains "array">
		<cfset lArrayProps = listAppend(lArrayProps, stProps[prop].name)>
	</cfif>
</cfloop>

<cfloop from="1" to="#arraylen(aObj)#" index="i">
	<!--- getdata for array properties --->
	<cfif len(lArrayProps)>
		<cfloop list="#lArrayProps#" index="key">
			<cfquery datasource="#arguments.dsn#" name="qArrayData">
			select * from #tablename#_#key#
			where objectid = '#aObj[i].objectID#'
			order by seq
			</cfquery>
		
			<cfset SetVariable("#key#", ArrayNew(1))>
		
			<cfloop query="qArrayData">
				<cfset ArrayAppend(Evaluate(key), qArrayData.data)>
			</cfloop>
		
			<cfset SetVariable("aObj[i]['#key#']", Evaluate(key))>
		</cfloop>
	</cfif>
</cfloop>
<!--- end: process array data --->
<!--- <cfset exectime = starttime - gettickcount()>
<cfoutput>getData() exectime: #exectime#</cfoutput>
<cftrace inline="#request.debug.trace#" text="getData() exectime: #exectime#">
 --->