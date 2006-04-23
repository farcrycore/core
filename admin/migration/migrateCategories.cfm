<cfparam name="attributes.sourceDSN" default="">
<cfparam name="attributes.migrateDSN" default="">

<cfparam name="attributes.r_bSuccess" default="false">

<!--- ensure required attributes are provided --->
<cfif attributes.sourceDSN eq "" OR attributes.migrateDSN eq ""><cfexit></cfif>

<cfinclude template="/farcry/farcry_core/ui/migration/_functions.cfm">

<!--- <cftry> --->

<cfscript>
function addHierarchy(stHierarchy, hierarchyID) {
    // local variable definitions
    var stCategory = structNew();
    var stKeywords = structNew();
    var stTemp = structNew();

    structDelete(stHierarchy, "LABEL");
    for (categoryID in stHierarchy) {
        stCategory = getObject(dsn=attributes.sourceDSN, objectID=categoryID);
        application.o_category.addCategory(dsn=attributes.migrateDSN, categoryID=categoryID, categoryLabel=stCategory.label, parentID=hierarchyID);
        stKeywords = deserialiseWDDX(stCategory.stObjectData.categoryData);
        stKeywords = stKeywords.stKeywords;
        for (keyword in stKeywords) {
            if (structIsEmpty(structFind(stKeywords, keyword)) AND keyword neq "") {
                application.o_category.addCategory(dsn=attributes.migrateDSN, categoryID=createUUID(), categoryLabel=keyword, parentID=categoryID);
            }
        }
        stTemp = structFind(stHierarchy, categoryID);
        structDelete(stTemp, "LABEL");
        if (not structIsEmpty(stTemp)) addHierarchy(stTemp, categoryID);
    }
}

rootCategoryID = createUUID();
application.o_dmTree.setRootNode(dsn=attributes.migrateDSN, objectID=rootCategoryID, objectName='Root', typeName='categories');
</cfscript>

<cfquery name="qHierarchy" datasource="#attributes.sourceDSN#">
SELECT a.objectID, a.objectData, b.label as typeName
FROM objects a, types b
WHERE a.typeid = b.typeid
AND lower(b.label) = 'metadatahierarchy'
</cfquery>

<cfloop query="qHierarchy">
    <cfscript>
    stTemp = deserialiseWDDX(qHierarchy.objectData);
    stData = deserialiseWDDX(stTemp.hierarchyData);
    // add category
    application.o_category.addCategory(dsn=attributes.migrateDSN, categoryID=qHierarchy.objectID, categoryLabel=stData.label, parentID=rootCategoryID);
    stHierarchy = structFind(stData, "0");
    //  migrate hierarchy
    addHierarchy(stHierarchy, qHierarchy.objectID);
    </cfscript>
</cfloop>

<!--- old code from Roche migration
<cfquery name="qNewsType" datasource="#attributes.migrateDSN#">
SELECT categoryID FROM categories
WHERE lower(categoryLabel) = 'newstype'
</cfquery>
<cfscript>
application.o_category.addCategory(dsn=attributes.migrateDSN, categoryID=createUUID(), categoryLabel='CORPORATE', parentID=qNewsType.categoryID);
</cfscript>
--->

<!---
<cfcatch type="Any">
    <cfset "caller.#attributes.r_bSuccess#" = "false">
    <cfdump var="#CFCATCH#">
    <cfexit>
</cfcatch>
</cftry>
--->

<cfset "caller.#attributes.r_bSuccess#" = "true">