<cfcomponent displayname="Database" extends="mxunit.framework.TestCase" output="false" mode="self">
	
	<cffunction name="setUp" returntype="void" access="public">
		
		<cfif isdefined("application.stPlugins.testMXUnit.dsn") and isdefined("application.stPlugins.testMXUnit.dbowner") and isdefined("application.stPlugins.testMXUnit.dbtype")>
			<cfset this.dsn = application.stPlugins.testMXUnit.dsn />
			<cfset this.dbowner = application.stPlugins.testMXUnit.dbowner />
			<cfset this.dbtype = application.stPlugins.testMXUnit.dbtype />
		<cfelse>
			<cfset this.dsn = application.dsn />
			<cfset this.dbowner = application.dbowner />
			<cfset this.dbtype = application.dbtype />
		</cfif>
		
		<cfset this.db = createObject("component", "farcry.core.packages.lib.db").init(dsn=this.dsn,dbtype=this.dbtype,dbowner=this.dbowner) />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		
		<cfset var schema = structnew() />
		
		<cftry>
			<cfset schema = this.db.getGateway(this.dsn).introspectType("dummyContentTypeA") />
			<cfif not structisempty(schema)>
				<cfset this.db.getGateway(this.dsn).dropSchema(schema) />
			</cfif>
			
			<cfset schema = this.db.getGateway(this.dsn).introspectType("dummyContentTypeB") />
			<cfif not structisempty(schema)>
				<cfset this.db.getGateway(this.dsn).dropSchema(schema) />
			</cfif>
			
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>
	
	
	<cffunction name="initialiseGateway" access="public" displayname="Initialise gateway" hint="">
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset var md = getmetadata(gateway) />
		
		<cfset assertTrue(listcontains(md.dbtype,this.dbtype) or listcontains(md.dbtype,"default"),"Did not initialise gateway") />
	</cffunction>
	
	<cffunction name="getGateway" access="public" displayname="Get gateway" hint="" dependsOn="initialiseGateway">
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset var md = "" />
		
		<cfset gateway = this.db.getGateway(dsn=this.dsn) />
		<cfset md = getmetadata(gateway) />
		
		<cfset assertTrue(listcontains(md.dbtype,this.dbtype) or listcontains(md.dbtype,"default"),"Did not load gateway") />
	</cffunction>
	
	<cffunction name="getTableMetadata" access="public" displayname="Get table metadata" hint="Generation of schema from component">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset assertFalse(structisempty(schema),"Schema struct is empty") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema)),"text"),"arrayfields,fields,indexes,tablename","Incorrect schema information provided") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.indexes)),"text"),"l_index,primary,y_index","Incorrect indexes listed") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields)),"text"),"a,b,c,createdby,d,datetimecreated,datetimelastupdated,e,f,g,h,i,j,k,l,label,lastupdatedby,locked,lockedby,m,objectid,ownedby","Incorrect fields generated") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.arrayfields)),"text"),"dummycontenttypea_a,dummycontenttypea_b,dummycontenttypea_c","Incorrect array fields listed") />
		<cfset assertEquals(arraytolist(schema.indexes.primary.fields),"objectid","Incorrect primary key fields") />
		<cfset assertEquals(schema.indexes.primary.type,"primary","Incorrect primary key index type") />
		<cfset assertEquals(arraytolist(schema.indexes.y_index.fields),"e","Incorrect index fields") />
		<cfset assertEquals(schema.indexes.y_index.type,"unclustered","Incorrect index type") />
	</cffunction>
	
	<cffunction name="getTableMetadata_ObjectID" access="public" displayname="Get table metadata (ObjectID)" hint="Generation of ObjectID schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- objectid // UUID --->
		<cfset assertEquals(schema.fields.objectid.name,"objectid","Incorrect name value") />
		<cfset assertEquals(schema.fields.objectid.type,"string","Incorrect type value") />
		<cfset assertEquals(schema.fields.objectid.precision,"50","Incorrect precision value") />
		<cfset assertEquals(schema.fields.objectid.bPrimaryKey,true,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.objectid.nullable,false,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.objectid.default,"","Incorrect default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_UUID" access="public" displayname="Get table metadata (UUID)" hint="Generation of UUID schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- objectid // UUID --->
		<cfset assertEquals(schema.fields.l.name,"l","Incorrect name value") />
		<cfset assertEquals(schema.fields.l.type,"string","Incorrect type value") />
		<cfset assertEquals(schema.fields.l.precision,"50","Incorrect precision value") />
		<cfset assertEquals(schema.fields.l.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.l.nullable,true,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.l.default,"NULL","Incorrect default value") />
		<cfset assertEquals(schema.fields.l.index,"l_index:1","Incorrect index") />
	</cffunction>
	
	<cffunction name="getTableMetadata_String" access="public" displayname="Get table metadata (String)" hint="Generation of String schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- createdby // string --->
		<cfset assertEquals(schema.fields.createdby.name,"createdby","Incorrect name value") />
		<cfset assertEquals(schema.fields.createdby.type,"string","Incorrect type value") />
		<cfset assertEquals(schema.fields.createdby.precision,"250","Incorrect precision value") />
		<cfset assertEquals(schema.fields.createdby.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.createdby.nullable,false,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.createdby.default,"","Incorrect default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_DateTime" access="public" displayname="Get table metadata (DateTime)" hint="Generation of DateTime schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- datetimecreated // datetime --->
		<cfset assertEquals(schema.fields.datetimecreated.name,"datetimecreated","Incorrect name value") />
		<cfset assertEquals(schema.fields.datetimecreated.type,"datetime","Incorrect type value") />
		<cfset assertEquals(schema.fields.datetimecreated.precision,"","Incorrect precision value") />
		<cfset assertEquals(schema.fields.datetimecreated.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.datetimecreated.nullable,false,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.datetimecreated.default,"","Incorrect default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_Boolean" access="public" displayname="Get table metadata (Boolean)" hint="Generation of Boolean schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- locked // boolean --->
		<cfset assertEquals(schema.fields.locked.name,"locked","Incorrect name value") />
		<cfset assertEquals(schema.fields.locked.type,"numeric","Incorrect type value") />
		<cfset assertEquals(schema.fields.locked.precision,"1,0","Incorrect precision value") />
		<cfset assertEquals(schema.fields.locked.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.locked.nullable,false,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.locked.default,"0","Incorrect default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_SimpleArray" access="public" displayname="Get table metadata (Simple Array)" hint="Generation of Simple Array schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- a // simple array --->
		<cfset assertEquals(schema.fields.a.name,"a","Incorrect name value") />
		<cfset assertEquals(schema.fields.a.type,"array","Incorrect type value") />
		<cfset assertEquals(schema.fields.a.precision,"","Incorrect precision value") />
		<cfset assertEquals(schema.fields.a.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.a.nullable,true,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.a.default,"NULL","Incorrect default value") />
		<cfset assertEquals(schema.fields.a.tablename,"dummyContentTypeA_a","Incorrect table name") />
		<cfset assertTrue(structkeyexists(schema.fields.a,"indexes"),"Missing indexes information") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.a.indexes)),"text"),"data_index,primary","Incorrect indexes") />
		<cfset assertEquals(listsort(arraytolist(schema.fields.a.indexes.primary.fields),"text"),"parentid,seq","Incorrect primary key fields") />
		<cfset assertEquals(schema.fields.a.indexes.primary.type,"primary","Incorrect primary key index type") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.a.fields)),"text"),"data,parentid,seq,typename","Incorrect array fields generated") />
		<cfset assertEquals(schema.fields.a.indexes.data_index.type,"unclustered","Incorrect simple array data index type") />
		<cfset assertEquals(lcase(arraytolist(schema.fields.a.indexes.data_index.fields)),"data","Incorrect simple array data index fields") />
	</cffunction>
	
	<cffunction name="getTableMetadata_ExtendedArray" access="public" displayname="Get table metadata (Extended Array)" hint="Generation of Extended Array schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- b // extended array --->
		<cfset assertEquals(schema.fields.b.name,"b","Incorrect name value") />
		<cfset assertEquals(schema.fields.b.type,"array","Incorrect type value") />
		<cfset assertEquals(schema.fields.b.precision,"","Incorrect precision value") />
		<cfset assertEquals(schema.fields.b.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.b.nullable,true,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.b.default,"NULL","Incorrect default value") />
		<cfset assertEquals(schema.fields.b.tablename,"dummyContentTypeA_b","Incorrect table name") />
		
		<!--- indexes --->
		<cfset assertTrue(structkeyexists(schema.fields.b,"indexes"),"Missing indexes information") />
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.b.indexes)),"text"),"data_index,primary","Incorrect indexes") />
		<cfset assertEquals(listsort(arraytolist(schema.fields.b.indexes.primary.fields),"text"),"parentid,seq","Incorrect primary key fields") />
		<cfset assertEquals(schema.fields.b.indexes.primary.type,"primary","Incorrect primary key index type") />
		
		<!--- fields --->
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.b.fields)),"text"),"data,parentid,q,r,s,seq,t,typename","Incorrect array fields generated") />
		
		<cfset assertEquals(schema.fields.b.fields.q.type,"string","Incorrect extended string field type value") />
		<cfset assertEquals(schema.fields.b.fields.q.precision,"250","Incorrect extended string field precision value") />
		<cfset assertEquals(schema.fields.b.fields.q.nullable,true,"Incorrect extended string field nullable value") />
		<cfset assertEquals(schema.fields.b.fields.q.default,"NULL","Incorrect extended string field default value") />
		
		<cfset assertEquals(schema.fields.b.fields.r.type,"numeric","Incorrect extended numeric field type value") />
		<cfset assertEquals(schema.fields.b.fields.r.precision,"10,2","Incorrect extended numeric field precision value") />
		<cfset assertEquals(schema.fields.b.fields.r.nullable,true,"Incorrect extended numeric field nullable value") />
		<cfset assertEquals(schema.fields.b.fields.r.default,"NULL","Incorrect extended string numeric default value") />
		
		<cfset assertEquals(schema.fields.b.fields.s.type,"numeric","Incorrect extended boolean field type value") />
		<cfset assertEquals(schema.fields.b.fields.s.precision,"1,0","Incorrect extended boolean field precision value") />
		<cfset assertEquals(schema.fields.b.fields.s.nullable,true,"Incorrect extended boolean field nullable value") />
		<cfset assertEquals(schema.fields.b.fields.s.default,"NULL","Incorrect extended boolean field default value") />
		
		<cfset assertEquals(schema.fields.b.fields.t.type,"datetime","Incorrect extended datetime field type value") />
		<cfset assertEquals(schema.fields.b.fields.t.precision,"","Incorrect extended datetime field precision value") />
		<cfset assertEquals(schema.fields.b.fields.t.nullable,true,"Incorrect extended datetime field nullable value") />
		<cfset assertEquals(schema.fields.b.fields.t.default,"NULL","Incorrect extended datetime field default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_ContentArray" access="public" displayname="Get table metadata (Content Array)" hint="Generation of Content Array schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- c // content array --->
		<cfset assertEquals(schema.fields.c.name,"c","Incorrect name value") />
		<cfset assertEquals(schema.fields.c.type,"array","Incorrect type value") />
		<cfset assertEquals(schema.fields.c.precision,"","Incorrect precision value") />
		<cfset assertEquals(schema.fields.c.bPrimaryKey,false,"Incorrect bPrimaryKey value") />
		<cfset assertEquals(schema.fields.c.nullable,true,"Incorrect nullable value") />
		<cfset assertEquals(schema.fields.c.default,"NULL","Incorrect default value") />
		<cfset assertEquals(schema.fields.c.tablename,"dummyContentTypeA_c","Incorrect table name") />
		<cfset assertTrue(structkeyexists(schema.fields.c,"indexes"),"Missing indexes information") />
		
		<!--- indexes --->
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.c.indexes)),"text"),"array_index,b_index,primary","Incorrect indexes on content type array") />
		<cfset assertEquals(schema.fields.c.indexes.primary.type,"primary","Incorrect array primary index type") />
		<cfset assertEquals(lcase(arraytolist(schema.fields.c.indexes.primary.fields)),"objectid","Incorrect array primary index fields") />
		<cfset assertEquals(schema.fields.c.indexes.array_index.type,"unclustered","Incorrect supplementary array index type") />
		<cfset assertEquals(lcase(arraytolist(schema.fields.c.indexes.array_index.fields)),"parentid,seq","Incorrect supplementary array index fields") />
		<cfset assertEquals(schema.fields.c.indexes.b_index.type,"unclustered","Incorrect array normal index type") />
		<cfset assertEquals(lcase(arraytolist(schema.fields.c.indexes.b_index.fields)),"b","Incorrect array normal index fields") />
		
		<!--- fields --->
		<cfset assertEquals(listsort(lcase(structkeylist(schema.fields.c.fields)),"text"),"a,b,createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedby,objectid,ownedby,parentid,seq","Incorrect array fields generated") />
		<cfset assertEquals(schema.fields.c.fields.a.type,"string","Incorrect extended string field type value") />
		<cfset assertEquals(schema.fields.c.fields.a.precision,"250","Incorrect extended string field precision value") />
		<cfset assertEquals(schema.fields.c.fields.a.nullable,true,"Incorrect extended string field nullable value") />
		<cfset assertEquals(schema.fields.c.fields.a.default,"NULL","Incorrect extended string field default value") />
	</cffunction>
	
	<cffunction name="getTableMetadata_Indexes" access="public" displayname="Get table metadata (Indexes)" hint="Generation of index schema" dependsOn="getTableMetadata">
		<cfset var schema = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<!--- normal indexes --->
		<cfset assertEquals(listsort(lcase(structkeylist(schema.indexes)),"text"),"l_index,primary,y_index","Incorrect indexes") />
		<cfset assertEquals(schema.indexes.primary.type,"primary","Incorrect primary index type") />
		<cfset assertEquals(lcase(arraytolist(schema.indexes.primary.fields)),"objectid","Incorrect primary index fields") />
		<cfset assertEquals(schema.indexes.y_index.type,"unclustered","Incorrect normal index type") />
		<cfset assertEquals(lcase(arraytolist(schema.indexes.y_index.fields)),"e","Incorrect normal index fields") />
		<cfset assertEquals(schema.indexes.l_index.type,"unclustered","Incorrect normal index type") />
		<cfset assertEquals(lcase(arraytolist(schema.indexes.l_index.fields)),"l","Incorrect normal index fields") />
	</cffunction>
	
	<cffunction name="deployType" access="public" displayname="Deploy type" hint="" dependsOn="getTableMetadata">
		<cfset var schema = "" />
		<cfset var stResult = "" />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata(typename="farcry.core.tests.resources.dummyContentTypeA") />
		<cfset stResult = this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bSuccess,message,results","Gateway returned invalid result struct") />
		
		<cfset assertTrue(stResult.bSuccess,"Gateway returned failure flag") />
		
		<cftry>
			<cfquery datasource="#this.dsn#" name="q">
				select * from #this.dbowner##schema.tablename#
			</cfquery>
			
			<cfcatch type="database">
				<cfif find("Invalid object name 'dummyContentTypeA'",cfcatch.message)>
					<cfset fail("Table does not exist") />
				<cfelse>
					<cfthrow message="#cfcatch.message#" detail="#cfcatch.ExtendedInfo#" extendedinfo="#cfcatch.SQL#" />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="dropType" access="public" displayname="Drop type" hint="" dependsOn="deployType">
		<cfset var schema = "" />
		<cfset var stResult = "" />
		
		<cfset gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata(typename="farcry.core.tests.resources.dummyContentTypeA") />
		<cfset stResult = this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset assertTrue(stResult.bSuccess) />
		
		<cfset stResult = this.db.dropType(typename="farcry.core.tests.resources.dummyContentTypeA",dsn=this.dsn)>
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bSuccess,message,results") />
		<cfset assertTrue(stResult.bSuccess) />
		
		<cftry>
			<cfquery datasource="#this.dsn#" name="q">
				select * from #this.dbowner#dummyContentTypeA
			</cfquery>
			
			<cfquery datasource="#this.dsn#" name="q">
				select * from #this.dbowner#dummyContentTypeA_a
			</cfquery>
			
			<cfquery datasource="#this.dsn#" name="q">
				select * from #this.dbowner#dummyContentTypeA_b
			</cfquery>
			
			<cfquery datasource="#this.dsn#" name="q">
				select * from #this.dbowner#dummyContentTypeA_c
			</cfquery>
			
			<cfset fail("Table still exists") />
			
			<cfcatch>
				<!--- Good ... that table SHOULDN'T exist --->
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="isDeployed_false" access="public" displayname="Is deployed =&gt; false" hint="" dependsOn="initialiseGateway">
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset var bDeployed = this.db.isDeployed(typename="farcry.core.tests.resources.dummyContentTypeC",dsn=this.dsn) />
		
		<cfset assertFalse(bDeployed,"Table exists") />
	</cffunction>
	
	<cffunction name="isDeployed_true" access="public" displayname="Is deployed =&gt; true" hint="" dependsOn="deployType,dropType">
		<cfset var schema = "" />
		<cfset var stResult = "" />
		<cfset var bDeployed = "" />
		
		<cfset gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata(typename="farcry.core.tests.resources.dummyContentTypeA") />
		<cfset stResult = this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset bDeployed = this.db.isDeployed(typename="farcry.core.tests.resources.dummyContentTypeA",dsn=this.dsn) />
		
		<cfset assertTrue(bDeployed) />
	</cffunction>
	
	<cffunction name="diffSchema_match" access="public" displayname="Schema differences (None)" dependsOn="getTableMetadata,deployType,isDeployed_true">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="diffSchema_undeployedtable" access="public" displayname="Schema differences (Undeployed table)" dependsOn="deployType,isDeployed_false">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypeb","Incorrect table conflict detected") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypeb)),"text"),"conflict,newmetadata,resolution","Incorrect conflict information returned") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypeb.newmetadata)),"text"),listsort(lcase(structkeylist(schema)),"text"),"Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummycontenttypeb.conflict,"Undeployed table","Incorrect conflict identified") />
	</cffunction>
	
	<cffunction name="diffSchema_undeployedsimple" access="public" displayname="Schema differences (Undeployed simple property)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["undeployedproperty"] = structnew() />
		<cfset schema.fields["undeployedproperty"].name = "undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].type = "string" />
		<cfset schema.fields["undeployedproperty"].precision = "250" />
		<cfset schema.fields["undeployedproperty"].bPrimaryKey = false />
		<cfset schema.fields["undeployedproperty"].nullable = false />
		<cfset schema.fields["undeployedproperty"].default = "" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.conflict,"Altered table","Incorrect table conflict") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea.fields)),"text"),"undeployedproperty","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea.fields.undeployedproperty)),"text"),"conflict,newmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.fields.undeployedproperty.conflict,"Undeployed property","Incorrect conflict identified") />
	</cffunction>
	
	<cffunction name="diffSchema_undeployedarray" access="public" displayname="Schema differences (Undeployed array property)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.getGateway(this.dsn).deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["undeployedproperty"] = structnew() />
		<cfset schema.fields["undeployedproperty"].tablename = "dummyContentTypeA_undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].primarykey = "parentid,seq" />
		<cfset schema.fields["undeployedproperty"].name = "undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].type = "array" />
		<cfset schema.fields["undeployedproperty"].precision = "" />
		<cfset schema.fields["undeployedproperty"].bPrimaryKey = false />
		<cfset schema.fields["undeployedproperty"].nullable = false />
		<cfset schema.fields["undeployedproperty"].default = "" />
		<cfset schema.fields["undeployedproperty"].fields = structnew() />
		<cfset schema.fields["undeployedproperty"].fields.parentid = this.db.createFieldStruct(name="parentid",default="",nullable=false,type="uuid",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.seq = this.db.createFieldStruct(name="seq",default=0,nullable=false,type="numeric",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.data = this.db.createFieldStruct(name="data",default="NULL",nullable=true,type="string",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.typename = this.db.createFieldStruct(name="typename",default="NULL",nullable=true,type="string",precision="") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea_undeployedproperty","Incorrect table conflict detected") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea_undeployedproperty)),"text"),"conflict,newmetadata,resolution","Incorrect conflict information returned") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea_undeployedproperty.newmetadata)),"text"),listsort(lcase(structkeylist(schema.fields.undeployedproperty)),"text"),"Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea_undeployedproperty.conflict,"Undeployed table","Incorrect conflict identified") />
	</cffunction>
	
	<cffunction name="diffSchema_undeployedindex" access="public" displayname="Schema differences (Undeployed index)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["g"].index = "Z_index:1" />
		<cfset schema.fields["i"].index = "Z_index:2" />
		<cfset schema.indexes["Z_index"] = structnew() />
		<cfset schema.indexes["Z_index"].name = "Z_index" />
		<cfset schema.indexes["Z_index"].type = "unclustered" />
		<cfset schema.indexes["Z_index"].fields = listtoarray("g,i") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.conflict,"Altered table","Incorrect table conflict") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea.indexes)),"text"),"z_index","Changed index not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.indexes.z_index.conflict,"Undeployed index","Incorrect index conflict") />
		<cfset assertEquals(arraytolist(stDiff.tables.dummycontenttypea.indexes.z_index.newMetadata.fields),"g,i","Undeployed index fields not included") />
	</cffunction>
	
	<cffunction name="diffSchema_deletedsimple" access="public" displayname="Schema differences (Deleted simple property)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset structdelete(schema.fields,"createdby") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"createdby","Deleted property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.createdby)),"text"),"conflict,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.createdby.conflict,"Surplus property","Incorrect conflict identified") />
	</cffunction>
	
	<cffunction name="diffSchema_deletedarray" access="public" displayname="Schema differences (Deleted array property)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset structdelete(schema.fields,"a") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummyContentTypeA_a","Deleted table not identified") />
		<cfset assertTrue(structkeyexists(stDiff.tables.dummyContentTypeA_a,"conflict"),"Missing 'conflict' value") />
		<cfset assertTrue(structkeyexists(stDiff.tables.dummyContentTypeA_a,"oldmetadata"),"Missing 'oldmetadata' value") />
		<cfset assertTrue(structkeyexists(stDiff.tables.dummyContentTypeA_a,"resolution"),"Missing 'resolution' value") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA_a.conflict,"Surplus table","Incorrect conflict identified") />
	</cffunction>
	
	<cffunction name="diffSchema_deletedindex" access="public" displayname="Schema differences (Deleted index)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset structdelete(schema.indexes,"y_index") />
		<cfset schema.fields["e"].index = "" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.conflict,"Altered table","Incorrect table conflict") />
		<cfset assertFalse(structisempty(stDiff.tables.dummycontenttypea.indexes),"Index conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea.indexes)),"text"),"y_index","Removed index not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.indexes.y_index.conflict,"Surplus index","Altered index not identified") />
		<cfset assertEquals(arraytolist(stDiff.tables.dummycontenttypea.indexes.y_index.oldMetadata.fields),"e","Deleted index fields not identified") />
	</cffunction>
	
	<cffunction name="diffSchema_changedstringprecision" access="public" displayname="Schema differences (Changed string property precision)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["k"].precision = "150" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"k","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.k)),"text"),"conflict,newmetadata,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.k.conflict,"Altered property","Incorrect conflict identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.k.oldmetadata.precision,"100","Old metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.k.newmetadata.precision,"150","New metadata incorrect") />
	</cffunction>
	
	<cffunction name="diffSchema_changednumericprecision" access="public" displayname="Schema differences (Changed numeric property precision)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["h"].precision = "4,4" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"h","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.h)),"text"),"conflict,newmetadata,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.h.conflict,"Altered property","Incorrect conflict identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.h.oldmetadata.precision,"8,0","Old metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.h.newmetadata.precision,"4,4","New metadata incorrect") />
	</cffunction>
	
	<cffunction name="diffSchema_changednullabletofalse" access="public" displayname="Schema differences (Changed property nullable to false)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["f"].nullable = false />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"f","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.f)),"text"),"conflict,newmetadata,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.f.conflict,"Altered property","Incorrect conflict identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.f.oldmetadata.nullable,true,"Old metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.f.newmetadata.nullable,false,"New metadata incorrect") />
	</cffunction>
	
	<cffunction name="diffSchema_numerictostring" access="public" displayname="Schema differences (Changed numeric to string)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset schema.fields["g"].type = "string" />
		<cfset schema.fields["g"].precision = "250" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"g","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.g)),"text"),"conflict,newmetadata,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.g.conflict,"Altered property","Incorrect conflict identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.g.oldmetadata.type,"numeric","Old metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.g.newmetadata.type,"string","New metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.g.newmetadata.precision,"250","New metadata incorrect") />
	</cffunction>
	
	<cffunction name="diffSchema_stringdefault" access="public" displayname="Schema differences (Changed string default)" dependsOn="deployType,dropType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["i"].default = "there" />
		<cfset schema.fields["i"].nullable = false />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.conflict,"Altered table","Altered table not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields)),"text"),"i","Undeployed property not identified") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummyContentTypeA.fields.i)),"text"),"conflict,newmetadata,oldmetadata,resolution","Incorrect correction metadata returned") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.i.conflict,"Altered property","Incorrect conflict identified") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.i.oldmetadata.default,"hello","Old metadata incorrect") />
		<cfset assertEquals(stDiff.tables.dummyContentTypeA.fields.i.newmetadata.default,"there","New metadata incorrect") />
	</cffunction>
	
	<cffunction name="diffSchema_changedindex" access="public" displayname="Schema differences (Changed index)" dependsOn="deployType">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset arrayappend(schema.indexes.y_index.fields,"g") />
		<cfset schema.fields["g"].index = "y_index:2" />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertFalse(structisempty(stDiff.tables),"Table conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables)),"text"),"dummycontenttypea","Changed table not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.conflict,"Altered table","Incorrect table conflict") />
		<cfset assertFalse(structisempty(stDiff.tables.dummycontenttypea.indexes),"Index conflicts") />
		<cfset assertEquals(listsort(lcase(structkeylist(stDiff.tables.dummycontenttypea.indexes)),"text"),"y_index","Changed index not identified") />
		<cfset assertEquals(stDiff.tables.dummycontenttypea.indexes.y_index.conflict,"Altered index","Altered index not identified") />
		<cfset assertEquals(arraytolist(stDiff.tables.dummycontenttypea.indexes.y_index.oldMetadata.fields),"e","Altered index existing fields not identified") />
		<cfset assertEquals(arraytolist(stDiff.tables.dummycontenttypea.indexes.y_index.newMetadata.fields),"e,g","Altered index new fields not identified") />
	</cffunction>
	
	<cffunction name="deployProperty_simple" access="public" displayname="Deploy simple property" dependsOn="deployType,dropType,diffSchema_undeployedsimple">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["undeployedproperty"] = structnew() />
		<cfset schema.fields["undeployedproperty"].name = "undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].type = "string" />
		<cfset schema.fields["undeployedproperty"].precision = "250" />
		<cfset schema.fields["undeployedproperty"].bPrimaryKey = false />
		<cfset schema.fields["undeployedproperty"].nullable = false />
		<cfset schema.fields["undeployedproperty"].default = "" />
		
		<cfset gateway.addColumn(schema=schema,propertyname="undeployedproperty") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="deployProperty_array" access="public" displayname="Deploy array property" dependsOn="deployType,dropType,diffSchema_undeployedarray">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["undeployedproperty"] = structnew() />
		<cfset schema.fields["undeployedproperty"].tablename = "dummyContentTypeA_undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].primarykey = "parentid,seq" />
		<cfset schema.fields["undeployedproperty"].name = "undeployedproperty" />
		<cfset schema.fields["undeployedproperty"].type = "array" />
		<cfset schema.fields["undeployedproperty"].precision = "" />
		<cfset schema.fields["undeployedproperty"].bPrimaryKey = false />
		<cfset schema.fields["undeployedproperty"].nullable = false />
		<cfset schema.fields["undeployedproperty"].default = "" />
		<cfset schema.fields["undeployedproperty"].fields = structnew() />
		<cfset schema.fields["undeployedproperty"].fields.parentid = this.db.createFieldStruct(name="parentid",default="",nullable=false,type="uuid",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.seq = this.db.createFieldStruct(name="seq",default=0,nullable=false,type="numeric",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.data = this.db.createFieldStruct(name="data",default="NULL",nullable=true,type="string",precision="") />
		<cfset schema.fields["undeployedproperty"].fields.typename = this.db.createFieldStruct(name="typename",default="NULL",nullable=true,type="string",precision="") />
		<cfset schema.fields["undeployedproperty"].indexes = structnew() />
		
		<cfset gateway.deploySchema(schema=schema.fields.undeployedproperty,bDropTable=true) />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="deployIndex" access="public" displayname="Deploy index" dependsOn="deployType,dropType,diffSchema_undeployedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["g"].index = "Z_index:1" />
		<cfset schema.fields["i"].index = "Z_index:2" />
		<cfset schema.indexes["Z_index"] = structnew() />
		<cfset schema.indexes["Z_index"].name = "Z_index" />
		<cfset schema.indexes["Z_index"].type = "unclustered" />
		<cfset schema.indexes["Z_index"].fields = listtoarray("g,i") />
		
		<cfset gateway.addIndex(schema=schema,indexname="Z_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="dropProperty_simple" access="public" displayname="Drop simple property" dependsOn="deployType,dropType,diffSchema_deletedsimple">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset structdelete(schema.fields,"createdby") />
		<cfset gateway.dropColumn(schema=schema,propertyname="createdby") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="dropProperty_array" access="public" displayname="Drop array property" dependsOn="deployType,dropType,diffSchema_deletedarray">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset structdelete(schema.fields,"a") />
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		<cfset gateway.dropSchema(schema=stDiff.tables.dummyContentTypeA_a.oldmetadata) />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="dropIndex" access="public" displayname="Drop index" dependsOn="deployType,dropType,diffSchema_deletedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		<cfset var stTemp = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset structdelete(schema.indexes,"y_index") />
		<cfset schema.fields["e"].index = "" />
		<cfset stTemp = gateway.dropIndex(schema=schema,indexname="y_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairProperty_numerictostring" access="public" displayname="Repair property (numeric to string)" dependsOn="deployType,dropType,diffSchema_numerictostring">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["g"].type = "string" />
		<cfset schema.fields["g"].precision = "250" />
		
		<cfset gateway.repairColumn(schema=schema,propertyname="g") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairProperty_numericprecision" access="public" displayname="Repair property (numeric precision)" dependsOn="deployType,dropType,diffSchema_changednumericprecision">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["h"].precision = "4,4" />
		
		<cfset gateway.repairColumn(schema=schema,propertyname="h") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairProperty_datetimetounnullable" access="public" displayname="Repair property (datetime to unnullable)" dependsOn="deployType,dropType,diffSchema_changednullabletofalse">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["f"].nullable = false />
		<cfset schema.fields["f"].default = "" />
		
		<cfset result = gateway.repairColumn(schema=schema,propertyname="f") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairProperty_stringdefault" access="public" displayname="Repair property (string default)" dependsOn="deployType,dropType,diffSchema_stringdefault">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		<cfset var stTemp = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["i"].default = "there" />
		
		<cfset stTemp = gateway.repairColumn(schema=schema,propertyname="i") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairIndex" access="public" displayname="Repair index" dependsOn="deployType,dropType,diffSchema_changedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset arrayappend(schema.indexes.y_index.fields,"g") />
		<cfset schema.fields["g"].index = "y_index:2" />
		
		<cfset gateway.repairIndex(schema=schema,indexname="y_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="deployProperty_extendedsimple" access="public" displayname="Deploy simple property in extended array" dependsOn="deployType,dropType,diffSchema_undeployedsimple">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["b"].fields["undeployedproperty"] = structnew() />
		<cfset schema.fields["b"].fields["undeployedproperty"].name = "undeployedproperty" />
		<cfset schema.fields["b"].fields["undeployedproperty"].type = "string" />
		<cfset schema.fields["b"].fields["undeployedproperty"].precision = "250" />
		<cfset schema.fields["b"].fields["undeployedproperty"].bPrimaryKey = false />
		<cfset schema.fields["b"].fields["undeployedproperty"].nullable = false />
		<cfset schema.fields["b"].fields["undeployedproperty"].default = "" />
		
		<cfset gateway.addColumn(schema=schema.fields["b"],propertyname="undeployedproperty") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="dropProperty_extendedsimple" access="public" displayname="Drop simple property in extended array" dependsOn="deployType,dropType,diffSchema_deletedsimple">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset structdelete(schema.fields.c.fields,"r") />
		<cfset gateway.dropColumn(schema=schema.fields.c,propertyname="r") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairProperty_extendednumerictostring" access="public" displayname="Repair property (numeric to string in extended array)" dependsOn="deployType,dropType,diffSchema_numerictostring">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["b"].fields["r"].type = "string" />
		<cfset schema.fields["b"].fields["r"].precision = "250" />
		
		<cfset gateway.repairColumn(schema=schema.fields["b"],propertyname="r") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="deployIndex_array" access="public" displayname="Deploy index in array" dependsOn="deployType,dropType,diffSchema_undeployedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["c"].fields["a"].index = "a_index:1" />
		<cfset schema.fields["c"].indexes["a_index"] = structnew() />
		<cfset schema.fields["c"].indexes["a_index"].name = "a_index" />
		<cfset schema.fields["c"].indexes["a_index"].type = "unclustered" />
		<cfset schema.fields["c"].indexes["a_index"].fields = listtoarray("a") />
		
		<cfset gateway.addIndex(schema=schema.fields["c"],indexname="a_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="dropIndex_array" access="public" displayname="Drop index in array" dependsOn="deployType,dropType,diffSchema_deletedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset structdelete(schema.fields.c.indexes,"b_index") />
		<cfset schema.fields.c.fields["b"].index = "" />
		<cfset gateway.dropIndex(schema=schema.fields.c,indexname="b_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="repairIndex_array" access="public" displayname="Repair index in array" dependsOn="deployType,dropType,diffSchema_changedindex">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		<cfset var stTemp = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["c"].indexes.b_index.fields = listtoarray("a,b") />
		<cfset schema.fields["c"].fields["a"].index = "b_index" />
		
		<cfset stTemp = gateway.repairIndex(schema=schema.fields["c"],indexname="b_index") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
	<cffunction name="createData_objectid" access="public" displayname="Create data (objectid primary key)" dependsOn="deployType,dropType">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,objectid,results","Invalid return struct") />
		<cfset assertTrue(stResult.bSuccess,"Function did not return success flag") />
		<cfset assertTrue(isvalid("uuid",stResult.objectid),"Function did not return objectid") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeB
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"New record not found in database") />
	</cffunction>
	
	<cffunction name="createData_parentidseq" access="public" displayname="Create data (parentid+seq primary key)" dependsOn="deployType,dropType">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.parentid = createuuid() />
		<cfset stProperties.seq = 10 />
		
		<cfset stResult = this.db.getGateway(this.dsn).createData(schema=schema.fields.a,stProperties=stProperties) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,results","Invalid return struct") />
		<cfset assertTrue(stResult.bSuccess,"Function did not return success flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_a
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.parentid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="#stProperties.seq#" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"New record not found in database") />
	</cffunction>
	
	<cffunction name="createData_recordexists" access="public" displayname="Create data (record already exists)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,objectid,results","Invalid return struct") />
		<cfset assertFalse(stResult.bSuccess,"Function did not return failure flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeB
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Incorrect number of records in database") />
	</cffunction>
	
	<cffunction name="createData_nullstring" access="public" displayname="Create data (null string)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	j is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="createData_nulldatenew" access="public" displayname="Create data (null date new way)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.f = "" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	f is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="createData_nulldateold" access="public" displayname="Create data (null date old way)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.f = dateadd('yyyy',200,now()) />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	f is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="createData_simplearrays" access="public" displayname="Create data (simple arrays)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.a = arraynew(1) />
		<cfset stProperties.a[1] = createuuid() />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_a
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="1" />
					and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.a[1]#" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="createData_extendedarrays" access="public" displayname="Create data (extended arrays)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.b = arraynew(1) />
		<cfset stProperties.b[1] = structnew() />
		<cfset stProperties.b[1].q = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_b
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="1" />
					and q=<cfqueryparam cfsqltype="cf_sql_varchar" value="hello" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record not found") />
	</cffunction>
	
	<cffunction name="setData_objectid" access="public" displayname="Set data (objectid primary key)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.createdby = "test" />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,results,stproperties","Invalid return struct") />
		<cfset assertTrue(stResult.bSuccess,"Function did not return success flag #stResult.toString()#") />
	</cffunction>
	
	<cffunction name="setData_parentidseq" access="public" displayname="Set data (parentid+seq primary key)" dependsOn="deployType,dropType,createData_parentidseq">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.parentid = createuuid() />
		<cfset stProperties.seq = 10 />
		<cfset stProperties.data = "hello" />
		<cfset stResult = this.db.getGateway(this.dsn).createData(schema=schema.fields.a,stProperties=stProperties) />
		
		<cfset stProperties.data = "world" />
		<cfset stResult = this.db.getGateway(this.dsn).setData(schema=schema.fields.a,stProperties=stProperties) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,results,stproperties","Invalid return struct") />
		<cfset assertTrue(stResult.bSuccess,"Function did not return success flag") />
	</cffunction>
	
	<cffunction name="setData_recordnotexist" access="public" displayname="Set data (record does not exist)" dependsOn="deployType,dropType">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.objectid = createuuid() />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bsuccess,message,results,stproperties","Invalid return struct") />
		<cfset assertFalse(stResult.bSuccess,"Function did not return failure flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeB
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.objectid#" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,0,"Incorrect number of records in database") />
	</cffunction>
	
	<cffunction name="setData_nullstring" access="public" displayname="Set data (null string)" dependsOn="deployType,dropType,createData_nullstring">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.j = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.j = "" />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	j is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="setData_nulldatenew" access="public" displayname="Set data (null date new way)" dependsOn="deployType,dropType,createData_nulldatenew">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.f = now() />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.f = "" />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	f is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="setData_nulldateold" access="public" displayname="Set data (null date old way)" dependsOn="deployType,dropType,createData_nulldateold">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.f = now() />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.f = dateadd('yyyy',200,now()) />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA
			where	f is null
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="setData_simplearrays" access="public" displayname="Set data (simple arrays)" dependsOn="deployType,dropType,createData_simplearrays">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.a = arraynew(1) />
		<cfset stProperties.a[1] = createuuid() />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.a[1] = "hello" />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_a
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.objectid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="1" />
					and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="hello" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record with null value not found") />
	</cffunction>
	
	<cffunction name="setData_extendedarrays" access="public" displayname="Set data (extended arrays)" dependsOn="deployType,dropType,createData_extendedarrays">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.b = arraynew(1) />
		<cfset stProperties.b[1] = structnew() />
		<cfset stProperties.b[1].q = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties.objectid = stResult.objectid />
		<cfset stProperties.b[1].q = "world" />
		<cfset stResult = this.db.setData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_b
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.objectid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="1" />
					and q=<cfqueryparam cfsqltype="cf_sql_varchar" value="world" />
		</cfquery>
		
		<cfset assertEquals(q.recordcount,1,"Record not found") />
	</cffunction>
	
	<cffunction name="getData_objectid" access="public" displayname="Get data (objectid primary key)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.createdby = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		
		<cfset stProperties = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeB",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties,"createdby"),"Invalid return struct") />
		<cfset assertEquals(stProperties.createdby,"hello","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_parentidseq" access="public" displayname="Get data (parentid+seq primary key)" dependsOn="deployType,dropType,createData_parentidseq">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.parentid = createuuid() />
		<cfset stProperties.seq = 10 />
		<cfset stProperties.data = "hello" />
		
		<cfset stResult = this.db.getGateway(this.dsn).createData(schema=schema.fields.a,stProperties=stProperties) />
		
		<cfset stProperties = this.db.getGateway(this.dsn).getData(schema=schema.fields.a,parentid=stProperties.parentid,seq=10) />
		
		<cfset assertTrue(structkeyexists(stProperties,"data"),"Invalid return struct") />
		<cfset assertEquals(stProperties.data,"hello","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_recordnotexist" access="public" displayname="Get data (record does not exist)" dependsOn="deployType,dropType">
		<cfset var schema = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeB",objectid=createuuid(),dsn=this.dsn) />
		
		<cfset assertEquals(structkeylist(stProperties),"","Invalid return struct") />
	</cffunction>
	
	<cffunction name="getData_nullstring" access="public" displayname="Get data (null string)" dependsOn="deployType,dropType,createData_nullstring">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfset stProperties = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties,"j"),"Invalid return struct") />
		<cfset assertEquals(stProperties.j,"","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_nulldatenew" access="public" displayname="Get data (null date new way)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfquery datasource="#this.dsn#" name="q">
			update	#this.dbowner#dummyContentTypeA
			set		f=null
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		<cfset stProperties = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties,"f"),"Invalid return struct") />
		<cfset assertEquals(stProperties.f,"","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_nulldateold" access="public" displayname="Get data (null date old way)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfquery datasource="#this.dsn#" name="q">
			update	#this.dbowner#dummyContentTypeA
			set		f=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('yyyy',200,now())#" />
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		<cfset stProperties = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties,"f"),"Invalid return struct") />
		<cfset assertEquals(stProperties.f,"","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_simplearrays" access="public" displayname="Get data (simple arrays)" dependsOn="deployType,dropType,createData_simplearrays">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var stProperties2 = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.a = arraynew(1) />
		<cfset stProperties.a[1] = createuuid() />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfset stProperties2 = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties2,"a"),"Invalid return struct") />
		<cfset assertTrue(arraylen(stProperties2.a) eq 1,"Invalid array data") />
		<cfset assertEquals(stProperties2.a[1],stProperties.a[1],"Incorrect data returned") />
	</cffunction>
	
	<cffunction name="getData_extendedarrays" access="public" displayname="Get data (extended arrays)" dependsOn="deployType,dropType,createData_extendedarrays">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var stProperties2 = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.b = arraynew(1) />
		<cfset stProperties.b[1] = structnew() />
		<cfset stProperties.b[1].q = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfset stProperties2 = this.db.getData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertTrue(structkeyexists(stProperties2,"b"),"Invalid return struct") />
		<cfset assertTrue(arraylen(stProperties2.b) eq 1,"Invalid array data") />
		<cfset assertTrue(isstruct(stProperties2.b[1]),"Array items should be structs") />
		<cfset assertEquals(stProperties2.b[1].q,"hello","Incorrect data returned") />
	</cffunction>
	
	<cffunction name="deleteData_objectid" access="public" displayname="Delete data (objectid primary key)" dependsOn="deployType,dropType,createData_objectid">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stResult2 = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeB") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeB",bDropTable=true,dsn=this.dsn) />
		
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeB",stProperties=stProperties,dsn=this.dsn) />
		<cfset stResult2 = this.db.deleteData(typename="farcry.core.tests.resources.dummyContentTypeB",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult2)),"text"),"bSuccess,results","Invalid return struct") />
		<cfset assertTrue(stResult2.bSuccess,"Function did not return success flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeB
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		<cfset assertEquals(q.recordcount,0,"Record found in database") />
	</cffunction>
	
	<cffunction name="deleteData_parentidseq" access="public" displayname="Delete data (parentid+seq primary key)" dependsOn="deployType,dropType,createData_parentidseq">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset schema = this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA_c") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.parentid = createuuid() />
		<cfset stProperties.seq = 10 />
		<cfset stProperties.data = "hello" />
		<cfset stResult = this.db.getGateway(this.dsn).createData(schema=schema.fields.a,stProperties=stProperties) />
		<cfset stResult = this.db.getGateway(this.dsn).deleteData(schema=schema.fields.a,parentid=stProperties.parentid,seq=stProperties.seq) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult)),"text"),"bSuccess,results","Invalid return struct") />
		<cfset assertTrue(stResult.bSuccess,"Function did not return success flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_c
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.parentid#" />
					and seq=<cfqueryparam cfsqltype="cf_sql_integer" value="#stProperties.seq#" />
		</cfquery>
		<cfset assertEquals(q.recordcount,0,"Record found in database") />
	</cffunction>

	<cffunction name="deleteData_arrays" access="public" displayname="Delete data (arrays)" dependsOn="deployType,dropType,createData_simplearrays,createData_extendedarrays">
		<cfset var schema = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stResult2 = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var q = "" />
		
		<cfset this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset this.db.deployType(typename="farcry.core.tests.resources.dummyContentTypeA",bDropTable=true,dsn=this.dsn) />
		
		<cfset stProperties.a = arraynew(1) />
		<cfset stProperties.a[1] = createuuid() />
		<cfset stProperties.b = arraynew(1) />
		<cfset stProperties.b[1] = structnew() />
		<cfset stProperties.b[1].q = "hello" />
		<cfset stResult = this.db.createData(typename="farcry.core.tests.resources.dummyContentTypeA",stProperties=stProperties,dsn=this.dsn) />
		<cfset stResult2 = this.db.deleteData(typename="farcry.core.tests.resources.dummyContentTypeA",objectid=stResult.objectid,dsn=this.dsn) />
		
		<cfset assertEquals(listsort(lcase(structkeylist(stResult2)),"text"),"bSuccess,results","Invalid return struct") />
		<cfset assertTrue(stResult2.bSuccess,"Function did not return success flag") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_a
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		<cfset assertEquals(q.recordcount,0,"Record found in simple array table") />
		
		<cfquery datasource="#this.dsn#" name="q">
			select	*
			from	#this.dbowner#dummyContentTypeA_b
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stResult.objectid#" />
		</cfquery>
		<cfset assertEquals(q.recordcount,0,"Record found in extended array table") />
	</cffunction>
	
	
	<cffunction name="FC1906_repairProperty_integertostring" access="public" displayname="FC-1906: Repair property (integer to string)" dependsOn="deployType,dropType,diffSchema_numerictostring">
		<cfset var schema = structnew() />
		<cfset var stDiff = structnew() />
		
		<cfset var gateway = this.db.initialiseGateway(dsn=this.dsn,dbowner=this.dbowner,dbtype=this.dbtype) />
		
		<cfset this.db.initialiseTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		<cfset schema = this.db.getTableMetadata("farcry.core.tests.resources.dummyContentTypeA") />
		
		<cfset gateway.deploySchema(schema=schema,bDropTable=true) />
		
		<cfset schema.fields["h"].type = "string" />
		<cfset schema.fields["h"].precision = "250" />
		
		<cfset gateway.repairColumn(schema=schema,propertyname="h") />
		
		<cfset stDiff = this.db.getGateway(this.dsn).diffSchema(schema=schema) />
		
		<cfset assertTrue(structisempty(stDiff.tables),"Table conflicts") />
	</cffunction>
	
</cfcomponent>