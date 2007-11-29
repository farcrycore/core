<cfcomponent hint="Encapsulates a resource bundle" output="false">
	
	<!--- =========== PUBLIC =========== --->
	<cfset this.file = "" />
	<cfset this.fileexists = false />
	<cfset this.bundle = structnew() />
	
	<cffunction name="init" access="public" output="true" returntype="any" hint="Loads a file into the component">
		<cfargument name="file" type="string" required="true" />
		
		<cfset this.file = arguments.file />
		<cfset this.bundle = loadResource(this.file) />
		
		<cfreturn this />
	</cffunction>
	
	<!--- =========== PRIVATE =========== --->
	
	<!--- Java Objects --->
	<cfset variables.jPRB = CreateObject("java","java.util.PropertyResourceBundle") />
	<cfset variables.jFIS = CreateObject("java", "java.io.FileInputStream") />
	
	<cffunction name="loadResource" access="private" output="No" returntype="struct" hint="Reads and parses java resource bundle per locale">
		<cfargument name="file" required="Yes" type="string" />
		
		<cfscript>
			var isOk=false; // success flag
			var keys=""; // var to hold rb keys
			var resourceBundle=structNew(); // structure to hold resource bundle
			var thisKey="";
			var thisMSG="";
			
			if (fileExists(arguments.file)) { // final check, if this fails the file is not where it should be
				isOK=true;
				variables.jFIS.init(arguments.file);
				variables.jPRB.init(variables.jFIS);
				keys=variables.jPRB.getKeys();
				while (keys.hasMoreElements()) {
					thisKEY=keys.nextElement();
					thisMSG=variables.jPRB.handleGetObject(thisKey);
					resourceBundle["#thisKEY#"]=thisMSG;
				}
				variables.jFIS.close();
			}
		</cfscript>
		
		<cfset this.fileexists = isOK />
		
		<cfreturn resourceBundle>
	</cffunction>

</cfcomponent>