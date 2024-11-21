<cfcomponent output="false" hint="This component acts as a generic container for metadata about a database table. It provides utility methods to interact with the metadata and encapsulates the checking for and defalut values of metadata attributes.">


	<cffunction name="init" access="public" output="false" hint="Initializes the instance data for the component" returntype="farcry.core.packages.fourq.TableMetadata">
		<cfset variables.validDataTypes = "array,boolean,datetime,date,numeric,string,nstring,uuid,variablename,color,email,longchar,int,integer,smallint,decimal,text,varchar,datetime" />
		<cfset variables.tableDefinition = structNew() />
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getTableName" access="public" returntype="string" output="false" hint="Returns the name of the table that this metadata represents">
		<cfreturn variables.tableName />
	</cffunction>
	
	
	<cffunction name="getTableDefinition" access="public" output="false" returntype="struct" hint="Returns a struct of structs. Each sub-struct contains the keys type,default,nullable. The name of the key for each sub-struct is the desired name of the column in the table.">
		<cfreturn variables.tableDefinition />
	</cffunction>
	
	
	<cffunction name="parseMetadata" access="public" returntype="void" output="false" hint="Parses the given structure and generates metadata that can be used by the DBGateway components." >
		<cfargument name="md" type="struct" required="true" hint="Metadata for a component that follows the farcry convention of using <cfproperty> tags to declare database specific information. This would typically be the result of calling getMetaData() on the component.">
		<cfargument name="bForceRefresh" type="boolean" required="false" default="false" hint="Flag that will force a refresh of the metadata if required." />
		<cfset var i = "" />
		<cfset var prop = "" />
		
		<cfif structKeyExists(arguments.md,'bAbstract')>
			<cfthrow type="farcry.core.packages.fourq.tablemetadata.abstractTypeException" message="Abstract components cannot be used for table definitions." detail="An attempt was made to generate database table information for an abstract component #md.name# (#md.path#). Abstract components cannot be used for table definitions. Either extend the component or set the bAbstract attribute of the cfcomponent tag to false.">
		</cfif>
		
		<!--- Make sure we set the table name first time through --->
		<cfif not structKeyExists(variables,'tablename')>
			<cfset variables.tableName = listfirst(listlast(arguments.md.path,'\/'),'.') />
		</cfif>

		<!--- 
		REPLACED WITH SIMPLE CALL FROM THE APPLICATION.STCOAPI IF ALREADY AVAILABLE
		 --->
		<cfif NOT bForceRefresh AND structKeyExists(application, "stcoapi") AND structKeyExists(application.stcoapi, variables.tablename) AND structKeyExists(application.stcoapi[variables.tablename], "tableDefinition")>
			<cfset variables.tableDefinition = application.stcoapi[variables.tablename].tableDefinition />
		<cfelse>
		
			<cfset parseComponentMetadata(md=arguments.md) />
			<cfif structKeyExists(variables, "tableDefinition")>
				<cfloop collection="#variables.tableDefinition#" item="prop">
					<cfif NOT structKeyExists(variables.tableDefinition[prop],'type')>
						<cfthrow type="farcry.core.packages.fourq.TableMetadata.InvalidPropertyException" message="PLEASER: The cfproperty tag for #variables.tableDefinition[prop].name# does not have a type attribute." detail="The type attribute of the cfproperty tag is required for the fourq persistence layer." />
					</cfif>
					<cfif NOT structKeyExists(variables.tableDefinition[prop],'default')>
						<cfset variables.tableDefinition[prop].default = "" />
					</cfif>
					<cfif NOT structKeyExists(variables.tableDefinition[prop],'required')>
						<cfset variables.tableDefinition[prop].required = false />
					</cfif>
					<cfif NOT structKeyExists(variables.tableDefinition[prop],'nullable')>
			
						<cfif variables.tableDefinition[prop].required>
							<cfset variables.tableDefinition[prop].nullable = false />
						<cfelse>
							<cfset variables.tableDefinition[prop].nullable = true />
						</cfif>
					</cfif>
				</cfloop>
			</cfif>			
		</cfif>
			
	</cffunction>

	<cffunction name="parseComponentMetadata" access="private" output="false" returntype="void" hint="Parses the given component metadata structure and generates metadata that can be used by the DBGateway components." >
		<cfargument name="md" type="struct" required="true" hint="Metadata for a component that follows the farcry convention of using <cfproperty> tags to declare database specific information. This would typically be the result of calling getMetaData() on the component.">
		
		<cfset var i = "" />
		<cfset var bSuccess = true />

		<!--- Make sure we set the table name first time through --->
		<cfif not structKeyExists(variables,'tablename')>
			<cfset variables.tableName = listLast(arguments.md.name,'.') />
		</cfif>
		
			
		<cfif structKeyExists(arguments.md,'properties')>

			<cfparam name="variables.tableDefinition" default="#structNew()#" >
		
			<!--- If we got to here there should be some properties to parse --->
			<cfloop from="1" to="#arrayLen(arguments.md.properties)#" index="i">

				<cfif not structKeyExists(variables.tableDefinition,arguments.md.properties[i].name)>
					<cfset variables.tableDefinition[arguments.md.properties[i].name] = structNew() />
				</cfif>

				<cfset bSuccess = StructAppend(variables.tableDefinition[arguments.md.properties[i].name],parseProperty(arguments.md.properties[i]),false)>

			</cfloop>
			
			
		</cfif>
			
		<!--- Parse the next level if it exists --->
		<cfif structKeyExists(arguments.md,'extends')>
			<cfset parseComponentMetadata(arguments.md.extends) />
		</cfif>
			
	</cffunction>
	
	<cffunction name="parseProperty" access="private" output="false" returntype="struct" hint="Parses the data out of cfproperty tag metadata and inserts default values for unspecified attributes">
		<cfargument name="data" required="true" type="struct" />
		<cfset var prop = structNew() />

		<cfif structKeyExists(arguments.data,'type')>
			<cfif listFindNoCase(variables.validDataTypes,arguments.data.type)>
				<cfset prop.type = arguments.data.type />
			</cfif>
		</cfif>
		
		<cfset prop.name = arguments.data.name />
		
		<cfif structKeyExists(arguments.data,'type') AND structKeyExists(prop,'type') AND prop.type eq 'array'>
		  <cfreturn parseArrayProperty(arguments.data) />
		</cfif>
		
		<cfreturn prop />
	</cffunction>
		
	
	<cffunction name="parseArrayProperty" access="private" output="false" returntype="struct" hint="Parses the data out of cfproperty tag for array properties">
		<cfargument name="data" required="true" type="struct" />
		
		<cfset var prop = structNew() />
		<cfset var arrayProps = "" />
		<cfset var i = "" />
		<cfset var fieldName = "" />
		<cfset var dataType = "" />
		<cfset var reservedFieldNames = "parentid,data,seq,tablename" />
		<cfset prop.type = arguments.data.type />
		<cfset prop.name = arguments.data.name />
		<cfset prop.fields = structNew() />
		<cfset prop.fields.parentid = structNew() />
		<cfset prop.fields.parentid.type = "uuid" />
		<cfset prop.fields.parentid.name = "parentid" />
		<cfset prop.fields.parentid.default = "NULL" />
		<cfset prop.fields.parentid.nullable = true />
		
		<cfset prop.fields.data = structNew() />
		<cfset prop.fields.data.type = "string" />
		<cfset prop.fields.data.name = "data" />
		<cfset prop.fields.data.default = "NULL" />
		<cfset prop.fields.data.nullable = true />
		
		<cfset prop.fields.seq = structNew() />
		<cfset prop.fields.seq.type = "numeric" />
		<cfset prop.fields.seq.name = "seq" />
		<cfset prop.fields.seq.default = "NULL" />
		<cfset prop.fields.seq.nullable = true />
		
		<cfset prop.fields.typename = structNew() />
		<cfset prop.fields.typename.type = "string" />
		<cfset prop.fields.typename.name = "typename" />
		<cfset prop.fields.typename.default = "NULL" />
		<cfset prop.fields.typename.nullable = true />
		
		<cfif structKeyExists(arguments.data,'arrayProps')>
			<cfset arrayProps = listToArray(arguments.data.arrayProps,";") />
			<cfloop from="1" to="#arrayLen(arrayProps)#" index="i">
			  <cfset fieldName = listFirst(arrayProps[i],":") />
			  <cfset dataType = listRest(arrayProps[i],":") />
			  <cfif listFindNoCase(reservedFieldNames,fieldName)>
			    <cfthrow type="farcry.core.packages.fourq.TableMetadata.InvalidArrayPropertyException" message="The cfproperty tag for #arguments.data.name# is using a reserved field name in the arrayProps attribute." detail="The list of reserved field names is #reservedFieldNames#. The arrayProps attribute has a value of ""#arguments.data.arrayProps#""." />
			  </cfif>
			  
			  <cfif not listFindNoCase(variables.validDataTypes,dataType)>
					<cfthrow type="farcry.core.packages.fourq.TableMetadata.InvalidArrayPropertyException" message="The cfproperty tag for #arguments.data.name# has an invalid data type in the arrayProps attribute." detail="The list of valid datatypes is #variables.validDataTypes#. The arrayProps attribute has a value of ""#arguments.data.arrayProps#""." />
				</cfif>
				
			  <cfset prop.fields[fieldName] = structNew() />
			  <cfset prop.fields[fieldname].type = dataType />
			  <cfset prop.fields[fieldname].name = fieldName />
			  <cfset prop.fields[fieldName].default = "NULL" />
				<cfset prop.fields[fieldName].nullable = true />
			</cfloop>
		</cfif>
		
<!--- 		<cfif structKeyExists(arguments.data,'required') AND arguments.data.required>
			<cfset prop.nullable = false />
		<cfelse>
			<cfset prop.nullable = true />
		</cfif> --->
		
		<cfreturn prop />
	</cffunction>
		
	
</cfcomponent>