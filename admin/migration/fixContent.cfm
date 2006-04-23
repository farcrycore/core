<cfparam name="attributes.datasource" default="">
<cfparam name="attributes.r_bSuccess" default="false">

<!--- ensure required attributes are provided --->
<cfif attributes.datasource eq ""><cfexit></cfif>

<!--- <cftry> --->

<cffunction name="updateContent" returntype="boolean">
    <cfargument name="objectID" type="UUID" required="yes">
    <cfargument name="typeName" type="string" required="yes">
    <cfargument name="propertyName" type="string" required="yes">
    <cfargument name="propertyValue" type="string" required="yes">

    <cfquery name="uContent" datasource="#attributes.datasource#">
    UPDATE #arguments.typeName#
    SET #arguments.propertyName# = '#replaceNoCase(arguments.propertyValue, "'", "''", "ALL")#'
    WHERE objectID = '#arguments.objectID#'
    </cfquery>

    <cfreturn "true">
</cffunction>

<cfset lTables = "dmHTML,dmNews">
<cfloop list="#lTables#" index="typeName">
    <cfquery name="qContent" datasource="#attributes.datasource#">SELECT objectID, teaser, body FROM #typeName#</cfquery>
    <cfloop query="qContent">
        <cfscript>
        teaser = qContent.teaser;
        body = qContent.body;

        // process teaser content
        if (findNoCase("display.cfm", teaser) gt 0 OR findNoCase("navajo/", teaser) gt 0) {
            newTeaser = replaceNoCase(teaser, "navajo/", "", "ALL");
            newTeaser = replaceNoCase(newTeaser, "display.cfm", "index.cfm", "ALL");
            updateContent(objectID=qContent.objectID, typeName=typeName, propertyName="teaser", propertyValue=newTeaser);
        }

        // process body content
        if (findNoCase("display.cfm", body) gt 0 OR findNoCase("navajo/", body) gt 0) {
            newBody = replaceNoCase(body, "navajo/", "", "ALL");
            newBody = replaceNoCase(newBody, "display.cfm", "index.cfm", "ALL");
            newBody = replaceNoCase(newBody, "daemon_images/", "images/", "ALL");
            updateContent(objectID=qContent.objectID, typeName=typeName, propertyName="body", propertyValue=newBody);
        }
        </cfscript>
    </cfloop>
</cfloop>

<!---
<cfcatch type="Any">
    <cfset "caller.#attributes.r_bSuccess#" = "false">
    <cfdump var="#CFCATCH#">
    <cfexit>
</cfcatch>
</cftry>
--->

<cfset "caller.#attributes.r_bSuccess#" = "true">