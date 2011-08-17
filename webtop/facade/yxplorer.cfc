<cfcomponent displayname="remote object yxplorer" hint="tool to explore any cf object passed a la cfdump for remote access">
	<cfscript>

function TypeOf(x) {
   if(isSimpleValue(x)) return "string";
   if(isArray(x)) return "array";
   if(isStruct(x)) return "structure";
   if(isQuery(x)) return "query";
   if(isSimpleValue(x) and isWddx(x)) return "wddx";
   if(isBinary(x)) return "binary";
   if(isCustomFunction(x)) return "custom function";
   if(isDate(x)) return "date";
   if(isNumeric(x)) return "numeric";
   if(isBoolean(x)) return "boolean";
   if( listFindNoCase( structKeyList( GetFunctionList() ), "isXMLDoc" ) AND
isXMLDoc(x)) return "xml";
   // Trick the explorer into thinking references are structures and dereference them as needed
   if(isObject(x) and isInstanceOf(x,"java.lang.ref.Reference")) return "structure";
   
   return "unknown";  
}
</cfscript>


	<cffunction name="getScope" returntype="array" access="private" >
		<cfargument name="object" required="true" type="any">
		<cfset var myCollection = structNew()>
		<cfset var myResult = arrayNew(1)>
		<cfset var counter = 0>
		<!--- If the object is really a reference, return a reference scope --->
		<cfif isObject(object) and isInstanceOf(object,"java.lang.ref.Reference")>
			<cfreturn getReference(object)>
		</cfif>
		<cfloop collection="#object#" item="key">
			<cfset counter = counter + 1>
			<cfset myResult[counter] = structNew()>
			<cfset myResult[counter].Label = key>
			<cfset myResult[counter].Type = typeof(object[key])>
			
			<cfif IsSimpleValue(object[key])>
				<cfset myResult[counter].value = object[key]>
			<cfelse>
				<cfset myResult[counter].value = "complex">
			</cfif>
		</cfloop>
		
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="getSql" returntype="array" access="private" >
		<cfargument name="q" required="true" type="query">	
		<cfreturn toArray(q)>
	</cffunction>

	<cffunction name="getReference" returntype="array" access="private" >
		<cfargument name="ref" required="true" type="any">
		<cfset var myResult = arrayNew(1)>	
		<cfset var target = ref.get()>
		<cfset myResult[1] = StructNew()>
		<cfif IsDefined("target")>
			<cfset myResult[1].Label = "*">
			<cfset myResult[1].Type = typeof(target)>
			<cfif IsSimpleValue(target)>
				<cfset myResult[1].value = target>
			<cfelse>
				<cfset myResult[1].value = "complex">
			</cfif>
		<cfelse>
			<!--- Reference is empty --->
			<cfset myResult[1].Label = "Null">
			<cfset myResult[1].Type = "unknown">
			<cfset myResult[1].value = "Null">
		</cfif>
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="flashDGFormat" returntype="array" output="false" access="public">
		<cfargument name="myArray" required="true" type="array">
		<cfset var myAResult = arrayNew(1)>
		
			<cfloop from="1" to="#arraylen(myArray)#" index="id">
				<cfset myAResult[id] = structNew()>
				<cfset myAResult[id].Label = id>
				<cfset myAResult[id].Type =  typeof(myArray[id])>
				<cfif IsSimpleValue(myArray[id])>
					<cfset myAResult[id].value = myArray[id]>
				<cfelse>
					<cfset myAResult[id].value = "complex">
				</cfif>
			</cfloop>
			<cfreturn myAResult>

		
	</cffunction>
	
	<cffunction name="queryToArray" displayName="toArray" hint="Use for  creating arrays of like objects from queries in CF" returnType="Array">
		<cfargument name="inputQuery" type="query" required="yes" hint="Query results">

		<!--- declare vars --->
		<cfset var aReturnData = arrayNew(1)>
		<cfset var tmpObject = "">
		<cfset var columnName = "">
		<cfset var i = 0>

		<!--- loop over the query --->
		<cfloop from="1" to="#inputQuery.recordCount#" index="i">
			<cfset tmpObject = structNew()>
			<cfloop list="#inputQuery.columnList#" index="columnName">
				<cfset tmpObject[columnName] = inputQuery[columnName][i] >
			</cfloop>
			<cfset arrayAppend(aReturnData, tmpObject)>
		</cfloop>
		
		<cfreturn aReturnData>
	</cffunction>
	
	<cffunction name="formatScope" returntype="string">
		<cfargument name="inScope" default="" type="string">
		<cfset fString = "">
		<cfset isroot = true>
		<cfloop list="#inScope#" delimiters="." index="scope">
				<cfif not isroot>
					<cfif scope is "*">
						<!--- Java reference object: add .get() call to dereference --->
						<cfset fString = fString & ".get()">
					<cfelse>
						<cfset fString = fString &"['#scope#']">
					</cfif>
				<cfelse>
					<cfset fString = scope>
					<cfset isroot = false>
				</cfif>
		</cfloop>
			
		<cfreturn fString>	
	</cffunction>
	
	<cffunction name="getCFScope" returntype="struct" access="remote">
		<cfargument name="scope" default="application" type="string">
		<cfset var myRes = structNew()>
		
		<!--- <cfswitch expression="#scope#">
			<cfcase value="application">
				<cfset myRes.DATA = getScope(#application#)>
			</cfcase>
			<cfcase value="session">
				<cfset myRes.DATA = getScope(#session#)>
			</cfcase>
			<cfcase value="client">
				<cfset myRes.DATA = getScope(#client#)>
			</cfcase>
			<cfcase value="cookie">
				<cfset myRes.DATA = getScope(#cookie#)>
			</cfcase>
		</cfswitch> --->
		<cfset var toReturn = "">
		<cfset scope = formatScope(scope)>
		<cfset toReturn = evaluate(scope)>
		<cfswitch expression="#typeOf(toReturn)#">
			<cfcase value="query">
				<cfset myRes.DATA = queryToArray(toReturn)>
			</cfcase>
			<cfcase value="array">
				<cfset myRes.DATA = flashDGFormat(toReturn)>
			</cfcase>
			<cfcase value="custom function">
				<cfset myRes.DATA = getFunction(toReturn)>
			</cfcase>
			<cfdefaultcase>
				<cfset myRes.DATA = getScope(toReturn)>
			</cfdefaultcase>

		</cfswitch>

		<cfset myRes.CFType = typeOf(toReturn)>
		<cfreturn myRes>
	</cffunction>
	
	<cffunction name="getScopeArray" returntype="struct" access="remote" >
		<cfset var myRes = structNew()>
		<cfset var myArray = arrayNew(1)>
		<cfscript>
			var mycounter = 0;
			if(isdefined("application.stCoapi")){
				mycounter = mycounter + 1;
				myArray[mycounter] = structNew();
				myArray[mycounter].scope = "application.stCoapi";
			}
			
			if(isdefined("application.objectBroker")){
				mycounter = mycounter + 1;
				myArray[mycounter] = structNew();
				myArray[mycounter].scope = "application.objectBroker";
			}
	
			if(isdefined("server")){
				mycounter = mycounter + 1;
				myArray[mycounter] = structNew();
				myArray[mycounter].scope = "server";
			}

			if(isdefined("application")){
				mycounter = mycounter + 1;
				myArray[mycounter] = structNew();
				myArray[mycounter].scope = "application";
			}
			
			if(isdefined("session")){
				mycounter = mycounter + 1;
				myArray[mycounter] = structNew();
				myArray[mycounter].scope = "session";
			}
			
			myRes.data = myArray;
		</cfscript>
		<cfreturn myRes>
	</cffunction>
	
	<cffunction name="getFunction" returntype="struct" access="private">
		<cfargument name="functionInst" required="true">
		<cfset var stFcProps = structNew()>
		<cfscript>
			stFcProps.name = functionInst.metadata.name;
			if(structKeyExists(stFcProps,"returntype")){
				stFcProps.returntype = functionInst.metadata.returntype;
			}
			else stFcProps.returntype = "any";
			
			if(structKeyExists(stFcProps,"hint")){
				stFcProps.hint = functionInst.metadata.hint;
			}
			else stFcProps.hint = "";
			
			if(structKeyExists(stFcProps,"access")){
				stFcProps.access = functionInst.metadata.access;
			}
			else stFcProps.access = "public";
			
			if(structKeyExists(stFcProps,"output")){
				stFcProps.access = functionInst.metadata.access;
			}
			else stFcProps.output = "yes";
			
			stFcProps.arguments = ArrayNew(1);
		</cfscript>
		
		<cfloop from="1" to="#arrayLen(functionInst.metadata.parameters)#" index="pid">
			<cfscript>
				stFcProps.arguments[pid] = structCopy(functionInst.metadata.parameters[pid]);
				if(not structKeyExists(stFcProps.arguments[pid],"required")){
					stFcProps.arguments[pid].required = false;
				}
				if(not structKeyExists(stFcProps.arguments[pid],"type")){
					stFcProps.arguments[pid].type = "any";
				}
				if(not structKeyExists(stFcProps.arguments[pid],"def")){
					stFcProps.arguments[pid].def = "n/a";
				}
				if(not structKeyExists(stFcProps.arguments[pid],"hint")){
					stFcProps.arguments[pid].hint = "n/a";
				}
				
				
				//stFcProps.arguments[pid].name = functionInst.metadata.parameters[pid].name;
				//stFcProps.arguments[pid].required = functionInst.metadata.parameters[pid].required;
				//stFcProps.arguments[pid].type = functionInst.metadata.parameters[pid].type;
				//stFcProps.arguments[pid].def = IIF(structKeyExists(functionInst.metadata.parameters[pid],"default"),DE("functionInst.metadata.parameters[pid].default"),DE("no"));
			</cfscript>
		</cfloop>
		<cfreturn stFcProps>
	</cffunction>
	
</cfcomponent>