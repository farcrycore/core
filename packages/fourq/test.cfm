<!------------------------------------------------------------------------
fourQ COAPI
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/test.cfm,v 1.1 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.1 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Stephen Milligan (spike@spikefu.com)

Description:
Provides test routines to ensure that the rest of the code in the fourq
module works correctly as long as the data passed to them is correct.
------------------------------------------------------------------------->
<cfapplication name="farcry_test" sessionmanagement="true" />
<cfset application.dsn = "farcry_test" />
<cfset application.dbtype = "MySQL" />
<cfset application.dbowner = "" />


<cfoutput>
<html>
	<head>
		<title>fourq test module</title>
		<style>
			dt {
				font-family: Arial;
				font-weight: bold;
				font-variant: small-caps;
			}
			dd.failure {
				font-weight: bold;
				color: red;
			}
			b.codelocation {
				color: ##333;
			}
		</style>
	</head>
	<body>
	
	<h3>Farcry fourq test module</h3>
	
	<div>
		Running all tests with the following variables:<br />
		application.dsn: "#application.dsn#"<br />
		application.dbtype: "#application.dbtype#"<br />
		application.dbowner: "#application.dbowner#"<br />		
	</div>
	
	<!--- Make sure we can create an instance of the DBGatewayFactory --->
	<dl>
		<dt>Gateway factory initialization</dt>
		<cftry>
			<cfset factory = createObject('component','farcry.farcry_core.fourq.DBGatewayFactory').init() />
			<dd>OK!</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#cfcatch.message#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>


	<!--- Make sure we can get a gateway with the application variables (application.dsn, application.dbowner, application.dbtype) --->
	<dl>
		<dt>Gateway retrieval from factory using application default variables - application.dsn, application.dbowner, application.dbtype</dt>
		<cftry>
			<cfset gateway = factory.getGateway(application.dsn,application.dbowner,application.dbtype) />
			<dd>OK!</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>
	
	<!--- Parse the metadata for an abstract component --->
	<dl>
		<dt>Ensure that we get an exception if we try to parse the metadata for abstract component farcry.farcry_core.fourq.test.Abstract.</dt>
		<cftry>
			<cfset tableMetadata = createobject('component','farcry.farcry_core.fourq.TableMetadata').init() />
			<cfset abstract = createObject('component','farcry.farcry_core.fourq.test.Abstract') />
			<cfset tableMetadata.parseMetadata(getMetadata(abstract)) />
			<cfthrow type="farcry.farcry_core.fourq.test" message="TableMetadata did not throw an exception." detail="The farcry.farcry_core.fourq.TableMetadata component did not throw an exception when the parseMetadata() method was called on an abstract component.">
			<cfcatch type="farcry.farcry_core.fourq.tablemetadata.abstractTypeException">
				<dd>OK!</dd>
			</cfcatch>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>
	
	<!--- Parse the metadata for a valid component --->
	<dl>
		<dt>Ensure that we can create table metadata for component farcry.farcry_core.fourq.test.ValidTest .</dt>
		<cftry>
			<cfset tableMetadata = createobject('component','farcry.farcry_core.fourq.TableMetadata').init() />
			<cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset tableMetadata.parseMetadata(getMetadata(test)) />
			<dd>OK!</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>


	<!--- Test run deployment of a component. --->
	<dl>
		<dt>Dry run test of component deployment.</dt>
		<cftry>
			<cfset result = gateway.deployType(tableMetadata) />
			<dd>OK!<br/>
<pre>
#result.sql#
</pre>
<cfloop from="1" to="#arrayLen(result.arrayTables)#" index="i">
<pre>
#result.arrayTables[i].sql#
</pre>
</cfloop>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>



	<!--- Component deployment with bDropTable set to true component. --->
	<dl>
		<dt>Component deployment to database.</dt>
		<cftry>
			<cfset result = gateway.deployType(tableMetadata,true,false) />
			<dd>OK!<br/>
<pre>
#result.sql#
</pre>
<cfloop from="1" to="#arrayLen(result.arrayTables)#" index="i">
<pre>
#result.arrayTables[i].sql#
</pre>
</cfloop>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>



	<!--- Component deployment using fourq. --->
	<dl>
		<dt>Component deployment to database using fourq.</dt>
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.deployType(true,false) />
			<dd>OK!<br/>
<pre>
#result.sql#
</pre>
<cfloop from="1" to="#arrayLen(result.arrayTables)#" index="i">
<pre>
#result.arrayTables[i].sql#
</pre>
</cfloop>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>



