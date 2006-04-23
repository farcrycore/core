<!--- getFarcryTypes UDF --->
<cffunction name="getFarcryTypes" returntype="string">
    <cfargument name="packagePath" type="string" required="yes">
    <cfargument name="type" type="string" required="yes" default="types">

    <!--- define local variables --->
    <cfset var lReturn = "">
    <cfset var qDir = "">
    <cfset var filter = "">

    <!--- determine appropriate file filter --->
    <cfif arguments.type eq "rules">
        <cfset filter = "rule*.cfc">
    <cfelse>
        <cfset filter = "dm*.cfc">
    </cfif>
	
    <!--- grab names of rules from farcry rules directory --->
    <cfdirectory directory="#arguments.packagePath#/packages/#arguments.type#" name="qDir" filter="#filter#" sort="name">
	
    <!--- process list accordingly --->
    <cfscript>
    lReturn = valueList(qDir.name);
    lReturn = replaceNoCase(lReturn, ".cfc", "", "ALL");
    </cfscript>

    <cfif arguments.type eq "rules">
        <cfscript>
        lReturn = listPrepend(lReturn, "container");
        lReturn = listDeleteAt(lReturn, listFindNoCase(lReturn, "rules"));
        </cfscript>
    </cfif>

    <cfreturn lReturn>
</cffunction>

<!--- dump UDF --->
<cffunction name="dump">
    <cfargument name="var" type="any">
    <cfdump var="#arguments.var#">
</cffunction>

<!--- abort UDF --->
<cffunction name="abort">
    <cfabort>
</cffunction>

<!--- dot anim UDF --->
<cffunction name="dotAnim">
    <cfoutput>.....</td></cfoutput>
    <cfflush>
</cffunction>
