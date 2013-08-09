<cfcomponent output="false" bAbstract="1">
	
	<cffunction name="getAncestors" hint="Get all the extended components as an array of isolated component metadata." returntype="array" access="public" output="false">
		<cfargument name="md" required="Yes" type="struct">
			<cfset var aAncestors = arrayNew(1)>
			<cfscript>	
				if (structKeyExists(md, 'extends'))
					aAncestors = getAncestors(md.extends);
				arrayAppend(aAncestors, md);
			</cfscript>
		<cfreturn aAncestors>
	</cffunction>

	<cffunction name="getMethods" access="public" hint="Get a structure of all methods, including extended, for this component" returntype="struct" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var methods = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curMethod = "">
		<cfset var i = '' />
		<cfset var j = '' />


		<cfscript>
		for ( i=1; i lte ArrayLen(aAncestors); i=i+1 ) {
			curAncestor = aAncestors[i] ;
			
			if ( StructKeyExists( curAncestor, 'functions' ) )
				for ( j=1; j lte ArrayLen( curAncestor.functions ); j=j+1 ) {
					curMethod = StructNew() ;
					curMethod.metadata = curAncestor.functions[j] ;
					curMethod.Origin = curAncestor.name ;
					if ( i eq ArrayLen(aAncestors)
					// don't exclude any method 1)from this
						or not StructKeyExists( curMethod.metadata, 'access' )
					// 2)that does not have 'access' attribute
						or curMethod.metadata.access neq 'private' ) {
					// 3)that does not have access='private'
						methods[curmethod.metadata.name] = curMethod ;
					}
				}
		
		}
		</cfscript>
		<cfreturn methods>
	</cffunction>
	
	<cffunction name="getPropsAsStruct" returntype="struct" hint="Get all extended properties and return as a flattened structure." access="public" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var stProperties = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curProperty = "">
		<cfset var i = "">
		<cfset var j = "">
		<cfset var prop = "">
		<cfset var success = "">
		
		<cfloop index="i" from="1" to="#ArrayLen(aAncestors)#">
			<cfset curAncestor = duplicate(aAncestors[i])>
			
			<cfif StructKeyExists(curAncestor,"properties")>
				<cfloop index="j" from="1" to="#ArrayLen(curAncestor.properties)#">
					<cfif not structKeyExists(stProperties, curAncestor.properties[j].name)>
						<cfset stProperties[curAncestor.properties[j].name] = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].metadata = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].origin = "" />
					</cfif>
					<cfset stProperties[curAncestor.properties[j].name].origin = curAncestor.name />
					<cfset success = structAppend(stProperties[curAncestor.properties[j].name].metadata, curAncestor.properties[j],true) />
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop collection="#stProperties#" item="prop">
			<!--- make sure all metadata has a default and required --->
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"required")>
				<cfset stProperties[prop].metadata.required = "no">
			</cfif>
			
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"default")>
				<cfset stProperties[prop].metadata.default = "">
			</cfif>
		</cfloop>

		<cfreturn stProperties>
	</cffunction>
	
	<cffunction name="initMetaData" access="public" hint="Extract all component metadata in a flat format for loading into a shared scope." output="true" returntype="struct">
		<cfargument name="stMetaData" type="struct" required="false" default="#structNew()#" hint="Structure to which this cfc's parameters are appended" />
	
		<cfset var stReturnMetadata = arguments.stMetaData />
		<cfset var md = getMetaData(this) />
		<cfset var key = "" />
		<cfset var mdExtend = structnew() />
		
		
		<!--- If we are updating a type that already exists then we need to update only the metadata that has changed. --->
		<cfparam name="stReturnMetadata.stProps" default="#structnew()#" />
		<cfset stReturnMetadata.stProps = application.factory.oUtils.structMerge(stReturnMetadata.stProps,getPropsAsStruct()) />
		
		<!--- This will get the components methods and any methods that are from super cfc's --->
		<cfset stReturnMetadata.stMethods = getMethods()>	
		
		<!--- add any extended component metadata --->
		<cfset mdExtend = md />
		<cfloop condition="not structisempty(mdExtend)">
			<cfloop collection="#mdExtend#" item="key">
				<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
					<cfparam name="stReturnMetadata.#key#" default="#mdExtend[key]#" />				
				</cfif>
			</cfloop>
			<cfif structkeyexists(mdExtend,"extends") and not findnocase(mdExtend.extends.name,"fourq")>
				<cfset mdExtend = mdExtend.extends />
			<cfelse>
				<cfset mdExtend = structnew() />
			</cfif>
		</cfloop>
		
		<!--- Param component metadata --->
		<cfparam name="stReturnMetadata.displayname" default="#listlast(stReturnMetadata.name,'.')#" />
		
		<!--- This sets up the array which will contain the name of all types this type extends --->
		<cfset stReturnMetadata.aExtends = application.coapi.coapiadmin.getExtendedTypeArray(packagePath=md.name)>
		
		<cfreturn stReturnMetadata />
	</cffunction> 
	
</cfcomponent>