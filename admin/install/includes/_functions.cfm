<!--- getFarcryTypes UDF --->
<cffunction name="getFarcryTypes" returntype="string">
	
	<cfthrow detail="DEPRECATED">

</cffunction>



<cffunction name="getFarcryTypes2" returntype="string">
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
    <cfoutput>.....</li></ul></td></cfoutput>
    <cfflush>
</cffunction>

<!--- dot anim UDF bookends --->
<cffunction name="dotAnimDiv" access="public" output="true" returntype="string" hint="Return left and right <div>'s for each install item">
	<cfargument name="arg" required="false" default="" type="string" hint="Text to place in <div>'s" />
	<cfargument name="class" required="false" default="" type="string" hint="Class for <div>" />
	
    <cfoutput><div<cfif len(trim(arguments.class))> class="#arguments.class#"</cfif>>#arguments.arg#</div></cfoutput>
    <cfflush />
	
</cffunction>