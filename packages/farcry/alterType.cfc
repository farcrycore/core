<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/alterType.cfc,v 1.36 2003/12/09 00:39:31 brendan Exp $
$Author: brendan $
$Date: 2003/12/09 00:39:31 $
$Name: milestone_2-1-2 $
$Revision: 1.36 $

|| DESCRIPTION || 
$Description: alter type/rule cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent>
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cffunction name="getDataType">
	<cfargument name="cfctype" required="true">
	<cfargument name="bReturnTypeOnly" required="No" default="false">
	
	<cfscript>
		stDefaultTypes = getTypeDefaults();
		type = stDefaultTypes[arguments.cfctype].type;
		length = stDefaultTypes[arguments.cfctype].length;
		switch (type){
			case "varchar":case "varchar2":case "nvarchar":
			{
				datatype=type;
				if (not arguments.bReturnTypeOnly)
					datatype = datatype & '(#length#)';
				break;
			}
			
			default:{
			datatype = type;
			}
		}
	</cfscript>
	<cfreturn datatype>
</cffunction>

<cffunction name="dropArrayTable">
	<cfargument name="typename" required="true">
	<cfargument name="property" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	
	<cfquery datasource="#arguments.dsn#">
	DROP TABLE #application.dbowner##arguments.typename#_#arguments.property#	
	</cfquery>
</cffunction>

<cffunction name="deployArrayProperty">
	<cfargument name="typename" required="true">
	<cfargument name="property" required="true">
	<cfargument name="scope" required="false" default="types">
	
	<cfscript>
	//tablename = '#arguments.typename#_#arguments.propertyname#';
    if (application[arguments.scope][arguments.typename].bCustomType) "#arguments.typename#" = createObject("component", "#application.custompackagepath#.#arguments.scope#.#arguments.typename#");
    else "#arguments.typename#" = createObject("component", "#application.packagepath#.#arguments.scope#.#arguments.typename#");

	evaluate(arguments.typename).deployArrayTable(bTestRun='0',parent='#application.dbowner##arguments.typename#',property=arguments.property);
	</cfscript>
</cffunction>

<cffunction name="refreshCFCAppData">
	<cfargument name="typename">
	<cfargument name="scope" required="false" default="types">
	
	<cfscript>
	//this now uses type path
	if (arguments.scope IS 'types')
	{
		typePath = application.types[arguments.typename].typePath;
		bCustomType = application.types[arguments.typename].bCustomType;
		"#arguments.typename#" = createObject("component", typePath);
		evaluate(typename).initMetaData("application.types");
		application.types[arguments.typename].bCustomType = bCustomType;	 
		application.types[arguments.typename].typePath = typePath;
		
	}
	else if (arguments.scope IS 'rules')
	{
		rulePath = application.rules[arguments.typename].rulePath;
		bCustomRule = application.rules[arguments.typename].bCustomRule;
		"#arguments.typename#" = createObject("component", rulePath);
		evaluate(typename).initMetaData("application.rules");
		application.rules[arguments.typename].bCustomRule = bCustomRule;	 
		application.rules[arguments.typename].rulePath = rulePath;
		
	}		
	</cfscript>
</cffunction>

