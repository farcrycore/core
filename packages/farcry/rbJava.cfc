<cfcomponent displayname="javaRB" hint="reads and parses java resource bundle per locale" output="no">
<!--- 

author:		paul hastings <paul@sustainableGIS.com>
date:		08-december-2003
revisions:	
notes:		the purpose of this CFC is to extract text resources from a pure java resource bundle. these
			resource bundles should be produced by a tools such as IBM's rbManager and consist of:
				key=ANSI escaped string such as
				(english, no need for ANSI escaped chars)
				Cancel=Cancel
				Go=Ok
				(thai, ANSI escaped chars)
				Cancel=\u0E22\u0E01\u0E40\u0E25\u0E34\u0E01
				Go=\u0E44\u0E1B			

methods in this CFC:
	- getResourceBundle returns a structure containing all key/messages value pairs in a given resource 
	bundle file. required argument is rbFile containing resource bundle file which MUST be placed in 
	java class path. optional argument is rbLocale to indicate which locale's resource bundle to use, 
	defaults to us_EN (american english). PUBLIC
	- getRBKeys returns an array holding all keys in given resource bundle. required argument is rbFile 
	containing absolute path to resource bundle file. optional argument is rbLocale to indicate which 
	locale's resource bundle to use, defaults to us_EN (american english). PUBLIC
	- getRBString returns string containing the text for a given key in a given resource bundle. required
	arguments are rbFile containing absolute path to resource bundle file and rbKey a string holding the 
	required key. optional argument is rbLocale to indicate which locale's resource bundle to use, defaults
	to us_EN (american english). PUBLIC
 --->	

<!--- default init --->
<cfscript>
	rB=createObject("java","java.util.ResourceBundle");	
	locale=createObject("java","java.util.Locale");
</cfscript>
 
<cffunction access="public" name="getResourceBundle" output="No" returntype="struct"
	hint="reads and parses java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_AU"> <!--- farcry tweak --->
<cfargument name="markDebug" required="No" type="boolean" default="false">
	<cfscript>
	var isOk=true; // success flag
	var resourceBundle=structNew(); // structure to hold resource bundle
	var thisKey="";
	var thisMSG="";
	var thisLang=listFirst(arguments.rbLocale,"_");
	var thisRegion=listLast(arguments.rbLocale,"_");
	var thisLocale=locale.init(thisLang,thisRegion);
	var thisBundle="";
	var keys="";
	try {
		thisBundle=rB.getBundle(arguments.rbFile,thisLocale);
		keys=thisBundle.getKeys();
			while (keys.hasMoreElements()) {
				thisKEY=keys.nextElement();
				thisMSG=thisBundle.getObject(thisKey);
				if (arguments.markDebug)
					resourceBundle["#thisKEY#"]="****"&thisMSG;
				else
					resourceBundle["#thisKEY#"]=thisMSG;
			}
	}
	catch (e any){
		isOk=false;
	}	
	</cfscript>
	<cfif isOK>
		<cfreturn resourceBundle>
	<cfelse>
		<cfthrow message="Fatal error: resource bundle #arguments.rbFile# not found.">
	</cfif>
</cffunction> 

<cffunction access="public" name="getRBKeys" output="No" returntype="array"
	hint="returns array of keys in java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
<cfscript>
	var isOk=true; // success flag
	var keys=arrayNew(1); // var to hold rb keys
	var rbKeys="";
	var thisBundle="";
	var thisLang=listFirst(arguments.rbLocale,"_");
	var thisRegion=listLast(arguments.rbLocale,"_");
	var thisLocale=locale.init(thisLang,thisRegion);
	try {
		thisBundle=rB.getBundle(arguments.rbFile,thisLocale);
		rbKeys=thisBundle.getKeys();
		while (rbKeys.hasMoreElements()) {
			arrayAppend(keys,rbKeys.nextElement());
			}
	}
	catch (e any){
		isOk=false;
	}	
	</cfscript>
	<cfif isOK>
		<cfreturn keys>
	<cfelse>
		<cfthrow message="Fatal error: resource bundle #arguments.rbFile# not found.">
	</cfif>
</cffunction> 

<cffunction access="public" name="getRBString" output="No" returntype="string"
	hint="returns text for given key in given java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbKey" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
	<cfscript>
	var isOk=true; // success flag
	var rbString=""; // text message to return
	var thisBundle="";	
	var resourceBundle=structNew(); // structure to hold resource bundle
	var thisLang=listFirst(arguments.rbLocale,"_");
	var thisRegion=listLast(arguments.rbLocale,"_");
	var thisLocale=locale.init(thisLang,thisRegion);
	try {
		thisBundle=rB.getBundle(arguments.rbFile,thisLocale);
		rbString=thisBundle.getObject(arguments.rbKey);
		rbKeys=thisBundle.getKeys();
	}	
	catch (e any){
		isOk=false;
	}	
	</cfscript>
	<cfif NOT isOK>
		<cfthrow message="Fatal error: resource bundle #arguments.rbFile# not found.">
	<cfelse>
		<cfreturn rbString>
		<cfif len(trim(rbString))>
			<cfreturn rbString>
		<cfelse>
			<cfthrow message="Fatal error: resource bundle #arguments.rbFile# does not contain key #arguments.rbKEY#.">
		</cfif>
	</cfif>
</cffunction> 

<cffunction name="loadResourceBundle" access="public" output="no" returnType="void" hint="Loads a bundle">
	<cfargument name="rbFile" required="yes" type="string">
	<cfargument name="rbLocale" required="no" type="string" default="en_US">
	<cfset variables.resourceBundle = getResourceBundle(arguments.rbFile,arguments.rbLocale)>
</cffunction>

<cffunction name="dumpRB" access="public" output="no" returnType="struct" hint="Loads a bundle">
	<cfreturn variables.resourceBundle>
</cffunction>


<cffunction name="formatRBString" access="public" output="no" returnType="string" hint="performs messageFormat like operation on compound rb string">
	<cfargument name="rbString" required="yes" type="string">
	<cfargument name="substituteValues" required="yes">
	<cfset var i=0>
	<cfset tmpStr=arguments.rbString>
	<cfif isArray(arguments.substituteValues)>
		<cfloop index="i" from="1" to="#arrayLen(arguments.substituteValues)#">
			<cfset tmpStr=replace(tmpStr,"{#i#}",arguments.substituteValues[i],"ALL")>
		</cfloop>
	<cfelse>
		<cfset tmpStr=replace(tmpStr,"{1}",arguments.substituteValues,"ALL")>
	</cfif>
	<cfreturn tmpStr>
</cffunction>

<cffunction name="getResource" access="public" output="false" returnType="string" 
	hint="Returns bundle.X, if it exists, and optionally wraps it ** if debug mode.">
	<cfargument name="resource" type="string" required="true">
	<cfset var val = "">
	<cfif not isDefined("variables.resourceBundle")>
		<cfthrow message="Fatal error: resource bundle not loaded.">
	</cfif>
	<cfif not structKeyExists(variables.resourceBundle, arguments.resource)>
		<cfset val = "">
	<cfelse>
		<cfset val = variables.resourceBundle[arguments.resource]>
	</cfif>
	<cfif isDebugMode()>
		<cfset val = "*** #val# ***">
	</cfif>
	<cfreturn val>
</cffunction>

</cfcomponent>
