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
setData() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/setData.cfm,v 1.20 2004/10/15 04:50:58 paul Exp $
$Author: paul $
$Date: 2004/10/15 04:50:58 $
$Name:  $
$Revision: 1.20 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Set method to update a record instance in the COAPI
------------------------------------------------------------------------->
<cfprocessingdirective pageencoding="utf-8">

<cfscript>
	// get table name for db schema
	tablename =  getTablename();
	// get extended properties for this instance
	stProps = variables.tableMetadata.getTableDefinition();
</cfscript>

<!--- check objectid passed --->
<cfif IsDefined("arguments.stProperties.objectid")>
	<cfset objectid=arguments.stProperties.objectid>
<cfelseif IsDefined("arguments.objectid")>
	<cfset objectid=arguments.objectid>
<cfelse>
	<cfabort showerror="Error: You must pass the objectid as an argument or part of the stProperties structure.">
</cfif>

<!--- build query --->
<cftry>
<cfquery datasource="#arguments.dsn#" name="qSetData">
	UPDATE #arguments.dbowner##tablename#
	SET objectID = <cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
	<!--- 
	loop through introspected properties 
	 - that way incorrectly specified properties are ignored
	--->	
	<cfloop collection="#stProps#" item="prop">
		<cfset propertyname = stProps[prop].name>
		<!--- check to see if property has been passed for update --->
		<cfif StructKeyExists(arguments.stProperties, propertyName) AND propertyName neq "ObjectID">
			<cfset propertyValue = arguments.stProperties[propertyName]>
			<!--- determine sql treatment --->
			<cfswitch expression="#stProps[prop].type#">
			
				<cfcase value="date">
					<cfif IsDate(propertyValue)>
						, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_TIMESTAMP">
					<cfelseif NOT IsDate(propertyValue) AND stProps[prop].required EQ "no">
						, #propertyName# = ''
					<cfelse>
						<cfabort showerror="Error: #propertyName# must be a date (#propertyValue#).">
					</cfif>
				</cfcase>
				
				<cfcase value="array">
					<!--- Check if there is actually an array with values --->
					<cfif isArray(propertyvalue)>
						<!--- delete existing array data --->
						<cfquery datasource="#arguments.dsn#" name="qDeleteArray">
							DELETE FROM #arguments.dbowner##tablename#_#propertyname# 
							WHERE objectid = <cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
						 </cfquery>
									
						<!--- Loop over the array elements for this array property --->
						<cfloop from="1" to="#arraylen(propertyvalue)#" index="j">
							<cfquery datasource="#arguments.dsn#" name="qAddArrayData">
								INSERT INTO #arguments.dbowner##tablename#_#propertyname#
								(objectid,seq,data)
								Values
								('#objectid#',#j#,<cfqueryparam value="#propertyValue[j]#" cfsqltype="CF_SQL_VARCHAR">)
							 </cfquery>
						</cfloop>
					</cfif> 
				</cfcase>
				
				<cfcase value="integer">
					, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_INTEGER" />
				</cfcase>
				
				<cfcase value="numeric">
					, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_FLOAT">
				</cfcase>				
				
				<cfcase value="boolean">
					<cfset propertyValue = YesNoFormat(propertyValue)>
					<cfif propertyValue eq "Yes">
						<cfset propertyValue = 1>
					<cfelseif propertyValue eq "No">
						<cfset propertyValue = 0>
					</cfif>
					, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_INTEGER" maxlength="1">
				</cfcase>
				
				<cfcase value="longchar">
					<cfif arguments.dbtype eq "ora">
						, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_CLOB">
					<cfelse>
						, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_LONGVARCHAR">
					</cfif>
				</cfcase>
				
				<cfdefaultcase>
					<!--- string data --->
					, #propertyName# = <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_VARCHAR">
				</cfdefaultcase>
				
			</cfswitch>
		</cfif>
	</cfloop>
	WHERE objectID = <cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfcatch>
	<cfrethrow>
	<!---
	<cfset setDataResult.bSuccess = false>
	<cfset setDataResult.message = cfcatch.message>
	--->
</cfcatch>
</cftry>