<cffunction name="refreshAllCFCAppData">
	<cfargument name="dsn" required="No" default="#application.dsn#">
	<!--- Find all types, base, extended & custom --->
	<cfdirectory directory="#application.path.core#/packages/types" name="qTypesDir" filter="dm*.cfc" sort="name">
	<cfdirectory directory="#application.path.project#/packages/types" name="qCustomTypesDir" filter="*.cfc" sort="name">
	<cfdirectory directory="#application.path.project#/packages/system" name="qExtendedTypesDir" filter="*.cfc" sort="name">
	
	<!--- We want to search NTM types so we can flag them as a bTreeNode. --->
	<cfquery datasource="#arguments.dsn#" name="qNTM">
		SELECT distinct(typename)
		FROM nested_tree_objects
	</cfquery> 
	<cfset lNTMTypes = valueList(qNTM.typename)>
	
	<!--- Init all CORE types --->
	<cfloop query="qTypesDir">
		<cftry>
			<cfscript>
			typename = left(qTypesDir.name, len(qTypesDir.name)-4); //remove the .cfc from the filename
			"#typename#" = createObject("Component", "#application.packagepath#.types.#typename#");
			evaluate(typename).initMetaData("application.types");
			application.types[typename].bCustomType = 0;
			application.types[typename].typePath = "#application.packagepath#.types.#typename#";
			</cfscript>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>	
	<!--- Init all EXTENDED CORE types --->
	<cfloop query="qExtendedTypesDir">
		<cftry>
			<cfscript>
			typename = left(qExtendedTypesDir.name, len(qExtendedTypesDir.name)-4); //remove the .cfc from the filename
			sMetaData = getMetaData(createObject("Component", "#application.custompackagepath#.system.#typeName#"));
			//does this type extend the core type?
			if(sMetaData.extends.name eq "#application.packagepath#.types.#typename#")
			{
				"#typename#" = createObject("Component", "#application.custompackagepath#.system.#typename#");
				evaluate(typename).initMetaData("application.types");
				application.types[typename].bCustomType = 0;
				application.types[typename].typePath = "#application.custompackagepath#.system.#typename#";
			}
			</cfscript>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>	
	<!--- Now init all Custom Types --->
	<cfloop query="qCustomTypesDir">
		<cftry>
			<cfscript>
			typename = left(qCustomTypesDir.name, len(qCustomTypesDir.name)-4); //remove the .cfc from the filename
			"#typename#" = createObject("Component", "#application.custompackagepath#.types.#typename#");
			evaluate(typename).initMetaData("application.types");
			application.types[typename].bCustomType = 1;
			application.types[typename].typePath = "#application.custompackagepath#.types.#typename#";
			</cfscript>
			<cfcatch><cfdump var="#cfcatch#"></cfcatch>
		</cftry>
	</cfloop>
	
	<!--- Now get all the rules --->
	<cfscript>
	rules = createObject("Component", "#application.packagepath#.rules.rules");
	qRules = rules.getRules(); 
	</cfscript>

	<!--- Populate application.rules scope with rule metatdata --->
	<cfloop query="qRules">
		<cfscript>
			
			if(qRules.bCustom)
			{
				sRuleMetaData = getMetaData(createObject("Component", "#application.custompackagepath#.rules.#qRules.rulename#"));
				//does this rule extend the core rule?
				if(sRuleMetaData.extends.name eq "#application.packagepath#.rules.#qRules.rulename#")
				{
					"#qRules.rulename#" = createObject("Component", "#application.custompackagepath#.rules.#qRules.rulename#");
					evaluate(qRules.rulename).initMetaData("application.rules");
					application.rules[qRules.rulename].bCustomRule = 0; //override the bCustomRule attribute
					application.rules[qRules.rulename].rulePath = "#application.custompackagepath#.rules.#qRules.rulename#";
				}
				else
				{
					"#qRules.rulename#" = createObject("Component", "#application.custompackagepath#.rules.#qRules.rulename#");
					evaluate(qRules.rulename).initMetaData("application.rules");
					application.rules[qRules.rulename].bCustomRule = 1;
					application.rules[qRules.rulename].rulePath = "#application.custompackagepath#.rules.#qRules.rulename#";
				}
			
			}
			else
			{
				"#qRules.rulename#" = createObject("Component","#application.packagepath#.rules.#qRules.rulename#");
				evaluate(qRules.rulename).initMetaData("application.rules");
				application.rules[qRules.rulename].bCustomRule = 0; //override the bCustomRule attribute
				application.rules[qRules.rulename].rulePath = "#application.packagepath#.rules.#qRules.rulename#";
			}
		</cfscript>
	</cfloop>
	<cfscript>
		for(type IN application.types)
		{
			if(listContainsNoCase(lNTMTypes,type))
				application.types[type].bTreeNode = 1;
		}
	</cfscript>
	
</cffunction>