<cfset complexObjectid = createUUID() />
	<!--- Insert a complex record. --->
	<dl>
		<dt>Create a new record for the test component with complex array data.</dt>
		<cfset stProperties = structNew() />
		<cfset stProperties.createdBy = "Unit Test" />
		<cfset stProperties.dateTimeCreated = Now() />
		<cfset stProperties.dateTimeLastUpdated = stProperties.dateTimeCreated />
		<cfset stProperties.foo = "Test for foo" />
		<cfset stProperties.label = "Test label" />
		<cfset stProperties.lastUpdatedBy = "Unit Test" />
		<cfset stProperties.locked = "false" />
		<cfset stProperties.objectid = complexObjectId />
		<cfset stProperties.arrayTest = arrayNew(1) />
		<cfset stArrayProp = structNew() />
		<cfset stArrayProp.age = 32 />
		<cfset stArrayProp.fname = "Spike" />
		<cfset stArrayProp.lname = "Milligan" />
		<cfset stArrayProp.data = createUUID() />
		<cfset arrayAppend(stProperties.arrayTest,stArrayProp) />
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.createData(stProperties=stProperties,user='Unit Test',bAudit=false) />
			<dd>OK!<br/>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>






  <cfset simpleObjectid = createUUID() />
	<!--- Insert a simple record. --->
	<dl>
		<dt>Create a new record for the test component with simple array data.</dt>
		<cfset stProperties = structNew() />
		<cfset stProperties.createdBy = "Unit Test" />
		<cfset stProperties.dateTimeCreated = Now() />
		<cfset stProperties.dateTimeLastUpdated = stProperties.dateTimeCreated />
		<cfset stProperties.foo = "Test for foo" />
		<cfset stProperties.label = "Test label" />
		<cfset stProperties.lastUpdatedBy = "Unit Test" />
		<cfset stProperties.locked = "false" />
		<cfset stProperties.objectid = simpleObjectid />
		<cfset stProperties.arrayTest = arrayNew(1) />
		<cfset arrayAppend(stProperties.arrayTest,"Value 1") />
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.createData(stProperties=stProperties,user='Unit Test',bAudit=false) />
			<dd>OK!<br/>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>


	<!--- Update the complex record. --->
	<dl>
		<dt>Update the complex array record.</dt>
		<cfset stProperties = structNew() />
		<cfset stProperties.createdBy = "Unit Test" />
		<cfset stProperties.dateTimeCreated = Now() />
		<cfset stProperties.dateTimeLastUpdated = stProperties.dateTimeCreated />
		<cfset stProperties.foo = "Test for foo" />
		<cfset stProperties.label = "Test label" />
		<cfset stProperties.lastUpdatedBy = "Unit Test" />
		<cfset stProperties.locked = "false" />
		<cfset stProperties.objectid = complexObjectId />
		<cfset stProperties.arrayTest = arrayNew(1) />
		<cfset stArrayProp = structNew() />
		<cfset stArrayProp.age = 302 />
		<cfset stArrayProp.fname = "Bob" />
		<cfset stArrayProp.lname = "Cratchitt" />
		<cfset stArrayProp.data = createUUID() />
		<cfset arrayAppend(stProperties.arrayTest,stArrayProp) />
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.setData(stProperties=stProperties,user='Unit Test',bAudit=false) />
			<dd>OK!<br/>
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>




	<!--- Retrieve the complex record. --->
	<dl>
		<dt>Retrieve the complex array record.</dt>
		
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.getData(objectid=complexObjectID,bFullArrayProps=true) />
			<dd>OK!<br/>
			<cfdump var="#result#">
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>





	<!--- Retrieve the complex record with old array props. --->
	<dl>
		<dt>Retrieve the complex array record with default array props.</dt>
		
		<cftry>
		  <cfset test = createObject('component','farcry.farcry_core.fourq.test.ValidTest') />
			<cfset result = test.getData(objectid=complexObjectID,bFullArrayProps=false) />
			<dd>OK!<br/>
			<cfdump var="#result#">
			</dd>
			<cfcatch>
				<dd class="failure">FAILED!
				<p>#formatError(cfcatch)#</p>
				</dd>
				<cfabort>
			</cfcatch>
		</cftry>
	</dl>











	</body>
</html>
</cfoutput>




<!--- 
  Miscellaneous functions below here.      
 --->



<cffunction name="formatError" access="private" output="true" returntype="void">
	<cfargument name="error" type="any" required="true" />
	<cfset var context = "" />
	<cfset var i = "" />
	#arguments.error.message#
	<br />
	<br />
	#arguments.error.detail#
	<br />
	<br />
	<cfif structKeyExists(arguments.error,'tagcontext')>
		<cfloop from="1" to="#arrayLen(arguments.error.tagcontext)#" index="i">	
			<cfset context = arguments.error.tagcontext[i] />
			<cfif i eq 1>
				At line <b class="codelocation">#context.line#:#context.column#</b> in template #context.template#
			<cfelse>
				<br />Called from <b class="codelocation">#context.line#:#context.column#</b> in template #context.template#
			</cfif>
		</cfloop>
	<cfelse>
		Error location could not be automatically determined from error structure.
		<cfdump var="#arguments.error#">
	</cfif>
	
</cffunction>