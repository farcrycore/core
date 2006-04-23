<!--- objectExists UDF --->
<cffunction name="objectExists" returntype="boolean">
    <cfargument name="dsn" type="string" required="yes">
    <cfargument name="objectID" type="UUID" required="yes">

    <!--- local variables --->
    <cfset var bExists = "true">

    <cfquery name="qObjects" datasource="#arguments.dsn#">
    SELECT objectID FROM refObjects
    WHERE objectID = '#arguments.objectID#'
    </cfquery>
    <cfif qObjects.recordCount eq 0>
        <cfset bExists = "false">
    <cfelse>
        <cfset bExists = "true">
    </cfif>

    <cfreturn bExists>
</cffunction>

<!--- getObject UDF --->
<cffunction name="getObject" returntype="struct">
    <cfargument name="dsn" type="string" required="yes">
    <cfargument name="objectID" type="UUID" required="yes">

    <!--- local variable definitions --->
    <cfset var extendeddata = "">
    <cfset var stData = structNew()>
    <cfset var stObj = structNew()>
    <cfset var teaser = "">
    <cfset var body = "">

    <cfquery name="qGetObject" datasource="#arguments.dsn#">
    SELECT a.*, b.label as typeName FROM objects a, types b
    WHERE a.typeID = b.typeID
    AND lower(a.objectID) = '#lCase(arguments.objectID)#'
    </cfquery>

    <!--- crack smoking Spectra workaround for extendeddata dodginess --->
    <cfif len(qGetObject.objectData) gt 13 AND right(qGetObject.objectData, 13) neq "</wddxpacket>">
        <cfquery name="qExtendedData" datasource="#arguments.dsn#">
        SELECT entityExtendedData FROM extendeddata
        WHERE lower(entityID) = '#lCase(arguments.objectID)#'
        ORDER BY segmentIndex ASC
        </cfquery>

        <cfloop query="qExtendedData">
            <cfset extendedData = extendedData & qExtendedData.entityExtendedData>
        </cfloop>
    </cfif>

    <!--- workaround for CFMX WDDX bug --->
    <cfif qGetObject.recordCount gt 0>
        <cfscript>
        stData = qGetObject.objectData & extendedData;

        // fix for MSWORD smart quotes
        stData = replaceNoCase(stData, "&##x92;", "'", "ALL");
        stData = replaceNoCase(stData, "&##x93;", """", "ALL");
        stData = replaceNoCase(stData, "&##x94;", """", "ALL");

        stData = deserialiseWDDX(stData);
        </cfscript>
    <cfelse>
        <cfreturn stObj>
    </cfif>

    <cfscript>
    stObj.objectID = qGetObject.objectID;
    stObj.label = qGetObject.label;
    stObj.datetimecreated = createODBCDateTime(qGetObject.datetimecreated);
    stObj.datetimelastupdated = createODBCDateTime(qGetObject.datetimelastupdated);
    stObj.createdBy = qGetObject.createdby;
    stObj.lastupdatedby = qGetObject.lastupdatedby;
    stObj.stObjectData = stData;
    </cfscript>

    <cfswitch expression="#qGetObject.typeName#">
    <cfcase value="daemon_news">
        <cfscript>
        // strip out font tags and other nasties
        //body = stripHTML(stData.body);
        //teaser = stripHTML(stData.teaser);

        stObj.aObjectIDs = arrayNew(1);
        if (arrayLen(stData.aImages) gt 0) stObj.aObjectIDs = stData.aImages;
        stObj.title = stData.title;
        stObj.body = stData.body;
        stObj.teaser = stData.teaser;
        stObj.status = stData.status;
        if (isDate(stData.publishDate)) stObj.publishDate = createODBCDateTime(stData.publishDate);
        if (isDate(stData.expiryDate)) stObj.expiryDate = createODBCDateTime(stData.expiryDate);
        stObj.stKeywords = stData.stKeywords;
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="daemon_corporatenews">
        <cfscript>
        // strip out font tags and other nasties
        //body = stripHTML(stData.body);
        //teaser = stripHTML(stData.teaser);

        stObj.aObjectIDs = arrayNew(1);
        if (arrayLen(stData.aImages) gt 0) stObj.aObjectIDs = stData.aImages;
        stObj.title = stData.title;
        stObj.body = stData.body;
        stObj.teaser = stData.teaser;
        stObj.status = stData.status;
        if (isDate(stData.publishDate)) stObj.publishDate = createODBCDateTime(stData.publishDate);
        if (isDate(stData.expiryDate)) stObj.expiryDate = createODBCDateTime(stData.expiryDate);
        stObj.stKeywords = stData.stKeywords;
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="daemon_file">
        <cfscript>
        stObj.title = stData.title;
        stObj.filename = stData.file;
        stObj.filePath = application.defaultFilePath;
        stObj.description = stData.title;
        stObj.status = 'approved';
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="daemon_image">
        <cfscript>
        stObj.title = stData.title;
        stObj.width = stData.width;
        stObj.height = stData.height;
        stObj.alt = stData.alt;
        stObj.imageFile = stData.filename;
        stObj.thumbnail = stData.thumbnailFilename;
        stObj.optimisedImage = stData.highResFilename;
        stObj.originalImagePath = application.defaultImagePath;
        if (stData.thumbnailFilename neq "") stObj.thumbnailImagePath = application.defaultImagePath;
        if (stData.highResFilename neq "") stObj.optimisedImagePath = application.defaultImagePath;
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="news_image">
        <cfscript>
        stObj.title = stData.title;
        stObj.width = stData.width;
        stObj.height = stData.height;
        stObj.alt = stData.alt;
        stObj.imageFile = stData.filename;
        stObj.thumbnail = stData.thumbnailFilename;
        stObj.optimisedImage = stData.highResFilename;
        stObj.originalImagePath = application.defaultImagePath;
        if (stData.thumbnailFilename neq "") stObj.thumbnailImagePath = application.defaultImagePath;
        if (stData.highResFilename neq "") stObj.optimisedImagePath = application.defaultImagePath;
        stObj.typeName = "daemon_image";
        </cfscript>
    </cfcase>
    <cfcase value="daemon_include">
        <cfscript>
        stObj.title = stData.title;
        stObj.include = stData.include;
        stObj.displayMethod = stData.displayMethod;
        stObj.teaser = stData.teaser;
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="daemon_html">
        <cfscript>
        // strip out font tags and other nasties
        body = stripHTML(stData.body);
        teaser = stripHTML(stData.teaser);

        stObj.aObjectIDs = arrayNew(1);
        if (arrayLen(stData.aFiles) gt 0) stObj.aObjectIDs = stData.aFiles;
        if (arrayLen(stData.aImages) gt 0) stObj.aObjectIDs = listToArray(listAppend(arrayToList(stObj.aObjectIDs), arrayToList(stData.aImages)));
        stObj.aRelatedIDs = arrayNew(1);
        if (arrayLen(stData.aRelatedID) gt 0) stObj.aRelatedIDs = stData.aRelatedID;
        stObj.aNextStepIDs = arrayNew(1);
        if (arrayLen(stData.aNextStepID) gt 0) stObj.aNextStepIDs = stData.aNextStepID;
        stObj.title = stData.title;
        stObj.body = body;
        stObj.teaser = teaser;
        stObj.teaserImage = stData.teaserImage;
        stObj.displayMethod = 'displayPage3Column';
        stObj.versionID = '';
        stObj.typeName = qGetObject.typeName;
        </cfscript>
    </cfcase>
    <cfcase value="daemon_navigation">
        <cfscript>
        if (arrayLen(stData.aObjects) gt 0) stObj.aObjectIDs = stData.aObjects;
        stObj.title = stData.title;
        stObj.status = stData.status;
        stObj.lNavIDAlias = lCase(stData.lNavIDAlias);
        stObj.externalLink = '';
        stObj.target = '';
        stObj.options = '';
        </cfscript>
    </cfcase>
    </cfswitch>

    <cfreturn stObj>
</cffunction>

<!--- add object UDF --->
<cfscript>
function addObject(sourceDSN, migrateDSN, theObj) {
    var stObj = arguments.theObj;
    var stTemp = structNew();

    if (stObj.typeName eq "daemon_html") {
        structDelete(stObj, "typeName");

        // create dmHTML object
        application.o_dmHTML.createData(dsn=arguments.migrateDSN, stProperties=stObj, bAudit=false);
        // add any object specific images and/or files
        if (not arrayIsEmpty(stObj.aObjectIDs)) {
            for (i = 1; i lte arrayLen(stObj.aObjectIDs); i = i + 1) {
                if (not objectExists(arguments.migrateDSN, stObj.aObjectIDs[i])) {
                    stTemp = getObject(dsn=arguments.sourceDSN, objectID=stObj.aObjectIDs[i]);
                    if (not structIsEmpty(stTemp)) addObject(arguments.sourceDSN, arguments.migrateDSN, stTemp);
                }
            }
        }
    } else if (stObj.typeName eq "daemon_include") {
        structDelete(stObj, "typeName");
        // create dmInclude object
        application.o_dmInclude.createData(dsn=arguments.migrateDSN, stProperties=stObj, bAudit=false);
    } else if (stObj.typeName eq "daemon_image") {
        structDelete(stObj, "typeName");
        // create dmImage object
        application.o_dmImage.createData(dsn=arguments.migrateDSN, stProperties=stObj, bAudit=false);
    } else if (stObj.typeName eq "daemon_file") {
        structDelete(stObj, "typeName");
        // create dmFile object
        application.o_dmFile.createData(dsn=arguments.migrateDSN, stProperties=stObj, bAudit=false);
    } else if (stObj.typeName eq "daemon_news" OR stObj.typeName eq "daemon_corporatenews") {
        structDelete(stObj, "typeName");
        // create dmNews object
        application.o_dmNews.createData(dsn=arguments.migrateDSN, stProperties=stObj, bAudit=false);
        // add any object specific images and/or files
        if (not arrayIsEmpty(stObj.aObjectIDs)) {
            for (i = 1; i lte arrayLen(stObj.aObjectIDs); i = i + 1) {
                if (not objectExists(arguments.migrateDSN, stObj.aObjectIDs[i])) {
                    stTemp = getObject(dsn=arguments.sourceDSN, objectID=stObj.aObjectIDs[i]);
                    if (not structIsEmpty(stTemp)) addObject(arguments.sourceDSN, arguments.migrateDSN, stTemp);
                }
            }
        }
    }
}
</cfscript>

<!--- add container and rules UDF --->
<cffunction name="addContainer">
    <cfargument name="dsn" type="string" required="yes">
    <cfargument name="containerLabel" type="string" required="yes">
    <cfargument name="aObjectIDs" type="array" required="yes">
    <cfargument name="displayMethod" type="string" required="yes">

    <!--- define local variables --->
    <cfset var stProps = structNew()>
    <cfset var stObj = structNew()>
    <cfset var containerID = "">
    <cfset var typeProps = arrayNew(1)>
    <cfset var objectWDDX = "">
    <cfset var oid = "">
    <cfset var c = 1>

    <cfimport taglib="/farcry/fourq/tags/" prefix="q4">

    <!--- create new container --->
    <cfscript>
    stProps.objectid = createUUID();
    stProps.label = arguments.containerLabel;

    containerID = stProps.objectID;
    </cfscript>

    <q4:contentobjectcreate dsn="#arguments.dsn#" typename="#application.packagepath#.rules.container" stProperties="#stProps#">
    <q4:contentobjectget dsn="#arguments.dsn#" typename="#application.packagepath#.rules.container" objectID="#containerID#" r_stObject="stObj">

    <!--- add handpicked rule to container --->
    <cfscript>
    typeProps = application.o_ruleHandPicked.getProperties();

    stProps = structNew();
    stProps.objectID = createUUID();
    </cfscript>

    <cfloop from="1" to="#arrayLen(typeProps)#" index="objID">
        <cfif structKeyExists(typeProps[objID], "default")><cfset "stProps.#typeProps[objID].name#" = "#typeProps[objID].default#"></cfif>
    </cfloop>
    <q4:contentobjectcreate dsn="#arguments.dsn#" typename="#application.packagepath#.rules.ruleHandpicked" stProperties="#stProps#">  
    <cfset rc = arrayAppend(stObj.aRules, stProps.objectID)>

    <!--- now update the container object --->
    <q4:contentobjectdata dsn="#arguments.dsn#" typename="#application.packagePath#.rules.container" stProperties="#stObj#" objectID="#stObj.objectID#">

    <!--- build objectWDDX packet string --->
    <cfscript>
    objectWDDX = "<wddxPacket version='1.0'><header/><data><array length='1'>";
    for (c = 1; c lte arrayLen(arguments.aObjectIDs); c = c + 1) objectWDDX = objectWDDX & "<struct><var name='OBJECTID'><string>#arguments.aObjectIDs[c]#</string></var><var name='TYPENAME'><string>farcry_core.packages.types.dmHTML</string></var><var name='METHOD'><string>#arguments.displayMethod#</string></var></struct>";
    objectWDDX = objectWDDX & "</array></data></wddxPacket>";
    </cfscript>

    <cfquery name="iRule" datasource="#arguments.dsn#">
    UPDATE ruleHandpicked SET objectWDDX = '#objectWDDX#' WHERE objectID = '#stProps.objectID#' AND intro is null
    </cfquery>

    <cfreturn true>
</cffunction>

<!--- deserialize WDDX UDF --->
<cffunction name="deserialiseWDDX">
    <cfargument name="wddx" type="string" required="yes">

    <!--- local variable definitions --->
    <cfset var stTemp = structNew()>

    <cfscript>
    application.o_stringReader.init(arguments.wddx);
    application.o_inputSource.init(application.o_stringReader);
    stTemp = application.o_wddxDeserializer.deserialize(application.o_inputSource);
    </cfscript>

    <cfreturn stTemp>
</cffunction>

<!--- strip HTML tags UDF --->
<cffunction name="stripHTML">
    <cfargument name="text" type="string" required="yes">
    <cfargument name="lStripTags" type="string" default="FONT" required="no">

    <!--- local variable definitions --->
    <cfset var theText = "">
    <cfset var stripperRE = "">

    <cfscript>
    theText = trim(REReplace(arguments.text, "(’|‘)", "'", "ALL"));
    stripperRE = "</?(" & listChangeDelims(arguments.lStripTags, "|") & ")[^>]*>";
    theText = REReplaceNoCase(theText , stripperRE, "", "ALL");
    </cfscript>

    <cfreturn theText>
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
