<cfcomponent displayname="Database API" hint="API for database gateway functions." output="false">
	
	<!--- Gateways by DSN --->
	<cfset variables.gateways = structnew() />
	<cfset variables.paths = structnew() />
	<cfset this.tablemetadata = structnew() />
	<cfset variables.tables = structnew() />
	
	
	<!--- DB INITIALISATION --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="loglocation" type="string" required="false" default="" />
		
		<cfset variables.paths = getDBTypes() />
		<cfset variables.modes = {
			"read" = application.dsn_read,
			"write" = application.dsn_write
		} />

		<cfset createGateway(dsn=application.dsn_read, dbtype=application.dbtype_read, dbowner=application.dbowner_read) />
		<cfset createGateway(dsn=application.dsn_write, dbtype=application.dbtype_write, dbowner=application.dbowner_write) />
		
		<cfset this.logChangeFlags = "" />
		<cfset this.logLocation = arguments.loglocation />
		
		<cfreturn this />
	</cffunction>
	
	
	<!--- INTERNAL DB FUNCTIONS --->
	<cffunction name="getDBTypes" access="public" output="false" returntype="struct" hint="Returns a struct mapping dbtype keys to their gateway components">
		<cfset var gatewaypath = "" />
		<cfset var o = "" />
		<cfset var stMeta = structnew() />
		<cfset var dbtype = "" />
		<cfset var thisdbtype = "" />
		<cfset var stResult = structnew() />
		<cfset var qItems = "" />
		<cfset var locations = "#expandpath('/farcry/core/packages/dbgateways/')#|farcry.core.packages.dbgateways" />
		<cfset var thislocation = "" />
		
		<!--- Update potential gateway locations --->
		<cfif structkeyexists(application,"plugins")>
			<cfloop list="#application.plugins#" index="thislocation">
				<cfif directoryexists(expandpath('/farcry/plugins/#thislocation#/packages/dbgateways/'))>
					<cfset locations = listappend(locations,"#expandpath('/farcry/plugins/#thislocation#/packages/dbgateways/')#|farcry.plugins.#thislocation#.packages.dbgateways") />
				</cfif>
			</cfloop>
		</cfif>
		<cfif structkeyexists(application,"projectdirectoryname")>
			<cfif directoryexists(expandpath('/farcry/projects/#application.projectdirectoryname#/packages/dbgateways/'))>
				<cfset locations = listappend(locations,"#expandpath('/farcry/projects/#application.projectdirectoryname#/packages/dbgateways/')#|farcry.projects.#application.projectdirectoryname#.packages.dbgateways") />
			</cfif>
		</cfif>
		
		<!--- Work out which gateway component corresponds to which dbtype --->
		<cfloop list="#locations#" index="thislocation">
			<cfdirectory action="list" directory="#listfirst(thislocation,'|')#" filter="*.cfc" name="qItems" />
			<cfloop query="qItems">
				<cfset gatewaypath = "#listlast(thislocation,'|')#.#listfirst(name,'.')#" />
				<cfset o = createobject("component",gatewaypath) />
				<cfset stMeta = getmetadata(o) />
				<cfif structkeyexists(stMeta,"dbtype")>
					<cfset dbtype = listfirst(stMeta.dbtype,":") />
				<cfelse>
					<cfset dbtype = listlast(stMeta.fullname,".") />
				</cfif>
				
				<cfloop list="#dbtype#" index="thisdbtype">
					<cfparam name="stResult.#thisdbtype#" default="#arraynew(1)#" />
					<cfset arrayappend(stResult[thisdbtype],gatewaypath) />
				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="initialiseGateway" access="public" output="false" returntype="any" hint="Creates the gateway for a set of connection parameters">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbtype" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		
		<cfset var i = 0 />
		<cfset var oMixin = "" />
		<cfset var thismethod = "" />
		<cfset var oGateway = "" />
		
		<cfif not structkeyexists(variables.paths,arguments.dbtype)>
			<cflog file="coapi" type="warning" text="Creating #variables.paths['default']# gateway for #arguments.dsn# because no recognized connection type was specified in argument 'dbtype' to method getGateway(). Connection type passed was <strong>#arguments.dbtype#</strong>" />
			<cfset arguments.dbtype = "default" />
		</cfif>
		
		<cfset oGateway = createObject('component',variables.paths[arguments.dbtype][1]).init(argumentCollection=arguments) />
		<cfif arguments.dbtype neq "default" and structkeyexists(variables.paths,"default")>
			<cfloop from="1" to="#arraylen(variables.paths['default'])#" index="i">
				<cfset oMixin = createobject("component",variables.paths['default'][i]) />
				<cfloop collection="#oMixin#" item="thismethod">
					<cfset oGateway["#thismethod#"] = oMixin[thismethod] />
				</cfloop>
			</cfloop>
		</cfif>
		<cfloop from="2" to="#arraylen(variables.paths[arguments.dbtype])#" index="i">
			<cfset oMixin = createobject("component",variables.paths[arguments.dbtype][i]) />
			<cfloop collection="#oMixin#" item="thismethod">
				<cfset oGateway["#thismethod#"] = oMixin[thismethod] />
			</cfloop>
		</cfloop>
		
		<cfreturn oGateway />
	</cffunction>

	<cffunction name="createGateway" access="public" output="false" returntype="any" hint="Creates a gateway for the given db connection parameters, and adds it to the application scope">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbtype" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />

		<cfset variables.gateways[arguments.dsn] = initialiseGateway(argumentCollection=arguments) />

		<cfreturn variables.gateways[arguments.dsn] />
	</cffunction>
	
	<cffunction name="getGateway" access="public" output="false" returntype="any" hint="Gets the gateway for the given db connection parameters">
		<cfargument name="dsn" type="string" required="false" default="" />
		<cfargument name="mode" type="string" required="false" default="" />

		<cfif len(arguments.mode) and not len(arguments.dsn) and structKeyExists(variables.modes, arguments.mode)>
			<cfset arguments.dsn = variables.modes[arguments.mode] />
		<cfelseif not len(arguments.dsn)>
			<cfthrow message="getGateway() requires a dsn or mode" />
		</cfif>

		<!--- DSN exists --->
		<cfreturn variables.gateways[arguments.dsn] />
	</cffunction>

	<cffunction name="getGatewayProperties" access="public" output="false" returntype="query" hint="Returns information about all registered gateways">
		<cfset var qResult = querynew("dsn,dbowner,dbtype,dbtype_label,read,write", "varchar,varchar,varchar,varchar,bit,bit") />
		<cfset var key = "" />
		<cfset var stProps = "" />

		<cfloop collection="#variables.gateways#" item="key">
			<cfset stProps = variables.gateways[key].getProperties() />
			<cfset queryAddRow(qResult) />
			<cfset querySetCell(qResult, "dsn", stProps.dsn) />
			<cfset querySetCell(qResult, "dbowner", stProps.dbowner) />
			<cfset querySetCell(qResult, "dbtype", stProps.dbtype) />
			<cfset querySetCell(qResult, "dbtype_label", stProps.dbtype_label) />
			<cfset querySetCell(qResult, "read", stProps.dsn eq variables.modes.read) />
			<cfset querySetCell(qResult, "write", stProps.dsn eq variables.modes.write) />
		</cfloop>

		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="initialiseTableMetadata" access="public" output="false" returntype="any" hint="Initialises and returns table metadata for a given content type">
		<cfargument name="typename" type="any" required="true" hint="The package path or type component to process" />
		<cfargument name="schema" type="struct" required="false" hint="Use to provide a manually generated schema" />
		
		<cfif structkeyexists(arguments,"schema")>
			<cfif not issimplevalue(arguments.typename)>
				<cfthrow message="When provided your own schema, the typename must be a string" />
			<cfelse>
				<cfset this.tablemetadata[arguments.typename] = duplicate(arguments.schema) />
				<cfset this.tablemetadata[listlast(arguments.typename,'.')] = duplicate(arguments.schema) />
			</cfif>
		<cfelse>
			<cfset this.tablemetadata[arguments.typename] = parseComponentMetadata(md=getMetadata(createobject("component",arguments.typename))) />
			<cfset this.tablemetadata[listlast(arguments.typename,'.')] = duplicate(this.tablemetadata[arguments.typename]) />
		</cfif>
		
		<cfset variables.tables[this.tablemetadata[arguments.typename].tablename] = arguments.typename />
		
		<cfreturn this.tablemetadata[arguments.typename] />
	</cffunction>
	
	<cffunction name="getTableMetadata" access="public" output="false" returntype="any" hint="Returns the metadata for a given content type">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		
		<cfif not structkeyexists(this.tablemetadata,arguments.typename)>
			<cfreturn initialiseTableMetadata(typename=arguments.typename) />
		<cfelse>
			<cfreturn this.tablemetadata[arguments.typename] />
		</cfif>
	</cffunction>
	
	
	<!--- COMPONENT METADATA PARSING --->
	<cffunction name="parseComponentMetadata" access="private" output="false" returntype="struct" hint="Parses the given component metadata structure and generates metadata that can be used by the DBGateway components." >
		<cfargument name="md" type="struct" required="true" hint="Metadata for a component that follows the farcry convention of using <cfproperty> tags to declare database specific information. This would typically be the result of calling getMetaData() on the component.">
		<cfargument name="existing" type="struct" required="false" default="#structnew()#" hint="Metadata so far" />
		
		<cfset var stResult = duplicate(arguments.existing) />
		<cfset var stProp = structnew() />
		<cfset var i = "" />
		<cfset var j = "" />
		<cfset var tmpMD = structnew() />
		<cfset var stPropMap = structnew() />
		<cfset var aProps = arraynew(1) />
		<cfset var thisindex = "" />
		<cfset var thispropindex = 0 />
		
		<cfparam name="stResult.typename" default="#listfirst(listlast(arguments.md.path,'\/'),'.')#" />
		<cfparam name="stResult.tablename" default="#listfirst(listlast(arguments.md.path,'\/'),'.')#" />
		<cfparam name="stResult.fields" default="#structnew()#" />
		<cfparam name="stResult.arrayfields" default="#structnew()#" /><!--- To make associating extending array content types easier --->
		<cfparam name="stResult.indexes" default="#structnew()#" />
		
		<cfset tmpMD = arguments.md />
		<cfloop condition="not structisempty(tmpMD)">
			<cfif structkeyexists(tmpMD,"dsn") and not structKeyExists(stResult,"dsn")>
				<cfset stResult.dsn = tmpMD.dsn />
			</cfif>
			<cfif structkeyexists(tmpMD,"properties")>
				<cfloop from="1" to="#arrayLen(tmpMD.properties)#" index="i">
					<cfif structkeyexists(tmpMD.properties[i],"type") and tmpMD.properties[i].type eq "any">
						<cfset structdelete(tmpMD.properties[i],"type") />
					</cfif>
					
					<cfif structkeyexists(stPropMap,tmpMD.properties[i].name)>
						<cfset structappend(aProps[stPropMap[tmpMD.properties[i].name]],tmpMD.properties[i],false) />
					<cfelse>
						<cfset arrayappend(aProps,tmpMD.properties[i]) />
						<cfset stPropMap[tmpMD.properties[i].name] = i />
					</cfif>
				</cfloop>
			</cfif>
			<cfif structkeyexists(tmpMD,"extends")>
				<cfset tmpMD = tmpMD.extends />
			<cfelse>
				<cfset tmpMD = structnew() />
			</cfif>
		</cfloop>
		
		<cfloop from="1" to="#arrayLen(aProps)#" index="i">
			<cfparam name="stResult.fields.#aProps[i].name#" default="#structNew()#" />
			<cfset stProp = parseProperty(aProps[i],stResult.tablename) />
			<cfset StructAppend(stResult.fields[aProps[i].name],stProp,false) />
			<cfif stProp.type eq "array">
				<cfset stResult.arrayfields[stProp.tablename] = stProp.name />
			</cfif>
			
			<cfif structkeyexists(stProp,"index")>
				<cfloop list="#stProp.index#" index="thisindex">
					<cfif listlen(thisindex,":") eq 2>
						<cfset thispropindex = listlast(thisindex,":") />
						<cfset thisindex = listfirst(thisindex,":") />
					<cfelse>
						<cfset thispropindex = 0 />
					</cfif>
					<cfif not structkeyexists(stResult.indexes,thisindex)>
						<cfset stResult.indexes[thisindex] = structnew() />
						<cfset stResult.indexes[thisindex].name = thisindex />
						<cfif thisindex eq "primary">
							<cfset stResult.indexes[thisindex].type = "primary" />
						<cfelse>
							<cfset stResult.indexes[thisindex].type = "unclustered" />
						</cfif>
						<cfset stResult.indexes[thisindex].fields = arraynew(1) />
					</cfif>
					<cfif thispropindex><!--- Field specified a particular position --->
						<cfset stResult.indexes[thisindex].fields[thispropindex] = stProp.name />
					<cfelse><!--- Field did not specify a particular position: add to end --->
						<cfset arrayappend(stResult.indexes[thisindex].fields,stProp.name) />
						<cfset listsetat(stProp.index,listfindnocase(stProp.index,thisindex),"#thisindex#:#arraylen(stResult.indexes[thisindex].fields)#") />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfif not structkeyexists(stResult.indexes,"primary")>
			<cfif structkeyexists(stResult.fields,"objectid")>
				<cfset stResult.indexes.primary = structnew() />
				<cfset stResult.indexes.primary.name = "primary" />
				<cfset stResult.indexes.primary.type = "primary" />
				<cfset stResult.indexes.primary.fields = listtoarray("objectid") />
				<cfset stResult.fields.objectid.bPrimaryKey = true />
			<cfelse>
				<cfthrow message="No primary key has been specified for #stResult.tablename#">
			</cfif>
		</cfif>
		
		<!--- If this is an extended array content type, override the parent type's array schema --->
		<cfif structkeyexists(variables.tables,listfirst(stResult.tablename,"_")) 
			and structkeyexists(this.tablemetadata,variables.tables[listfirst(stResult.tablename,"_")])
			and structkeyexists(this.tablemetadata[variables.tables[listfirst(stResult.tablename,"_")]].arrayfields,stResult.tablename)>
			
			<cfset stResult.fields.parentid = createFieldStruct(name="parentid",default="",nullable=false,type="uuid",precision="",index="array_index:1") />
			<cfset stResult.fields.seq = createFieldStruct(name="seq",default=0,nullable=false,type="numeric",precision="",index="array_index:2") />
			<cfset stResult.name = this.tablemetadata[variables.tables[listfirst(stResult.tablename,"_")]].arrayfields[stResult.tablename] />
			<cfset stResult.type = "array" />
			<cfset stResult.precision = "" />
			<cfset stResult.bPrimaryKey = false />
			<cfset stResult.nullable = true />
			<cfset stResult.default = "NULL" />
			<cfparam name="stResult.indexes" default="#structnew()#" />
			<cfset stResult.indexes["array_index"] = structnew() />
			<cfset stResult.indexes["array_index"].name = "array_index" />
			<cfset stResult.indexes["array_index"].type = "unclustered" />
			<cfset stResult.indexes["array_index"].fields = listtoarray("parentid,seq") />
			
			<cfset this.tablemetadata[variables.tables[listfirst(stResult.tablename,"_")]].fields[stResult.name] = stResult />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="createFieldStruct" access="public" output="false" returntype="struct" hint="Creates a field struct from metadata">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="nullable" type="boolean" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="precision" type="string" required="false" default="" />
		<cfargument name="bPrimaryKey" type="boolean" required="false" default="false" />
		<cfargument name="default" type="any" required="false" default="" />
		<cfargument name="index" type="string" required="false" default="" />
		<cfargument name="savable" type="boolean" required="false" default="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult.name = arguments.name />
		<cfset stResult.nullable = arguments.nullable />
		<cfset stResult.bPrimaryKey = arguments.bPrimaryKey />
		<cfset stResult.default = arguments.default />
		<cfset stResult.index = arguments.index />
		<cfset stResult.savable = arguments.savable />
		
		<cfif stResult.index eq "true">
			<cfset stResult.index = "#name#_index" />
		</cfif>
		<cfif stResult.bPrimaryKey>
			<cfset stResult.index = listappend(stResult.index,"primary") />
		</cfif>
		<cfset stResult.index = listsort(stResult.index,"textnocase","asc") />
		
		<cfswitch expression="#arguments.type#">
			<cfcase value="array">
				<cfset stResult.type = "array" />
				<cfset stResult.precision = "" />
			</cfcase>
			<cfcase value="boolean">
				<cfset stResult.type = "numeric" />
				<cfset stResult.precision = "1,0" />
				<cfif stResult.default eq true>
					<cfset stResult.default = 1>
				<cfelseif stResult.default eq false>
					<cfset stResult.default = 0>
				<cfelse>
					<cfset stResult.default = "">
				</cfif>
			</cfcase>
			<cfcase value="date,datetime" delimiters=",">
				<cfset stResult.type = "datetime" />
				<cfset stResult.precision = "" />
			</cfcase>
			<cfcase value="numeric">
				<cfset stResult.type = "numeric" />
				<cfset stResult.precision = "10,2" />
			</cfcase>
			<cfcase value="string,nstring,varchar" delimiters=",">
				<cfset stResult.type = "string" />
				<cfset stResult.precision = "250" />
			</cfcase>
			<cfcase value="uuid">
				<cfset stResult.type = "string" />
				<cfset stResult.precision = "50" />
				<cfif not refindnocase("(^|,)#stResult.name#($|,)","objectid,parentid") and not listcontains(stResult.index,"#name#_index") and not listcontains(stResult.index,"primary")>
					<cfset stResult.index = listsort(listappend(stResult.index,"#name#_index:1"),"textnocase","asc") />
				</cfif>
			</cfcase>
			<cfcase value="variablename">
				<cfset stResult.type = "string" />
				<cfset stResult.precision = "64" />
			</cfcase>
			<cfcase value="color">
				<cfset stResult.type = "string" />
				<cfset stResult.precision = "20" />
			</cfcase>
			<cfcase value="email">
				<cfset stResult.type = "string" />
				<cfset stResult.precision = "255" />
			</cfcase>
			<cfcase value="longchar,text" delimiters=",">
				<cfset stResult.type = "longchar" />
				<cfset stResult.precision = "" />
			</cfcase>
			<cfcase value="integer,int" delimiters=",">
				<cfset stResult.type = "numeric" />
				<cfset stResult.precision = "11,0" />
			</cfcase>
			<cfcase value="smallint">
				<cfset stResult.type = "numeric" />
				<cfset stResult.precision = "11,0" />
			</cfcase>
			<cfcase value="decimal">
				<cfset stResult.type = "numeric" />
				<cfset stResult.precision = "10,2" />
			</cfcase>
			<cfdefaultcase>
				<!--- Type has been overridden --->
				<cfset stResult.type = arguments.type />
			</cfdefaultcase>
		</cfswitch>
		
		<cfif stResult.default eq "" and stResult.nullable>
			<cfset stResult.default = "NULL" />
		</cfif>
		
		<cfif len(arguments.precision)>
			<cfset stResult.precision = arguments.precision />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="parseProperty" access="private" output="false" returntype="struct" hint="Parses the data out of cfproperty tag metadata and inserts default values for unspecified attributes">
		<cfargument name="data" required="true" type="struct" hint="Struct out of the getMetadata struct for a property" />
		<cfargument name="parenttable" required="true" type="string" hint="The name of the parent table" />
		
		<cfset var name = arguments.data.name />
		<cfset var nullable = true />
		<cfset var default = "" />
		<cfset var precision = "" />
		<cfset var type = "" />
		<cfset var bPrimaryKey = false />
		<cfset var stResult = "" />
		<cfset var index = "" />
		<cfset var savable = true />
		<cfset var j	= '' />
		
		<!--- incorporate formtool specific defaults --->
		<cfif structkeyexists(arguments.data,"ftType") and isdefined("application.formtools.#arguments.data.ftType#.stProps")>
			<cfloop collection="#application.formtools[arguments.data.ftType].stProps#" item="j">
				<cfif not structkeyexists(arguments.data,j) and structkeyexists(application.formtools[arguments.data.ftType].stProps[j].METADATA,"default")>
					<cfset arguments.data[j] = application.formtools[arguments.data.ftType].stProps[j].METADATA.default />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif structkeyexists(arguments.data,"dbNullable")>
			<cfset nullable = arguments.data.dbNullable />
		<cfelseif structkeyexists(arguments.data,"required")>
			<cfset nullable = not arguments.data.required />
		<cfelse>
			<cfset nullable = true />
		</cfif>
		
		<cfif structkeyexists(arguments.data,"default")>
			<cfset default = arguments.data.default />
		</cfif>
		
		<cfif structkeyexists(arguments.data,"dbPrecision")>
			<cfset precision = arguments.data.dbPrecision />
		</cfif>
		
		<cfif structkeyexists(arguments.data,"dbType")>
			<cfset type = arguments.data.dbType />
		<cfelseif structkeyexists(arguments.data,"type")>
			<cfset type = arguments.data.type />
		<cfelse>
			<cfset type = "string" />
		</cfif>

		<cfif structkeyexists(arguments.data,"dbPrimaryKey")>
			<cfset bPrimaryKey = arguments.data.dbPrimaryKey />
		</cfif>
		
		<cfif structkeyexists(arguments.data,"dbIndex")>
			<cfset index = arguments.data.dbIndex />
		</cfif>
		
		<cfif structkeyexists(arguments.data,"bSave") and not arguments.data.bSave>
			<cfset savable = false />
		</cfif>
		
		<cfset stResult = createFieldStruct(name=name,nullable=nullable,default=default,type=type,precision=precision,bPrimaryKey=bPrimaryKey,index=index,savable=savable) />
		
		<cfif type eq "array">
			<!--- If there is an array content type for this property, that overrides everything else --->
			<cfset stResult.tablename = "#parenttable#_#stResult.name#" />
			
			<cfif refindnocase("\.#stResult.tablename#($|,)",structkeylist(this.tablemetadata))>
				<cfset stResult = this.tablemetadata[rereplacenocase(structkeylist(this.tablemetadata),".*(^|,)([^,]+\.#stResult.tablename#),?.*","\2")] />
				<cfset stResult.name = name />
				<cfset stResult.type = "array" />
				<cfset stResult.precision = "" />
				<cfset stResult.bPrimaryKey = false />
				<cfset stResult.nullable = true />
				<cfset stResult.default = "NULL" />
				<cfset stResult.fields.parentid = createFieldStruct(name="parentid",default="",nullable=false,type="uuid",precision="",index="array_index") />
				<cfset stResult.fields.seq = createFieldStruct(name="seq",default=0,nullable=false,type="numeric",precision="",index="array_index") />
				<cfparam name="stResult.indexes" default="#structnew()#" />
				<cfset stResult.indexes["array_index"] = structnew() />
				<cfset stResult.indexes["array_index"].name = "array_index" />
				<cfset stResult.indexes["array_index"].type = "unclustered" />
				<cfset stResult.indexes["array_index"].fields = listtoarray("parentid,seq") />
			<cfelse><!--- Simple or extended array --->
				<cfset stResult.fields = parseArrayFields(arguments.data) />
				<cfset stResult.indexes = structnew() />
				<cfset stResult.indexes["primary"] = structnew() />
				<cfset stResult.indexes["primary"].name = "primary" />
				<cfset stResult.indexes["primary"].type = "primary" />
				<cfset stResult.indexes["primary"].fields = listtoarray("parentid,seq") />
				<cfset stResult.indexes["data_index"] = structnew() />
				<cfset stResult.indexes["data_index"].name = "data_index" />
				<cfset stResult.indexes["data_index"].type = "unclustered" />
				<cfset stResult.indexes["data_index"].fields = listtoarray("data") />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="parseArrayFields" access="private" output="false" returntype="struct" hint="Parses the data out of cfproperty tag for array properties">
		<cfargument name="data" required="true" type="struct" />
		
		<cfset var fields = structNew() />
		<cfset var arrayProps = "" />
		<cfset var i = "" />
		<cfset var reservedFieldNames = "parentid,data,seq,typename" />
		
		<cfset fields.parentid = createFieldStruct(name="parentid",default="",nullable=false,type="uuid",precision="",bPrimaryKey=true) />
		<cfset fields.seq = createFieldStruct(name="seq",default=0,nullable=false,type="numeric",precision="",bPrimaryKey=true) />
		<cfset fields.data = createFieldStruct(name="data",default="NULL",nullable=true,type="string",precision="250",index="data_index:1") />
		<cfset fields.typename = createFieldStruct(name="typename",default="NULL",nullable=true,type="string",precision="") />
		
		<cfif structKeyExists(arguments.data,'arrayProps')>
			<cfloop list="#arguments.data.arrayProps#" delimiters=";" index="i">
				<cfif not listFindNoCase(reservedFieldNames,listFirst(i,":"))>
					<cfset fields[listFirst(i,":")] = createFieldStruct(name=listFirst(i,":"),nullable=true,default="NULL",type=listlast(i,":"),precision="") />
				<cfelse>
					<cfthrow type="farcry.core.packages.lib.db.InvalidArrayPropertyException" message="The cfproperty tag for #listFirst(i,':')# is using a reserved field name in the arrayProps attribute." detail="The list of reserved field names is #reservedFieldNames#. The arrayProps attribute has a value of ""#arguments.data.arrayProps#""." />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn fields />
	</cffunction>
	
	
	<!--- GENERAL ACCESS --->
	<cffunction name="createData" access="public" output="false" returntype="struct" hint="Create an object including array properties.  Pass in a structure of property values; arrays should be passed as an array. The objectID can be ommitted and one will be created, passed in as an argument or passed in as a key of stProperties argument.">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="stProperties" type="struct" required="true" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var stReturn = StructNew()>
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,arguments.typename) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		<cfset var schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfset stReturn = getGateway(dsn=arguments.dsn, mode="write").createData(schema=schema,stProperties=stProperties,logLocation=logLocation) />
		
		<cfif NOT stReturn.bSuccess>
			<cflog text="#serializeJSON(stReturn)#" file="coapi" type="error" application="yes" />
		</cfif>
		
    	<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Passes update data to the gateway">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="stProperties" required="true" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,listlast(arguments.typename,".")) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		<cfset var schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="write").setData(schema=schema,stProperties=arguments.stProperties,logLocation=logLocation) />
	</cffunction>
	
	<cffunction name="setArrayData" access="public" output="false" returntype="struct" hint="Passes update an array update to the gateway">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="propertyname" required="true" type="string" />
		<cfargument name="objectid" type="UUID" required="true" />
		<cfargument name="aProperties" required="true" type="array" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,arguments.typename) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		<cfset var schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="write").setArrayData(schema=schema.fields[arguments.propertyname],aProperties=arguments.aProperties,parentid=arguments.objectid,logLocation=logLocation) />
	</cffunction>
	
	<cffunction name="getData" access="public" output="false" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="bDepth" type="numeric" required="false" default="1" hint="0:Everything (with full structs for all array field elements),1:Everything (only extended array field as structs),2:No array fields,3:No array or longchar fields" />
		<cfargument name="fields" type="string" required="false" default="" hint="Overrides the default fields returned. NOTE: the bDepth field may restrict the list further." />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset arguments.schema = getTableMetadata(arguments.typename) />

		<cfif not len(arguments.dsn) and structKeyExists(arguments.schema, "dsn")>
			<cfset arguments.dsn = arguments.schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="read").getData(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var stReturn = StructNew()>
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,arguments.typename) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		
		<cfset arguments.schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(arguments.schema, "dsn")>
			<cfset arguments.dsn = arguments.schema.dsn />
		</cfif>

		<cfset stReturn = getGateway(dsn=arguments.dsn, mode="write").deleteData(argumentCollection=arguments,logLocation=logLocation) />
		
		<cfif NOT stReturn.bSuccess>
			<cflog text="#stReturn.message# #stReturn.results[arraylen(stReturn.results)].detail# [SQL: #stReturn.results[arraylen(stReturn.results)].sql#]" file="coapi" type="error" application="yes" />
		</cfif>
		
    	<cfreturn stReturn />
	</cffunction>
	
	
	<!--- LOGGING --->
	
	<cffunction name="getLogLocation" access="public" output="false" returntype="string" hint="Sets the file to which SQL is logged">
		
		<cfreturn this.logLocation />
	</cffunction>
	
	<cffunction name="setLogLocation" access="public" output="false" returntype="void" hint="Sets the file to which SQL is logged">
		<cfargument name="logLocation" type="string" required="true" />
		
		<cfset this.logLocation = arguments.logLocation />
	</cffunction>
	
	<cffunction name="getLogChangeFlags" access="public" output="false" returntype="string" hint="Returns a list of the types that are flaged to have all SQL logged">
		
		<cfreturn this.logChangeFlags />
	</cffunction>
	
	<cffunction name="setLogChangeFlags" access="public" output="false" returntype="void" hint="Sets the list of the types that are flaged to have all SQL logged">
		<cfargument name="logChanges" type="string" required="true" />
		
		<cfif len(arguments.logChanges) and not directoryexists(getdirectoryfrompath(this.logLocation))>
			<cfdirectory action="create" directory="#getdirectoryfrompath(this.logLocation)#" mode="770" />
		</cfif>
		<cfif len(arguments.logChanges) and not fileexists(this.loglocation)>
			<cffile action="write" file="#this.loglocation#" output="" mode="770" />
		</cfif>
		
		<cfset this.logChangeFlags = arguments.logChanges />
	</cffunction>
	
	<cffunction name="getLog" access="public" output="false" returntype="any" hint="Loads and returns the SQL log">
		<cfargument name="asArray" type="boolean" required="false" default="false" />
		
		<cfset var sqllog = "" />
		<cfset var st = structnew() />
		<cfset var aResult = arraynew(1) />
		<cfset var result = "" />
		
		<cffile action="read" file="#this.loglocation#" variable="sqllog" />
		
		<cfif not arguments.asArray>
			<cfreturn sqllog />
		</cfif>
		
		<cfloop condition="structisempty(st) or (arraylen(st.pos) and st.pos[1])">
			<cfset st = refind("(\r?\n){2}",sqllog,1,true) />
			<cfif arraylen(st.pos) and st.pos[1] and st.pos[1] eq 1>
				<cfset sqllog = mid(sqllog,2,len(sqllog)) />
			<cfelseif arraylen(st.pos) and st.pos[1] and st.pos[1]>
				<cfset result = left(sqllog,st.pos[1]-1) />
				<cfset sqllog = mid(sqllog,st.pos[1]+1,len(sqllog)) />
				
				<cfif len(trim(result))>
					<cfset arrayappend(aResult,trim(result)) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="clearLog" access="public" output="false" returntype="void" hint="Clears the SQL log">
		
		<cffile action="write" file="#this.loglocation#" output="" mode="770" />
	</cffunction>
	
		
	<!--- CUSTOM FUNCTION ACCESS --->
	<cffunction name="run" access="public" output="false" returntype="any" hint="Simplifies access to gateway specific functions provided by plugins or projects. Returns false if the mixin does not exist.">
		<cfargument name="name" type="string" required="true" hint="The name of the mixin function to run" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var result = false />
		
		<cfset arguments.logChangeFlags = this.logChangeFlags />
		<cfset arguments.logLocation = this.logLocation />
		
		<cfinvoke component="#getGateway(dsn=arguments.dsn)#" method="#arguments.name#" argumentCollection="#arguments#" returnvariable="result"></cfinvoke>
		
		<cfreturn result />
	</cffunction>
	
	
	<!--- SCHEMA AND MAINTENANCE --->
 	<cffunction name="isDeployed" access="public" returntype="boolean" output="false" hint="Returns True if the table is already deployed">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="dsn" type="string" required="false" default="" />

		<cfset var schema = getTableMetadata(arguments.typename) />

		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="read").isDeployed(schema=schema) />
	</cffunction>
	
	<cffunction name="deployType" access="public" returntype="struct" output="false">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="bDropTable" type="boolean" required="true" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,arguments.typename) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		<cfset var schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="write").deploySchema(schema=schema,bDropTable=arguments.bDropTable,logLocation=logLocation) />
	</cffunction>
	
	<cffunction name="dropType" access="public" returntype="struct" output="false">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var logLocation = iif(listfindnocase(this.logChangeFlags,arguments.typename) or this.logChangeFlags eq "*","this.logLocation",DE("")) />
		<cfset var schema = getTableMetadata(arguments.typename) />
		
		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="write").dropSchema(schema=schema,logLocation=logLocation) />
	</cffunction>
	
	<cffunction name="diffSchema" access="public" returntype="struct" output="false" hint="Compares type metadata to the actual database schema">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="dsn" type="string" required="false" default="" />

		<cfset var schema = getTableMetadata(arguments.typename) />

		<cfif not len(arguments.dsn) and structKeyExists(schema, "dsn")>
			<cfset arguments.dsn = schema.dsn />
		</cfif>

		<cfreturn getGateway(dsn=arguments.dsn, mode="read").diffSchema(schema=schema) />
	</cffunction>
 	
	
	<cffunction name="deployChanges" access="public" returntype="array" output="false" hint="Processes an array of changes and returns an array of results">
		<cfargument name="changes" type="array" required="true" hint="Array of changes in the form { action, schema, propertyname|indexname, bDropTable(deploySchema only) }. Other properties can be included but will be ignored." />
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset var aResults = arraynew(1) />
		<cfset var stResult = structnew() />
		<cfset var i = 0 />
		<cfset var gateway = "" />
		<cfset var logLocation = "" />
		
		<cfloop from="1" to="#arraylen(arguments.changes)#" index="i">
			<cfset arguments.changes[i].logLocation = iif(listfindnocase(this.logChangeFlags,listfirst(arguments.changes[i].schema.tablename,"_")) or this.logChangeFlags eq "*","this.logLocation",DE("")) />

			<cfif len(arguments.dsn)>
				<cfset gateway = getGateway(dsn=arguments.dsn, mode="write") />
			<cfelseif structKeyExists(arguments.changes[i].schema, "dsn")>
				<cfset gateway = getGateway(dsn=arguments.changes[i].schema.dsn, mode="write") />
			<cfelse>
				<cfset gateway = getGateway(dsn=arguments.dsn, mode="write") />
			</cfif>

			<cfinvoke component="#gateway#" method="#arguments.changes[i].action#" argumentcollection="#arguments.changes[i]#" returnvariable="stResult" />

			<cfif stResult.bSuccess and structkeyexists(arguments.changes[i],"success")>
				<cfset stResult.message = arguments.changes[i].success />
			</cfif>
			<cfif not stResult.bSuccess and structkeyexists(arguments.changes[i],"failure")>
				<cfset stResult.message = arguments.changes[i].failure />
			</cfif>
			<cfset arrayappend(aResults,stResult) />
		</cfloop>
		
		<cfreturn aResults />
	</cffunction>
	
	<cffunction name="createChange" access="public" returntype="struct" output="false" hint="Shortcut function for creating change structs">
		<cfargument name="action" type="string" required="true" hint="The name of the gateway function to run" />
		<cfargument name="schema" type="struct" required="true" hint="The relevant table schema" />
		<cfargument name="propertyname" type="string" required="false" hint="The property to update" />
		<cfargument name="indexname" type="string" required="false" hint="The index to update" />
		<cfargument name="bDropTable" type="boolean" required="false" hint="Used for table deployments" />
		
		<cfif listcontains("addColumn,repairColumn,dropColumn",arguments.action) and not structkeyexists(arguments,"propertyname")>
			<cfthrow message="propertyname is required for column changes" />
		</cfif>
		<cfif listcontains("addIndex,repairIndex,dropIndex",arguments.action) and not structkeyexists(arguments,"indexname")>
			<cfthrow message="indexname is required for index changes" />
		</cfif>
		<cfif listcontains("deploySchema",arguments.action) and not structkeyexists(arguments,"bDropTable")>
			<cfthrow message="bDropTable is required for deploySchema" />
		</cfif>
		
		<cfreturn duplicate(arguments) />
	</cffunction>
	
	<cffunction name="mergeChanges" access="public" returntype="array" output="false" hint="Merges two arrays of changes. Yes, this is just an array merge function.">
		<cfargument name="changesA" type="array" required="true" />
		<cfargument name="changesB" type="array" required="true" />
		
		<cfset var aResult = arraynew(1) />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arraylen(arguments.changesA)#" index="i">
			<cfset arrayappend(aResult,duplicate(arguments.changesA[i])) />
		</cfloop>
		<cfloop from="1" to="#arraylen(arguments.changesB)#" index="i">
			<cfset arrayappend(aResult,duplicate(arguments.changesB[i])) />
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getDefaultChanges" access="public" returntype="array" output="false" hint="Takes a table conflict struct and property/index name, and generates an array of default change structs for deployChanges.">
		<cfargument name="stDiff" type="struct" required="true" hint="Conflict struct for a table" />
		<cfargument name="propertyname" type="string" required="false" hint="Specific property" />
		<cfargument name="indexname" type="string" required="false" hint="Specific index" />
		
		<cfset var aChanges = arraynew(1) />
		<cfset var stChange = structnew() />
		<cfset var diff = structnew() />
		<cfset var tablename = "" />
		
		<cfif structkeyexists(arguments,"propertyname")>
			<cfset diff = arguments.stDiff.fields[arguments.propertyname] />
			<cfset tablename = arguments.stDiff.newMetadata.tablename />
			<cfswitch expression="#diff.resolution#">
				<cfcase value="+">
					<cfset arrayappend(aChanges,createChange(action="addColumn",schema=arguments.stDiff.newMetadata,propertyname=arguments.propertyname)) />
				</cfcase>
				<cfcase value="x">
					<cfset arrayappend(aChanges,createChange(action="repairColumn",schema=arguments.stDiff.newMetadata,propertyname=arguments.propertyname)) />
				</cfcase>
				<cfcase value="-">
					<!--- Don't drop columns by default. Code left in place as a reference. --->
					<!--- <cfset arrayappend(aChanges,createChange(action="dropColumn",schema=arguments.stDiff.newMetadata,propertyname=arguments.propertyname)) /> --->
				</cfcase>
			</cfswitch>
		<cfelseif structkeyexists(arguments,"indexname")>
			<cfset tablename = arguments.stDiff.newMetadata.tablename />
			<cfset diff = arguments.stDiff.indexes[arguments.indexname] />
			<cfswitch expression="#arguments.stDiff.indexes[arguments.indexname].resolution#">
				<cfcase value="+">
					<cfset arrayappend(aChanges,createChange(action="addIndex",schema=arguments.stDiff.newMetadata,indexname=arguments.indexname)) />
				</cfcase>
				<cfcase value="x">
					<cfset arrayappend(aChanges,createChange(action="repairIndex",schema=arguments.stDiff.newMetadata,indexname=arguments.indexname)) />
				</cfcase>
				<cfcase value="-">
					<!--- Don't drop indexes by default. Code left in place as a reference. --->
					<!--- <cfset arrayappend(aChanges,createChange(action="dropIndex",schema=arguments.stDiff.newMetadata,indexname=arguments.indexname)) /> --->
				</cfcase>
			</cfswitch>
		<cfelse><!--- Table diff --->
			<cfset diff = arguments.stDiff />
			<cfswitch expression="#arguments.stDiff.resolution#">
				<cfcase value="+">
					<cfset arrayappend(aChanges,createChange(action="deploySchema",schema=arguments.stDiff.newMetadata,bDropTable=false)) />
				</cfcase>
				<cfcase value="x">
					<cfloop collection="#arguments.stDiff.fields#" item="arguments.propertyname">
						<cfset aChanges = mergeChanges(aChanges,getDefaultChanges(stDiff=arguments.stDiff,propertyname=arguments.propertyname)) />
					</cfloop>
					<cfloop collection="#arguments.stDiff.indexes#" item="arguments.indexname">
						<cfset aChanges = mergeChanges(aChanges,getDefaultChanges(stDiff=arguments.stDiff,indexname=arguments.indexname)) />
					</cfloop>
				</cfcase>
				<cfcase value="-">
					<!--- Don't drop tables by default. Code left in place as a reference. --->
					<!--- <cfset arrayappend(aChanges,createChange(action="dropSchema",schema=arguments.stDiff.oldMetadata)) /> --->
				</cfcase>
			</cfswitch>
		</cfif>
		
		<cfreturn aChanges />
	</cffunction>
	
	<cffunction name="deployDefaultChanges" access="public" output="false" returntype="array" hint="Deploys all default schema changes and returns the results">
		<cfargument name="types" type="string" required="false" default="*" />
		
		<cfset var thistype = "" />
		<cfset var stDiff = structnew() />
		<cfset var thistable = "" />
		<cfset var aChanges = arraynew(1) />
		
		<cfif arguments.types eq "*">
			<cfset arguments.types = structkeylist(this.tablemetadata) />
		</cfif>
		
		<cfloop list="#arguments.types#" index="thistype">
			<cfset stDiff = diffSchema(typename=thistype,dsn=application.dsn) />
			<cfloop collection="#stDiff.tables#" item="thistable">
				<cfset aChanges = mergeChanges(aChanges,getDefaultChanges(stDiff=stDiff.tables[thistable])) />
			</cfloop>
		</cfloop>
		
		<cfreturn deployChanges(aChanges,application.dsn) />
	</cffunction>
	
</cfcomponent>
