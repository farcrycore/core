<cfcomponent displayname="coapiManager" output="false">
	<cfscript>
		variables.stDB = structNew();//holds an image of the database
		variables.stCfc2Db = structNew();// holds mapping between farcry types and the database application server
		variables.initialised = false;
		variables.MAXEXTCLASS = "farcry.fourq.fourq"; // constant
		variables.oAltType = createObject("component","farcry.core.packages.farcry.alterType");
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="coapiManager">
		<cfif variables.initialised>
			<cfthrow type="Application" detail="coapiManager instace already intialised">
		<cfelse>
			<cfset variables.stCfc2Db = getCFC2DBMapping(application.dbType)>
			<cfset variables.initialised = true>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCFC2DBMapping" output="false" access="private" hint="I return the mapping between farcry and the supported databases" returntype="struct">
		<cfargument name="dbType" type="string">
		<cfset var stDBMapping=StructNew()>
		<cfscript>
		// TO DO: this should come from an external module ie Fourq
		// cfc property type to db data type translation
			switch(arguments.dbType){
				case "ora":
				{
					stDBMapping.boolean = "NUMBER|1";
					stDBMapping.integer = "integer";
					stDBMapping.date = "DATE";
					stDBMapping.numeric = "NUMBER";
					stDBMapping.string = "VARCHAR2|255";
					stDBMapping.nstring = "NVARCHAR2|255";
					stDBMapping.uuid = "VARCHAR2|50";
					stDBMapping.variablename = "VARCHAR2|64";
					stDBMapping.color = "VARCHAR2|20";
					stDBMapping.email = "VARCHAR2|255";
					stDBMapping.longchar = "NCLOB";
					stDBMapping.Array = "array";
					break;
				}
				case "mysql":
				{
					stDBMapping.boolean = "INT";
					stDBMapping.integer = "INT";
					stDBMapping.date = "DATETIME";
					stDBMapping.numeric = "NUMERIC|(10,2)";
					stDBMapping.string = "VARCHAR|255";
					stDBMapping.nstring = "VARCHAR|255";
					stDBMapping.uuid = "VARCHAR|50";
					stDBMapping.variablename = "VARCHAR|64";
					stDBMapping.color = "VARCHAR|20";
					stDBMapping.email = "VARCHAR|255";
					stDBMapping.longchar = "LONGTEXT";	
					stDBMapping.Array = "array";
					break;
				}
				case "postgresql":
				{
					stDBMapping.boolean = "INT";
					stDBMapping.integer = "INT";
					stDBMapping.date = "TIMESTAMP";
					stDBMapping.numeric = "NUMERIC";
					stDBMapping.string = "VARCHAR|255";
					stDBMapping.nstring = "VARCHAR|255";
					stDBMapping.uuid = "VARCHAR|50";
					stDBMapping.variablename = "VARCHAR|64";
					stDBMapping.color = "VARCHAR|20";
					stDBMapping.email = "VARCHAR|255";
					stDBMapping.longchar = "TEXT";
					stDBMapping.Array = "array";
					break;
				}
				case "mssql":
				{	
					stDBMapping.boolean = "INT";
					stDBMapping.integer = "INT";
					stDBMapping.date = "DATETIME";
					stDBMapping.numeric = "NUMERIC";
					stDBMapping.string = "VARCHAR|255";
					stDBMapping.nstring = "NVARCHAR|512";
					stDBMapping.uuid = "VARCHAR|50";
					stDBMapping.variablename = "VARCHAR|64";
					stDBMapping.color = "VARCHAR|20";
					stDBMapping.email = "VARCHAR|255";
					stDBMapping.longchar = "NTEXT";
					stDBMapping.Array = "array";
				}
				default:
					
				break;
			}	
		</cfscript>
		<cfreturn stDBMapping>
	</cffunction>
	
	<cffunction name="setFarcryScopeDbStruct"  output="false" access="private" returntype="void">
		<cfargument name="scope" required="true" type="string" hint="types or rules"  />
		<cfset variables.stDB[arguments.scope] = variables.oAltType.buildDBStructure(arguments.scope)>
	</cffunction>
	
	<cffunction name="updateStDBTable" output="false" hint="I update the image of the database for specified table, I should run after any table update" access="private" returntype="void">
		<cfargument name="scope" required="true" type="string">
		<cfargument name="cfcName" required="true" type="string">
		<cfset var stTmp = variables.oAltType.buildDBTableStructure(arguments.cfcName)>
		<cfset structInsert(variables.stDB[arguments.scope], arguments.cfcName, stTmp ,true)>
	</cffunction>
	
	<cffunction name="getFarcryScopeConflicts"  output="false" hint="returns all conflicts of all the farcry components for a specified FarcryScope" access="public" returntype="array">
		<cfargument name="scope" required="true" type="string" hint="Argument is types or rules" />
		<cfargument name="refresh" required="false" type="boolean" default="false" hint="refresh stDB structure image" />
		<cfset var arResult = arrayNew(1)>
		<cfset var typePath = "">
		<cfset var tmpObj = "">
		<cfscript>
			setFarcryScopeDbStruct(arguments.scope);
			// uncomment line below and delete line above to cache variable stCfc2Db on first request of the flex UI
			//if(not structKeyExists(variables.stDB,arguments.scope) OR arguments.refresh)setFarcryScopeDbStruct(arguments.scope);
		</cfscript>

		<cfloop collection="#application[arguments.scope]#" item="cfcName">	
			<cfset tmpObj = getCFCStatus(arguments.scope,cfcName)>
			<cfset arrayAppend(arResult, tmpObj)>	
		</cfloop>
			
		<cfreturn arResult>
	</cffunction>
		
	<cffunction name="getCFCStatus"  hint="returns conflicts of a specified farcry component from a given FarcryScope" access="public" output="false" returntype="struct">
		<cfargument name="scope" required="true" type="string">
		<cfargument name="cfcName" required="true" type="string">
		<cfargument name="bUpdateStDBTable" required="false" default="false" type="boolean">
		
		<cfset var tmpObj = structNew()>
		<cfset var oType = createObject("Component", application[arguments.scope][arguments.cfcName].PACKAGEPATH) />
		<cfset var depth = "">
		<cfset var propId = "">
		<cfset var stMetaData = structNew()>
		<cfset var extendsDepth = "">
		<cfset var propNotFoundMess = "">
		<cfset var checkedDbProps = "">
		<cfset var propKey = "">
		<cfset var DbTypeConflict = "">
		<cfset var struct2Parse = structNew()>
		<cfset var thisPropName = "">
		<cfset var structDBProp = structNew()>
		<cfset var thisProp = "">
		<cfset var tmpPropObj = "">
		<cfset var md = "" />
		<cfset var prop = "" />
		
		<cfset var o = createObject("Component", "#application.stcoapi[arguments.cfcName].packagePath#") />	
		<cfset var tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
		<cfset tableMetadata.parseMetadata(md=getMetadata(o), bForceRefresh=true) />
		<cfset md = tableMetadata.getTableDefinition() />
				
		<cfscript>
			if(not structKeyExists(variables.stDB,arguments.scope))setFarcryScopeDbStruct(arguments.scope);
			if(arguments.bUpdateStDBTable)updateStDBTable(arguments.scope,arguments.cfcName);
		</cfscript>


		<cfset tmpObj["typeName"] = arguments.cfcName>
		<cfset tmpObj["props"] = arrayNew(1)>
		
		<!--- get metadata class info --->
		<cfset stMetaData = getMetaData(oType) />
		
		<cfset extendsDepth = getExtendsDepth(stMetaData)>

		<!--- set temporary values for the cussent class type --->
		<cfif structKeyExists(variables.stDB[arguments.scope],arguments.cfcName)>
			<cfset tmpObj["dbStatus"] = "deployed">
			<cfset propNotFoundMess = "conflict">
		<cfelse>
			<cfset tmpObj["dbStatus"] = "undeployed">
			<cfset propNotFoundMess = "undeployed">
		</cfif>
		
		<!--- create a struct to flag checked properties/dbfields  --->
		<cfset checkedDbProps = structNew()>

		<cfloop collection="#md#" item="prop">
			<cfset thisPropName = prop>

			<cfif tmpObj["dbStatus"] eq "deployed" and structKeyExists(variables.stDB[arguments.scope][arguments.cfcName],thisPropName)>
				<cfset structDBProp = variables.stDB[arguments.scope][arguments.cfcName][thisPropName]>
			<cfelse>
				<cfset structDBProp = structNew()>
			</cfif>

			<cfif structKeyExists(md[prop], "type")>
				<cfset thisProp = setProperty(cfcName=arguments.cfcName,propName=thisPropName, dbStruct=structDBProp, metaStruct=md[prop], typeDeployed=tmpObj["dbStatus"])>
				<cfif thisProp.propDBType eq "n/a" or thisProp.cfc2Db eq "conflict">
					<cfset DbTypeConflict = propNotFoundMess>
				</cfif>
				<cfset checkedDbProps[trim(thisPropName)] = true>
				<cfset arrayAppend( tmpObj["props"],thisProp)>
			</cfif>
		</cfloop>
		<cfset tmpObj["dbStatus"] = DbTypeConflict>	
		
		<!--- There is a DB table matching the type --->
		<cfif structkeyExists(variables.stDB[arguments.scope],arguments.cfcName)>
			<!--- looping thru the fields of the database table  --->
			<cfloop collection="#variables.stDB[arguments.scope][arguments.cfcName]#" item="DBPropName">
				<!--- no match in the CFC property --->
				<cfif not structKeyExists(checkedDbProps,DBPropName)>
					<cfoutput><strong>#DBPropName#</strong></cfoutput>
					<cfset tmpPropObj = structNew()>
					<cfset tmpPropObj["propDBType"] = variables.stDB[arguments.scope][arguments.cfcName][DBPropName].type>
					<cfset tmpPropObj["propDBPrecision"] = variables.stDB[arguments.scope][arguments.cfcName][DBPropName].LENGTH>
					<cfset tmpPropObj["propName"] = DBPropName>
					<cfset tmpPropObj["propCfcType"] = "n/a">
					<cfset tmpPropObj["propAppType"] = "">
					<cfset tmpPropObj["propAppDefault"] = "">
					<cfset tmpPropObj["cfc2Db"] = "n/a">
					<cfset arrayAppend( tmpObj["props"],tmpPropObj)>
					<cfif not len(tmpObj["dbStatus"]) or  tmpObj["dbStatus"] eq "deployed">
						<cfset tmpObj["dbStatus"] = "conflict">
					</cfif>	
					
				</cfif>
			</cfloop>
			
		</cfif>
		<cfreturn tmpObj>
	</cffunction>
	
	<cffunction name="getCFCProps" hint="I return the properties of a type by reading introspecting only the cfc" output="false" access="public">
		<cfargument name="cfcName" required="true" type="string">

		<cfset var objModel = createObject("Component", application.stCoapi[arguments.cfcName].PACKAGEPATH) />
		<cfset var stMetaData = getMetaData(objModel) />
		<cfset var stProps = structNew() />
		<cfset var thisPropName = "" />
		<cfset var propKey = "stMetaData" />
		<cfset var extendsDepth = 0 />
		<cfset var struct2Parse = "" />
		<cfset var depth = "" />
		<cfset var propId = "" />
		<cfset var typeMatch = "" />
		<cfset var bPrecision = "" />

		<cfset extendsDepth = getExtendsDepth(stMetaData)>
		<!--- looping over type struct including parent classes structs--->
		<cfloop from="0" to="#extendsDepth#" index="depth">
			<cfif depth GT 0>
				<cfset propKey = listAppend(propKey,"Extends",".")>
			</cfif>					
			<cfset struct2Parse = evaluate(propKey)>
			<cfif struct2Parse.name eq variables.MAXEXTCLASS>
				<cfbreak><!--- reached maximum inheritence for class so exit loop and do not check DB properties for parents class --->
			</cfif>								
			<!--- looping over properties of class incl extended classes is properties struct exists--->
			<cfif structKeyExists(struct2Parse,"properties")>
				
				<cfloop from="1" to="#arrayLen(struct2Parse.properties)#" index="propId">
					
					<cfset thisPropName = trim(struct2Parse.properties[propId].name)>
					<cfset stProps[thisPropName] = structNew()>
		
					<cfset stProps[thisPropName] = structNew()>
					<cfset stProps[thisPropName].type = struct2Parse.properties[propId].TYPE>
					
					
					<cfif structKeyExists(struct2Parse.properties[propId],"REQUIRED")>
						<cfif listFindNoCase("false,no,0",struct2Parse.properties[propId].REQUIRED)>
							<cfset stProps[thisPropName].isNullable = true>
						<cfelse>
							<cfset stProps[thisPropName].isNullable = false>
						</cfif>
					<cfelse>
						<cfset stProps[thisPropName].isNullable = true>
					</cfif>
					
					<cfset stProps[thisPropName].defaultValue = "">
					<cfif structKeyExists(struct2Parse.properties[propId],"DEFAULT")>
						<cfset stProps[thisPropName].defaultValue = struct2Parse.properties[propId].DEFAULT>
					</cfif>
					
					<cfif not stProps[thisPropName].isNullable and listFindNoCase("boolean,integer,numeric",stProps[thisPropName].type)>
						<cfif structKeyExists(stProps[thisPropName],"defaultValue") and not isNumeric(stProps[thisPropName].defaultValue)>
							<cfset stProps[thisPropName].defaultValue = 0>
						</cfif>					
					</cfif>
				</cfloop>
				
			</cfif>
		</cfloop>
		<cfreturn stProps>
	</cffunction>
	
	<cffunction name="setProperty" hint="I define the conflicts for a given farcry component property" output="false" returntype="struct" access="private">
		<cfargument name="cfcName" required="true" type="string">
		<cfargument name="propName" required="true" type="string">
		<cfargument name="dbStruct" required="true" type="struct">
		<cfargument name="metaStruct" required="true" type="struct">
		<cfargument name="typeDeployed" required="true" type="string">
		
		<cfset var stObjResult = structNew()>
		<!--- set DB properties --->
		<cfset var typeMatch = "" />
		<cfset var bPrecision = "" />
		<cfset stObjResult["propName"] = arguments.propName>
		<cfset stObjResult["propCfcType"] = arguments.metaStruct.type>
		
		<cfif arguments.typeDeployed eq "deployed" and not structIsEmpty(arguments.dbStruct)>

			<!--- setting local variables to gain visual clarity in next conditional statement --->
			<cfset typeMatch = listFirst(variables.stCfc2Db[arguments.metaStruct.type],"|") eq arguments.dbStruct.type>
			<cfset bPrecision = listLen(variables.stCfc2Db[arguments.metaStruct.type],"|") eq 2>
		
			<cfif not typeMatch>
				<cfset stObjResult["cfc2Db"] = "conflict">				
			<cfelseif bPrecision and arguments.dbStruct.LENGTH neq listLast(variables.stCfc2Db[arguments.metaStruct.type],"|")>
				<cfset stObjResult["cfc2Db"] = "conflict"><!--- could be flagged as precision conflict --->
			<cfelse>
				<cfset stObjResult["cfc2Db"] = "ok">	
			</cfif>
			
			<cfset stObjResult["propDBType"] = listFirst(variables.stCfc2Db[arguments.metaStruct.type],"|") />
			<cfif bPrecision>
				<cfset stObjResult["propDBPrecision"] = listLast(variables.stCfc2Db[arguments.metaStruct.type],"|") />
			<cfelse>
				<cfset stObjResult["propDBPrecision"] = arguments.dbStruct.LENGTH>
			</cfif>
		<cfelse>	
			<cfset stObjResult["propDBType"] = "n/a">
			<cfset stObjResult["propDBPrecision"] = "n/a">
			<cfset stObjResult["cfc2Db"] = "undeployed">
		</cfif>
		<cftry>
		<cfif structKeyExists(application.types, arguments.cfcName) and structKeyExists(application.types[arguments.cfcName].stProps, propName) >
			<cfset stObjResult["propAppType"] = application.types[arguments.cfcName].stProps[propName].METADATA.type>
			<cfset stObjResult["propAppDefault"] = application.types[arguments.cfcName].stProps[propName].METADATA.DEFAULT>
		<cfelse>
			<cfset stObjResult["propAppType"] = "">
			<cfset stObjResult["propAppDefault"] = "">
		</cfif>
		<cfcatch>
			<cflog type="information" text="#cfcatch.Message# #cfcatch.ExtendedInfo# #cfcatch.Detail#">
			<cfdump var="#application.types[arguments.cfcName]#">
			<cfabort>
		</cfcatch>
		</cftry>
				
		<cfreturn stObjResult>	
	</cffunction>
	
	<cffunction name="getExtendsDepth" hint="I'm a recursive function to get the depth of inheritance" returntype="numeric" output="false" access="private">
		<cfargument name="object" type="struct" required="true">
		<cfargument name="thisDepth" type="numeric" required="false" default="0">
		
		<cfif structKeyExists(arguments.object,"Extends")>
			<cfset arguments.thisDepth = arguments.thisDepth + 1>
			<cfset arguments.thisDepth = getExtendsDepth(arguments.object.extends,arguments.thisDepth)>	
		</cfif>
		<cfreturn arguments.thisDepth>
	</cffunction>
	
	<cffunction name="refreshCFCMetaData" output="false" access="public" hint="refreshes type or rule in farcry application scope" returntype="boolean">
		<cfargument name="componentName" type="string" hint="name of a farcry type or rule to refresh in the application scope">
		<cfset var scope="types">
		
		<cfif structKeyExists(application.types,arguments.componentName)>
			<cfset scope = 'types'>
		<cfelseif structKeyExists(application.rules,arguments.componentName)>
			<cfset scope = 'rules'>
		<cfelse>
			<cfabort showerror="no component exists">
		</cfif>
		
		<cfset updateStDBTable(scope,componentName)>
		<cfset variables.oAltType.refreshCFCAppData(typename=arguments.componentName,scope=scope)>
		
		<cfreturn true>
	</cffunction>	
	
	<cffunction name="deployCFC" access="public"  output="false">
		<cfargument name="componentName" required="true">

		<cfset var o = createObject("component", application.stCoapi[arguments.componentName].packagepath) />
		<cfset var stResult = structNew()>
		<cftry>
			<cfscript>
				stResult["success"] = o.deployType(btestRun="false");
				stResult["message"] = "component  #arguments.componentName# deployed";
			</cfscript>
			<cfcatch>
				<cflog type="information" text="#cfcatch.Message# #cfcatch.ExtendedInfo# #cfcatch.Detail#">
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cfreturn stResult>
	</cffunction>

	<!--- ********************************
		  *   update properties methods 	 *
		  ******************************** --->
	<cffunction name="renameProperty" hint="update property type and default value" output="false" returntype="struct"  access="public">
		<cfargument name="componentName" type="string" hint="name of the component for the type or rule">
		<cfargument name="propertyName" type="string" hint="name of the component property">
		<cfargument name="renameto" type="string" hint="new name for the db column">
		<cfargument name="colType" type="string" hint="DB type content type or rule property">
		<cfargument name="colLength" type="numeric" hint="length for the db content type or rule property">
		<cfscript>
			var stResult = structNew();
			variables.oAltType.alterPropertyName(typename=arguments.componentName, srcColumn=arguments.propertyName, destColumn=arguments.renameto, colType=arguments.colType, colLength=arguments.colLength);
		 	stResult["success"] = true;
			stResult["message"] = "property #arguments.propertyName# renamed to #arguments.renameto#";
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="deployProperty" returntype="struct" output="false" access="public">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="cfcType" required="true" type="string">
		
		<cfset var stProps = structNew()>
		<cfset var stResult = structNew()>
		
		
		<cfscript>
			
			switch(arguments.cfcType){
				case "array":
				{
					variables.oAltType.deployArrayProperty(typename=arguments.componentName,property=arguments.propertyName);
					break;
				}
				 
				default:
			 	{
					stProps = getCFCProps(cfcName=arguments.componentName);			
					//is the property nullable
					isNullable = stProps[arguments.propertyName].ISNULLABLE;
					//if(stProps[arguments.propertyName].ISNULLABLE eq 'yes')isNullable = true;
					//do we have a default value
					defaultVal = stProps[arguments.propertyName].DEFAULTVALUE;
					dbType = setDBDeployValue(variables.stCfc2Db[arguments.cfcType]);
					
					if(not isNullable){
						variables.oAltType.addProperty(typename=arguments.componentName,srcColumn=arguments.propertyName,srcColumnType=dbType,bNull=isNullable,stDefault=defaultVal);
					}
					else variables.oAltType.addProperty(typename=arguments.componentName,srcColumn=arguments.propertyName,srcColumnType=dbType,bNull=isNullable);
					break;
				}
			}
			
			refreshCFCMetaData(componentName=arguments.componentName);
			
			stResult["success"] = true;
			stResult["message"] = "property #arguments.propertyName# for component #arguments.componentName# deployed";
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="setDBDeployValue" returntype="string" >
		<cfargument name="farcryType" required="true" type="string"><!--- a list with delimited by "|". 2nd element is optional for the precision --->
		<cfset var SLQTypeValue = listFirst(arguments.farcryType,"|")>

		<cfif listLen(arguments.farcryType,"|") eq 2>
			<cfset SLQTypeValue = SLQTypeValue & "(" & listLast(arguments.farcryType,"|") & ")">	
		</cfif>

		<cfreturn SLQTypeValue>
	</cffunction>
	
	<cffunction name="repairProperty"  output="false" access="public" returntype="struct">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="dbType" required="true" type="string">
		<cfscript>
			var stResult = structNew();
			
			refreshCFCMetaData(componentName=arguments.componentName);
			variables.oAltType.repairProperty(typename=arguments.componentName,srcColumn=arguments.propertyName,srcColumnType=arguments.dbType);
			
			stResult["success"] = true;
			stResult["message"] = "property #propertyName# for type #arguments.dbType# repaired";			
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="deleteProperty"  output="false" access="public" returntype="struct">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="cfcType" required="true" type="string">

		<cfscript>
		var stResult = structNew();	
			
		switch(arguments.cfcType){
			 case "array":
			 {
			 	variables.oAltType.dropArrayTable(typename=arguments.componentName,property=arguments.propertyName);
				break;
			 }
			 default:
			 {
				variables.oAltType.deleteProperty(typename=arguments.componentName,srcColumn=arguments.propertyName);				
				break;
			 }
		}
		stResult["message"] = "property #arguments.propertyName# deleted";
		stResult["success"] = true;

		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<!--- debug methods --->
	
	<cffunction name="getDBTableStruct" output="false" access="public" returntype="struct">
		<cfargument name="componentName" required="true" type="string">	
		<cfreturn variables.oAltType.buildDBTableStructure(arguments.componentName)>
	</cffunction>

	<cffunction name="stDB" returntype="Any">
		<cfreturn variables.stDB>
	</cffunction>
	
</cfcomponent>