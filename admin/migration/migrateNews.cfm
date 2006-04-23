<cfparam name="attributes.sourceDSN" default="">
<cfparam name="attributes.migrateDSN" default="">

<cfparam name="attributes.r_bSuccess" default="false">

<!--- ensure required attributes are provided --->
<cfif attributes.sourceDSN eq "" OR attributes.migrateDSN eq ""><cfexit></cfif>

<cfinclude template="/farcry/farcry_core/ui/migration/_functions.cfm">

<!--- <cftry> --->

<cffunction name="getCategoryID" returntype="string">
    <cfargument name="keyword" type="string" required="yes">
    <cfargument name="parentID" type="UUID" required="yes">

    <cfset var categoryID = "">

    <cfquery name="qCategory" datasource="#attributes.migrateDSN#">
    SELECT a.categoryID FROM categories a, nested_tree_objects b
    WHERE a.categoryID = b.objectID
    AND a.categorylabel = '#arguments.keyword#'
    AND b.typename = 'categories'
    AND b.parentID = '#arguments.parentID#'
    </cfquery>
    <cfif qCategory.recordCount gt 0><cfset categoryID = qCategory.categoryID></cfif>

    <cfreturn categoryID>
</cffunction>

<!--- this is corporate news stuff from Roche migration.. not needed anymore...
<!--- fetch objectID of CORPORATE keyword --->
<cfquery name="qCorporate" datasource="#attributes.migrateDSN#">
SELECT a.categoryID FROM categories a, nested_tree_objects b
WHERE a.categoryID = b.objectID
AND a.categorylabel = 'CORPORATE'
AND b.typename = 'categories'
AND b.parentID = (SELECT categoryID FROM categories WHERE lower(categoryLabel) = 'newstype')
</cfquery>

<cfif qCorporate.recordCount eq 0><cfexit></cfif>
--->

<!--- retrieve all news objects --->
<cfquery name="qNews" datasource="#attributes.sourceDSN#">
SELECT a.objectID FROM objects a, types b
WHERE a.typeID = b.typeID
AND lower(b.label) = 'daemon_news'
AND a.label is not null
</cfquery>

<cfloop query="qNews">
    <cfscript>
    //writeOutput("adding news object '" & qNews.objectID & "'<br>");
    stNews = getObject(dsn=attributes.sourceDSN, objectID=qNews.objectID);

    if (not structIsEmpty(stNews.stKeywords)) {
        structDelete(stNews.stKeywords, "LCATEGORIES");
        lCategoryIDs = "";
        for (keyword in stNews.stKeywords) {
            if (len(structFind(stNews.stKeywords, keyword)) eq 35) {
                catID = getCategoryID(keyword, structFind(stNews.stKeywords, keyword));
                if (catID neq "") lCategoryIDs = listAppend(lCategoryIDs, catID);
            }
        }
        //if (stNews.typeName eq "daemon_corporateNews") lCategoryIDs = listAppend(lCategoryIDs, qCorporate.categoryID);
        application.o_category.assignCategories(objectID=stNews.objectID, lCategoryIDs=lCategoryIDs, dsn=attributes.migrateDSN);
        structDelete(stNews, "stKeywords");
    }

    // create dmNews object
    addObject(attributes.sourceDSN, attributes.migrateDSN, stNews);
    </cfscript>
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