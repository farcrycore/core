<!------------------------------------------------------------------------
alterType() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/alterType.cfm,v 1.11 2004/09/27 04:33:46 daniela Exp $
$Author: daniela $
$Date: 2004/09/27 04:33:46 $
$Name:  $
$Revision: 1.11 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Not quite done yet...
------------------------------------------------------------------------->
<!--- 
This could be a nightmare trying to finesse column details
might be ok for basic table types and to help build array tables etc
here's a start afore i decided to do something more useful :-)
 --->

<cfset md = getMetaData(this)>
<!--- get table name for db schema deployment --->
<cfset tablename = ListLast(md.name, ".")>
<cfif tablename eq "4q" or tablename eq "fourq">
	<cfabort showerror="Error: you cannot deploy base CFC.">
</cfif>

<cfscript>
// cfc property type to db data type translation
	switch(arguments.dbtype){
		case "ora":
		{
			db.boolean = "NUMBER(1)";
			db.date = "DATE";
			db.integer = "INTEGER";
			db.numeric = "NUMBER";			
			db.string = "VARCHAR2(255)";
			db.nstring = "NVARCHAR2(255)";
			db.uuid = "VARCHAR2(50)";
			db.variablename = "VARCHAR2(64)";
			db.color = "VARCHAR2(20)";
			db.email = "VARCHAR2(255)";
			db.longchar = "NCLOB";
			break;
		}
		case "mysql":
		{
			db.boolean = "INT";
			db.date = "DATETIME";
			db.integer = "INT";
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "LONGTEXT";	
			break;
		}
		case "postgresql":
		{
			db.boolean = "INT";
			db.date = "TIMESTAMP";
			db.integer = "INTEGER";			
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "TEXT";	
			break;
		}
		default:
		{	
			db.boolean = "[int]";
			db.date = "[DATETIME]";
			db.integer = "INT";			
			db.numeric = "[NUMERIC]";
			db.string = "[VARCHAR] (255)";
			db.nstring = "[NVARCHAR] (512)";
			db.uuid = "[VARCHAR] (50)";
			db.variablename = "[VARCHAR] (64)";
			db.color = "[VARCHAR] (20)";
			db.email = "[VARCHAR] (255)";
			db.longchar = "[NTEXT]";
            break;
		}
	}	
</cfscript>

<cfsetting enablecfoutputonly="Yes">
<cfsavecontent variable="sql">
<cfoutput>
ALTER TABLE #arguments.dbowner##tablename#
(</cfoutput>
	<cfloop from=1 to="#arraylen(md.properties)#" index="prop">
	<cfif not structKeyExists(md.properties[prop],'makeCol')>
		<cfset md.properties[prop].makeCol = true>
	</cfif>
	<cfif md.properties[prop].required>
		<cfset nullable = "NOT NULL">
	<cfelse>
		<cfset nullable = "NULL">
	</cfif>
	<cfif md.properties[prop].makeCol>
	<cfoutput>[#md.properties[prop].name#] #db[md.properties[prop].type]# #nullable#,
</cfoutput>
	</cfif>
</cfloop>
<cfoutput>);</cfoutput>
</cfsavecontent>
<cfsetting enablecfoutputonly="no">

<cfquery datasource="#arguments.dsn#" name="qExists">
select * from dbo.sysobjects where id = object_id(N'[dbo].[#tablename#]')
</cfquery>


<cfparam name="args.testrun" default="false" type="boolean">
<cfif NOT args.testrun AND isDefined('qExists.recordCount') and qExists.recordcount>
	<cfquery datasource="#arguments.dsn#">
	#sql#
	</cfquery>
	<cfset stReturn.message = "Type modified successfully">
	<cfset stReturn.bSuccess = true>
<cfelse>
	<cfset stReturn.message = "A table with that name does not exist.">
	<cfset stReturn.bSuccess = false>
</cfif>

<cfoutput>
<pre>
#sql#
</pre>
</cfoutput>