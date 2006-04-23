<cfsetting enablecfoutputonly="Yes">

<cfscript>
	stStatus = structNew();
	stStatus.message = "";
	stStatus.status = false;
</cfscript>

<cfif stArgs.bDropTables>
<cftry>
	
	<cftransaction>
		<cfquery datasource="#stArgs.dsn#">
        if exists (select * from sysobjects where name = 'categories')
		DROP TABLE categories	

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
        if exists (select * from sysobjects where name = 'refCategories')
        DROP TABLE refCategories

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
	</cftransaction>		
	<cfset stStatus.message = "refCategories,categories tables successfully dropped <br>">
	<cfcatch type="any">
		<!--- TODO - put some details of the cfcatch.Message --->
		<cfset stStatus.message = "refCategories,categories tables unsuccessfully dropped <br>"> 
	</cfcatch>
</cftry>	
</cfif>
<cflock name="#createUUID()#" type="exclusive" timeout="50">
<cftry>
	<cftransaction>
	<!--- Create category and refCategories Tables --->
	<cfquery datasource="#stArgs.dsn#">
	CREATE TABLE [dbo].[categories]
	(
		[categoryID] [VARCHAR] (50) NOT NULL,
		[categoryLabel] [VARCHAR] (255) NOT NULL
	);
	</cfquery>
	<cfquery datasource="#stArgs.dsn#">
	CREATE TABLE [dbo].[refCategories]
	(
		[categoryid] [VARCHAR] (50) NOT NULL,
		[objectID] [VARCHAR] (50) NOT NULL
	);
	</cfquery>
	</cftransaction>
	<cfinvoke component="fourq.utils.tree.tree"	 method="setRootNode" objectName = "root" typename = "categories" objectID="#createUUID()#" returnvariable="stReturn">
	<cfscript> 
		stStatus.status = true;
		stStatus.message = stStatus.message & stReturn.message & '<br>' & 'categories, refCategory tables successfully created';
	</cfscript>
	<cfcatch type="database">
		<cfscript>
			//TODO - put some details of the cfcatch.Message 
			stStatus.status = false;
			stStatus.message = 'Creat categories, refCategory tables failed';
		</cfscript>
	</cfcatch>
	 
</cftry>		
</cflock>

	
<cfsetting enablecfoutputonly="no">