<cffunction name="getTypeDefaults" hint="Initialises a reference structure that can be looked up to get default types/lengths for respective DB columns">
	<cfargument name="dbtype" required="false" default="#application.dbtype#">
	<cfscript>
		stPropTypes = structNew();
		switch(arguments.dbtype){
		case "ora":
		{   //todo 
			db.type = 'number';
			db.length = 1;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'date';
			db.length = 7;
			stPropTypes['date'] = duplicate(db);
			//numeric
			db.type = 'number';
			db.length = 22;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar2';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'varchar2';
			db.length = 255;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar2';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar2';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar2';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar2';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);		
			//longchar
			db.type = 'CLOB';
			db.length = 4000;
			stPropTypes['longchar'] = duplicate(db);	
			break;
			
		}
		
		case "mysql":
		{
			//boolean	
			db.type = 'int';
			db.length = 4;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'datetime';
			db.length = 8;
			stPropTypes['date'] = duplicate(db);
			//numeric
			db.type = 'int';
			db.length = 4;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);		
			//longchar
			db.type = 'TEXT';
			db.length = 16;
			stPropTypes['longchar'] = duplicate(db);	
			break;
		}
		
		default:
		{	//boolean	
			db.type = 'int';
			db.length = 4;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'datetime';
			db.length = 8;
			stPropTypes['date'] = duplicate(db);
			//numeric
			db.type = 'numeric';
			db.length = 4;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'nvarchar';
			db.length = 512;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);		
			//longchar
			db.type = 'NTEXT';
			db.length = 16;
			stPropTypes['longchar'] = duplicate(db);	
			break;
		}
		}	
	</cfscript>
	<cfreturn stPropTypes>
</cffunction>

