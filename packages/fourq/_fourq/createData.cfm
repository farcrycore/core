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
createData() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/createData.cfm,v 1.22 2004/10/15 04:50:10 paul Exp $
$Author: paul $
$Date: 2004/10/15 04:50:10 $
$Name:  $
$Revision: 1.22 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Create a record instance for a content object and a corresponding 
entry in the refObjects table
------------------------------------------------------------------------->
<cfprocessingdirective pageencoding="utf-8">

<cfscript>
// get table name for db schema
	tablename=getTablename();
// get extended properties for this instance
	aProps=getProperties();
</cfscript>

<!--- check objectid passed --->
<cfif IsDefined("arguments.stProperties.objectid")>
	<cfset objectid=arguments.stProperties.objectid>
<cfelseif IsDefined("arguments.objectid")>
	<cfset objectid=arguments.objectid>
<cfelse>
	<cfset objectid = CreateUUID()>
</cfif>

<!--- build query --->
<cftransaction>

<cftry>

	<cfquery datasource="#arguments.dsn#" name="qCreateData">
		INSERT INTO #arguments.dbowner##tablename# ( 
			objectID
		<!--- 
		loop through introspected properties 
		 - that way incorrectly specified properties are ignored
		--->	
		<cfloop from="1" to="#ArrayLen(aProps)#" index="i">
			<cfset propertyName = aProps[i].name>
			<!--- check to see if property has been passed for insert --->
			<cfif StructKeyExists(arguments.stProperties, propertyName) AND propertyName neq "ObjectID" AND aProps[i].type neq "array">
				, #propertyName#
			</cfif>
		</cfloop>
		)
		VALUES ( 
			<cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
		<!--- 
		loop through introspected properties 
		 - that way incorrectly specified properties are ignored
		--->	
		<cfloop from="1" to="#ArrayLen(aProps)#" index="i">
			<cfset propertyname = aProps[i].name>
			<!--- check to see if property has been passed for update --->
			<cfif StructKeyExists(arguments.stProperties, propertyName) AND propertyName neq "ObjectID">
				<cfset propertyValue = arguments.stProperties[propertyName]>
				<!--- determine sql treatment --->
				<cfswitch expression="#aProps[i].type#">
				
					<cfcase value="date">
						<cfif IsDate(propertyValue)>
							, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_TIMESTAMP">
						<cfelseif NOT IsDate(propertyValue) AND aProps[i].required EQ "no">
							, ''
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
									INSERT INTO #arguments.dbowner##tablename#_#propertyname# (
										objectid,
										seq,
										data
									)
									VALUES (
										<cfqueryparam value="#objectid#" cfsqltype="CF_SQL_VARCHAR">,
										<cfqueryparam value="#j#" cfsqltype="CF_SQL_NUMERIC">,
										<cfqueryparam value="#propertyValue[j]#" cfsqltype="CF_SQL_VARCHAR">
									)
								 </cfquery>
							</cfloop>
						</cfif> 
					</cfcase>
					
					<cfcase value="integer">
						, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_INTEGER" />
					</cfcase>
					
					<cfcase value="numeric">
						, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_FLOAT">
					</cfcase>					
					
					<cfcase value="boolean">
						<cfset propertyValue = YesNoFormat(propertyValue)>
						<cfif propertyValue eq "Yes">
							<cfset propertyValue = 1>
						<cfelseif propertyValue eq "No">
							<cfset propertyValue = 0>
						</cfif>
						, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_INTEGER" maxlength="1">						
					</cfcase>
					
					<cfcase value="longchar">
						<cfif arguments.dbtype eq "ora">
							, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_CLOB">
						<cfelse>
							, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_LONGVARCHAR">
						</cfif>
					</cfcase>
					
					<cfdefaultcase>
						<!--- string data --->
						, <cfqueryparam value="#propertyValue#" cfsqltype="CF_SQL_VARCHAR">
					</cfdefaultcase>
					
				</cfswitch>
			</cfif>
		</cfloop>	
		)			
	</cfquery>
	
	<cfcatch>
		<cfset createDataResult.bSuccess = false>
		<cfset createDataResult.message = "#cfcatch.message#">
		<cfset createDataResult.detail = "#cfcatch.detail#">
		<cfset createDataResult.sql = "#cfcatch.sql#">
		<cfdump var="#createDataResult#">
	</cfcatch>

</cftry>

<!--- create lookup ref for type --->
<cftry>

	<cfquery datasource="#arguments.dsn#" name="qRefData">
		INSERT INTO #arguments.dbowner#refObjects (
			objectID, 
			typename
		)
		VALUES (
			<cfqueryparam value="#objectid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#tablename#" cfsqltype="CF_SQL_VARCHAR">
		)
	</cfquery>
	
	<cfcatch>
		<cfset createDataResult.bSuccess = false>
		<cfset createDataResult.message = "#cfcatch.message#">
	</cfcatch>
	
</cftry>

</cftransaction>

<!--- this is a bit redundant as using createUUID() --->
<cfset primarykey=objectid>