<cffunction name="getArrayTables" hint="Checks to see what array tables exists for a given type">
	<cfargument name="typename" type="string">
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#application.dsn#" name="qArrayTables">
		SELECT 	TABLE_NAME AS name
		FROM USER_TABLES
		WHERE UPPER(TABLE_NAME) LIKE '#ucase(arguments.typename)#@_A%' escape '@'
		</cfquery>
	</cfcase>
	
	<cfcase value="mysql">		
		<cfquery datasource="#application.dsn#" name="qArrayTables1">
		show tables
		</cfquery>	
		
		<cfquery dbtype="query" name="qArrayTables">
		select #qArrayTables1.columnlist# as name
		from qArrayTables1
		where upper(#qArrayTables1.columnlist#) like '#ucase(arguments.typename)#@_A%' escape '@'
		</cfquery>	
	</cfcase>
	
	<cfdefaultcase>	
		<cfquery datasource="#application.dsn#" name="qArrayTables">
		SELECT 	dbo.sysobjects.name
		FROM dbo.sysobjects
		WHERE dbo.sysobjects.name LIKE '#arguments.typename#@_a%' escape '@'
		</cfquery>
	</cfdefaultcase>				
	
	</cfswitch>
	
	<cfreturn qArrayTables>
</cffunction>

<cffunction name="arrayTableExists" hint="Checks to see what array tables exists for a given type">
	<cfargument name="tablename" type="string">
	<cfquery datasource="#application.dsn#" name="qArrayTables">
	SELECT 	dbo.sysobjects.name 
	FROM dbo.sysobjects
	WHERE dbo.sysobjects.name = '#arguments.tablename#'
	</cfquery>

	<cfscript>
	bTableExists = false;
	if (qArrayTables.recordCount) bTableExists = true;
	</cfscript>

	<cfreturn bTableExists>
</cffunction>


<cffunction name="compareDBToCFCMetadata" hint="Compares database metadata to CFC metadata"> 
	<cfargument name="typename" required="true">
	<cfargument name="stDB" required="true" hint="Structure containing current database metadata">
	<cfargument name="scope" required="No" default="types" hint="types or rules are valid options.  Referes to application.types or application.rules">
	<cfparam name="stCFCConflicts" default="#structNew()#"	>
	<!--- Generate a structure that compares the database structure to the cfc structure --->
	<cfscript>
	stTypeDefaults = getTypeDefaults();
	</cfscript>

	<cfloop collection="#arguments.stDB#" item="key">
		<cfscript>
		stPropReport = structNew();
		
		//init struct - just checking for type/name discrepencies for the time being.
		stPropReport.bPropertyExists = true;
		stPropReport.bTypeConflict = false;
		bConflict = false;
		
		if(NOT structKeyExists(application[arguments.scope][arguments.typename].stProps,key))
		{
			stPropReport.bPropertyExists = false;
			bConflict = true; //flag that an error has occured
		}	
		else
		{	
			if (NOT application[arguments.scope][arguments.typename].stProps[key].metadata.type IS "array")
			{
				CFCType = stTypeDefaults[application[arguments.scope][arguments.typename].stProps[key].metadata.type].type; 
				if(NOT arguments.stDB[key].type IS CFCType)
				{
					stPropReport.bTypeConflict = true;
					bConflict = true;
				}		
			}	
		}	
		if (bConflict)		
			stCFCConflicts['database']['#arguments.typename#']['#key#'] = duplicate(stPropReport);
		</cfscript>
		
	</cfloop>
	
	<!---  Now we are doing the opposite - generate a structure that compares the CFC structure to the database structure --->
	<cfloop collection="#application[arguments.scope][arguments.typename].stProps#" item="key">
		<cfscript>
		stPropReport = structNew();
		//init struct - just checking for type/name discrepencies for the time being.
		stPropReport.bPropertyExists = true;
		stPropReport.bTypeConflict = false;
		bConflict = false;
		if(NOT structKeyExists(arguments.stDB,key))
		{	
			stPropReport.bPropertyExists = false;
			bConflict = true; //flag that an error has occured
		}
		else	
		{   
			if (NOT application[arguments.scope][arguments.typename].stProps[key].metadata.type IS "array")
				CFCType = stTypeDefaults[application[arguments.scope][arguments.typename].stProps[key].metadata.type].type;
			else
				CFCType = "array";	
			if(NOT arguments.stDB[key].type IS CFCType)
			{
				stPropReport.bTypeConflict = true;
				bConflict = true;
			}
		}	
		if(bConflict)
			stCFCConflicts['cfc']['#arguments.typename#']['#key#'] = duplicate(stPropReport);
		</cfscript>
		
	</cfloop>
	
	<cfreturn stCFCConflicts>
</cffunction>

<cffunction name="renderCFCReport" hint="displays the table outlining the descrepencies in each CFCs integrity">
	<cfargument name="typename" default="string" required="true">
	<cfargument name="stCFC" type="struct" required="true">
	<cfargument name="scope" type="string" required="false" default="types">
	
		
	<cfif structCount(arguments.stCFC)>
	<cfoutput>
	<table class="dataEvenRow" border="0" cellspacing="0" cellpadding="3" style="width:100%;border:solid 1px black;">
	<tr>
		<td>
			<strong>The following CFC properties conflicts exist :</strong>
		</td>
	</tr>
	<tr>
		<td>
			<table border="1" cellpadding="3" cellspacing="0" width="100%">
				<tr>
					<th>Property</th>
					<th>Deployed</th>
					<th>Type</th>
					<th>Action</th>
					<th>&nbsp;</th>
				</tr>
				<cfloop collection="#arguments.stCFC#" item="key">
				<form name="CFCForm" action="" method="post">
				<tr>
				<cfif NOT arguments.stCFC[key].bPropertyExists>
					<td>
						#key#
					</td>
					<td align="center">
						<img src="#application.url.farcry#/images/no.gif" border="0" alt="Property not deployed">
					</td>
					<td>
						#application[arguments.scope][typename].stProps[key].metadata.type#
					</td>
					<td>
						<select name="action">
							<option selected value="">Do Nothing</option>
							<cfif application[arguments.scope][typename].stProps[key].metadata.type IS "array">
							<option value="deployarrayproperty">Deploy Array Table</option>							
							<cfelse>
							<option value="deployproperty">Deploy Property</option>
							</cfif>
						</select>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#">
						<input type="hidden" name="typename" value="#arguments.typename#">
						<input type="submit" value="Go" class="normalbttnstyle">
					</td>
				<cfelseif arguments.stCFC[key].bTypeConflict>
					<td>
					#key#
					</td>
					<td align="center">
						
						<img src="#application.url.farcry#/images/yes.gif" border="0" alt="Property deployed">
						
					</td>
					<td style="background-color:navy;color:white;font-weight:bold;" colspan="3" align="center">
						<strong>TYPE CONFLICT EXISTS</strong>:	Choose repair type below 
					</td>
					
				</cfif>
				</tr>
				</form>
				</cfloop>
			</table>
		</td>
	</tr>
	</table>
	<br>
	</cfoutput>
	</cfif>
</cffunction>

<cffunction name="renderDBReport" hint="">
	<cfargument name="typename" default="string" required="true">
	<cfargument name="stDB" type="struct" required="true">

	<cfscript>
	stTypes = buildDBStructure();
	</cfscript>
	
	<cfif structCount(arguments.stDB)>
	<cfoutput>
	<table class="dataEvenRow" border="0" cellspacing="0" cellpadding="3" style="width:100%;border:solid 1px black;">
	<tr>
		<td>
			<strong>The following database discrepencies exist : </strong>
		</td>
	</tr>
	<tr>
		<td>
			<table border="1" cellpadding="3" cellspacing="0" width="100%">
				<tr>
					<th>Property</th>
					<th>Exists In CFC</th>
					<th>Type</th>
					<th>Action</th>
					<th>&nbsp;</th>
				</tr>
				<script>
				function showRename(theForm,divID){
					em = document.getElementById(divID);
					if(eval('document.'+theForm+'.action.value')=="renameproperty")
					{
						if (em.style.display=='none')
							em.style.display='inline';
						else
							em.style.display='none';
						}
						else
							em.style.display='none';
					}
				</script>
				
				<cfloop collection="#arguments.stDB#" item="key">
				<form name="#arguments.typename#_#key#_DBForm" action="" method="post">
				<tr>
				<cfif NOT arguments.stDB[key].bPropertyExists>
					<td>
						#key#
					</td>
					<td align="center">
						<img src="#application.url.farcry#/images/no.gif" border="0">
					</td>
					<td>

						#stTypes[arguments.typename][key].type#
					</td>
					<td>
						
						<select name="action" onchange="showRename('#arguments.typename#_#key#_DBForm','#arguments.typename#_#key#_renameto');">
							<option selected value="">Do Nothing</option>
							<cfif stTypes[arguments.typename][key].type IS "array">
								<option value="droparraytable">Drop Array Table</option>
							<cfelse>	
								<option value="deleteproperty">Delete Column</option>
								<option value="renameproperty">Rename Column</option>
							</cfif>
						</select>
						<div id="#arguments.typename#_#key#_renameto" style="display:none;">
							to :
							<input type="text" size="15" name="renameto">
						</div>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#">
						<input type="hidden" name="typename" value="#arguments.typename#">
						<input type="submit" value="Go" class="normalbttnstyle">
					</td>
				<cfelseif arguments.stDB[key].bTypeConflict>
					<td>
						#key#
					</td>
					<td align="center">
						
						<img src="#application.url.farcry#/images/yes.gif" border="0" alt="Property deployed">
						Property has been deployed
					</td>
					<td style="background-color:navy;color:white;font-weight:bold;">
						&nbsp;&nbsp;<strong>TYPE CONFLICT</strong>&nbsp;&nbsp;
						<!--- #stTypes[arguments.typename][key].type# --->
					</td>
					<td>
						<select name="action">
							<option selected>Do Nothing</option>
							<option value="repairproperty">Repair Type</option>
						</select>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#">
						<input type="hidden" name="typename" value="#arguments.typename#">
						<input type="submit" value="Go" class="normalbttnstyle">
					</td>		
				</cfif>
				</tr>
				</form>
				</cfloop>
			</table>
		</td>
	</tr>
	</table>
	
	</cfoutput>
	</cfif>
</cffunction>

<cffunction name="alterPropertyName">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="destColumn" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	
	<cfset srcObject = "#arguments.typename#.[#arguments.srcColumn#]">
	
	<cfstoredproc procedure="sp_rename" datasource="#arguments.dsn#">
		<cfprocparam cfsqltype="cf_sql_varchar" type="in" value="#srcObject#">
		<cfprocparam cfsqltype="cf_sql_varchar" type="in" value="#destColumn#">
		<cfprocparam cfsqltype="cf_sql_varchar" type="in" value="COLUMN">
	</cfstoredproc>
</cffunction>

<cffunction name="deleteProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	<cfscript>
	SQL = "ALTER TABLE #application.dbowner##arguments.typename# DROP COLUMN #arguments.srcColumn#";
	</cfscript>
	<cfquery datasource="#arguments.dsn#">#preserveSingleQuotes(sql)#</cfquery>
</cffunction>

<cffunction name="addProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="srcColumnType" required="true">
	<cfargument name="bNull" required="false" default="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	<cfargument name="dbtype" default="#application.dbtype#" required="false">
	
	<cfscript>
	switch(arguments.dbtype){
		case "ora":
		{ 
			sql = "ALTER TABLE #application.dbowner##arguments.typename# ADD (#arguments.srcColumn# #arguments.srcColumnType# ";	
			if (arguments.bNull) sql = sql & "NULL";
			else sql = sql & "NOT NULL";
			sql = sql & ")";
			break;
		}
		default:
		{
			sql = "ALTER TABLE #application.dbowner##arguments.typename#	ADD #arguments.srcColumn# #arguments.srcColumnType# ";	
			if (arguments.bNull) sql = sql & "NULL";
			else sql = sql & "NOT NULL";
			break;
		}
	}	
	
	
	</cfscript>
	
	<cfquery datasource="#arguments.dsn#">#preserveSingleQuotes(sql)#</cfquery>
</cffunction>

<cffunction name="repairProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="srcColumnType" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	<cfargument name="scope" default="types" required="No">
	
	<!--- work out default field length --->
	<cfset length = getTypeDefaults()>
	<cfset length = length[application[arguments.scope][arguments.typename].stProps[arguments.srcColumn].metadata.type].length>
	
	<cftransaction>
		<cftry>
		<!--- check for constraint --->
		<cfquery NAME="qCheck" DATASOURCE="#application.dsn#">
			SELECT c_obj.name as CONSTRAINT_NAME, col.name	as COLUMN_NAME, com.text as DEFAULT_CLAUSE
			FROM	sysobjects	c_obj
			JOIN 	syscomments	com on 	c_obj.id = com.id
			JOIN 	sysobjects	t_obj on c_obj.parent_obj = t_obj.id  
			JOIN    sysconstraints con on c_obj.id	= con.constid
			JOIN 	syscolumns	col on t_obj.id = col.id
						AND con.colid = col.colid
			WHERE c_obj.xtype	= 'D'
				AND t_obj.name = '#arguments.typename#'
				AND col.name = '#arguments.srcColumn#'
		</cfquery>
		<cfset defaultL = len(qCheck.Default_Clause)-2>
		
		<!--- drop constraint --->
		<cfif qCheck.recordcount>
			<cfquery NAME="qDrop" DATASOURCE="#application.dsn#">
				ALTER TABLE #application.dbowner##arguments.typename# DROP CONSTRAINT #qCheck.Constraint_Name#
			</cfquery>
		</cfif>
		
		<!--- alter column --->
		<cfquery NAME="qAlter" DATASOURCE="#application.dsn#">
			ALTER TABLE #application.dbowner##arguments.typename#  
			ALTER COLUMN #arguments.srcColumn# #arguments.srcColumnType# <cfif NOT listContainsNoCase("NTEXT,INT,NUMBER",arguments.srcColumnType)>(#length#)</cfif>
		</cfquery>
		
		<!--- add constraint --->
		<cfif qCheck.recordcount>
			<cfoutput></cfoutput>
			<cfset sql  = 	"ALTER TABLE #application.dbowner##arguments.typename# WITH NOCHECK ADD	CONSTRAINT #qCheck.Constraint_Name# DEFAULT #qCheck.Default_Clause# FOR #arguments.srcColumn#">
			<cfquery NAME="qAdd" DATASOURCE="#application.dsn#">
				
				#preserveSingleQuotes(sql)#
			</cfquery>
	
		</cfif>
		<cfcatch><cfoutput>
		<cfdump var="#cfcatch#">
		#cfcatch.message#<p></p>#cfcatch.detail#<p></p></cfoutput></cfcatch>
		</cftry>
	</cftransaction>
</cffunction>

<cffunction name="buildDBStructure"> 
	<cfargument name="scope" default="types" required="No">
	<cfloop collection="#application[arguments.scope]#" item="typename"> 
		<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<CFQUERY NAME="GetTables" DATASOURCE="#application.dsn#">
			SELECT ut.TABLE_NAME AS TableName, 
					    uc.COLUMN_NAME AS ColumnName, 
    					uc.DATA_LENGTH AS length,
	    				uc.NULLABLE AS isnullable,
		    			uc.DATA_TYPE AS Type
			FROM USER_TABLES ut
			INNER JOIN USER_TAB_COLUMNS uc	ON (ut.TABLE_NAME = uc.TABLE_NAME)
			WHERE ut.TABLE_NAME = '#ucase(typename)#'
			GROUP BY ut.TABLE_NAME,
        					uc.COLUMN_NAME,
    		    			uc.DATA_LENGTH,
			        		uc.NULLABLE,
    	    				uc.DATA_TYPE
			</cfquery>		
		</cfcase>
		<cfcase value="mysql">
			<!--- Get all tables in database--->	
			<cfquery name="getMySQLTables" datasource="#application.dsn#">
				SHOW TABLES like '#typename#'
			</cfquery>
			<!--- Create new query to be filled with db metadata--->					
			<cfset GetTables = queryNew("TableName,ColumnName,length,isnullable,Type")>	
			<cfloop query="getMySQLTables">
				<!--- Get tablename --->
				<cfset myTable = GetMySQLTables[columnlist][currentrow]>
				<!--- Get column details of each table--->	
				<cfquery name="GetMySQLColumns" datasource="#application.dsn#">
					SHOW COLUMNS FROM #myTable#
				</cfquery>
				<!--- Loop thru columns --->
				<cfloop query="GetMySQLColumns">
					<cfif find("(",type)>
						<cfset openbracket = find("(",GetMySQLColumns.type)>
						<cfset closebracket = find(")",GetMySQLColumns.type)>
						<cfset myLength = mid(GetMySQLColumns.type,openbracket+1,closebracket-(openbracket+1))>
						<cfset myType = left(GetMySQLColumns.type,openbracket-1)>
					<cfelse>
						<cfset myType = GetMySQLColumns.type>
						<cfif GetMySQLColumns.type eq "datetime">
							<cfset myLength=8>
						<cfelseif GetMySQLColumns.type is "text">
							<cfset myLength=16>
						<cfelse>
							<cfset myLength=4>
						</cfif>
					</cfif>
					<!--- Fill column details into created query--->
					<cfset temp = queryAddRow(GetTables)>
					<cfset temp = QuerySetCell(GetTables, "TableName", myTable)>
					<cfset temp = QuerySetCell(GetTables, "ColumnName", GetMySQLColumns.field)>
					<cfset temp = QuerySetCell(GetTables, "length", myLength)>
					<cfset temp = QuerySetCell(GetTables, "isnullable", yesnoformat(GetMySQLColumns.null))>
					<cfset temp = QuerySetCell(GetTables, "Type", myType)>
				</cfloop>	
			</cfloop>				
		</cfcase>
		
		<cfdefaultcase>
			<CFQUERY NAME="GetTables" DATASOURCE="#application.dsn#">
			SELECT dbo.sysobjects.name AS TableName, 
						dbo.syscolumns.Name AS ColumnName, 
						dbo.syscolumns.length,
						dbo.syscolumns.isnullable,
						dbo.systypes.name AS Type
			FROM dbo.sysobjects 
			INNER JOIN dbo.syscolumns ON (dbo.sysobjects.id = dbo.syscolumns.id)
			INNER JOIN 	dbo.systypes ON (dbo.syscolumns.xtype = dbo.systypes.xusertype)
			WHERE dbo.sysobjects.xtype = 'U'
			AND	dbo.sysobjects.name = '#typename#'
			AND dbo.sysobjects.name <> 'dtproperties'
			GROUP BY dbo.sysobjects.name,
        					dbo.syscolumns.name,
	        				dbo.syscolumns.length,
		        			dbo.syscolumns.isnullable,
			        		dbo.systypes.name
			</CFQUERY>
		</cfdefaultcase>
		</cfswitch>
		
		<cfscript>
		qArrayTables = getArrayTables(typename='#typename#');
		for(i = 1;i LTE qArrayTables.recordCount;i=i+1)
		{
			queryAddRow(getTables,1);
			querySetCell(getTables,'columnname',replacenocase(qArrayTables.name[i],"#typename#_",""));
			querySetCell(getTables,'type','array');
		}	
			
		for(i = 1;i LTE getTables.recordCount;i = i+1){
			stThisRow = structNew();
			stThisRow.length = getTables.length[i];
			stThisRow.isNullable = getTables.isNullable[i];
			stThisRow.type = getTables.type[i];
			stTypes['#typename#']['#getTables.columnname[i]#'] = Duplicate(stThisRow);
		}
		</cfscript>
		<!--- <cfdump var="#qArrayTables#">
		<cfdump var="#getTables#"> --->
		 <!--- <cfdump var="#getTables#">
		 <cfdump var="#stTypes#">
		 <cfdump var="#application.types[typename].stprops#">  --->
		<!---  <cfdump var="#stTypes#">  ---> 
	</cfloop> 

	<cfreturn stTypes>
</cffunction> 

<cffunction name="deployCFC">
	<cfargument name="typename" required="true">
	<cfargument name="scope" required="false" default="types">
	
	<cfscript>
	if (arguments.scope IS 'types')
	{
		if(NOT application[arguments.scope]['#arguments.typename#'].bCustomType)
			o = createObject("component", "#application.packagePath#.#arguments.scope#.#arguments.typename#");
		else
			o = createObject("component", "#application.custompackagePath#.#arguments.scope#.#arguments.typename#");
	}
	else if (arguments.scope IS 'rules')
	{
		if(NOT application[arguments.scope]['#arguments.typename#'].bCustomRule)
			o = createObject("component", "#application.packagePath#.#arguments.scope#.#arguments.typename#");
		else
			o = createObject("component", "#application.custompackagePath#.#arguments.scope#.#arguments.typename#");
	}		
	result = o.deployType(btestRun="false");
	</cfscript>
</cffunction> 

<cffunction name="isCFCDeployed">
	<cfargument name="typename" required="true">
	<cfargument name="dsn" required="false" default="#application.dsn#">

	<cfswitch expression="#application.dbtype#">

	<cfcase value="ora">
		<cfquery name="qTableExists" datasource="#application.dsn#">
		SELECT TABLE_NAME FROM USER_TABLES
		WHERE TABLE_NAME = '#ucase(arguments.typename)#'
		</cfquery>
	</cfcase>
	
	<cfcase value="mysql">
		<cfquery name="qTableExists" datasource="#application.dsn#">
			SHOW TABLES LIKE '#arguments.typename#'
		</cfquery>
	</cfcase>

	<cfdefaultcase>
		<cfquery name="qTableExists" datasource="#application.dsn#">
		SELECT 	dbo.sysobjects.name FROM dbo.sysobjects
		WHERE dbo.sysobjects.name = '#arguments.typename#'
		</cfquery>
	</cfdefaultcase>

	</cfswitch>

	<cfscript>
	bTableExists = false;
	if (qTableExists.recordcount) bTableExists = true;
	</cfscript>
	<cfreturn bTableExists>
</cffunction>

<cffunction name="isCFCConflict" hint="Determines whether or not a CFCs integrity has been compromised" returntype="boolean">
	<cfargument name="stConflicts" type="struct" required="true">
	<cfargument name="typename" type="string" required="true" hint="CFC name eg dmNew, ruleNews etc">
	
	<cfscript>
	bConflict = false;
	if((structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],arguments.typeName)) OR (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],arguments.typeName)))
        bConflict = true;
	</cfscript>
	<cfreturn bConflict>
</cffunction>

</cfcomponent>