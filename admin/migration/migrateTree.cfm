<cfparam name="attributes.sourceDSN" default="">
<cfparam name="attributes.migrateDSN" default="">

<cfparam name="attributes.r_bSuccess" default="false">

<!--- ensure required attributes are provided --->
<cfif attributes.sourceDSN eq "" OR attributes.migrateDSN eq ""><cfexit></cfif>

<cfinclude template="/farcry/farcry_core/ui/migration/_functions.cfm">

<!--- <cftry> --->

<cfif not fileExists(expandPath(".") & "\stTree.wddx")>
    <!--- retrieve all old navigation objects --->
    <cfquery name="qNavNodes" datasource="#attributes.sourceDSN#">
    SELECT a.objectID FROM objects a, types b
    WHERE a.typeID = b.typeID
    AND lower(b.label) = 'daemon_navigation'
    AND a.label is not null
    </cfquery>

    <cfset stTree = structNew()>
    <cfloop query="qNavNodes">
    <cfscript>
    // get object
    stNode = getObject(dsn=attributes.sourceDSN, objectID=qNavNodes.objectID);
    depth = arrayLen(stNode.stObjectData.aNavParent) + 1;
    // force root node to approved status
    if (depth eq 1) {
        stNode.status = 'approved';
        stNode.lNavIDAlias = 'root';
    }

    aObjectIDs = arrayNew(1);
    if (arrayLen(stNode.stObjectData.aObjects) gt 0) {
        aObjects = stNode.stObjectData.aObjects;
        for (c = 1; c lte arrayLen(aObjects); c = c + 1) {
            stObj = getObject(dsn=attributes.sourceDSN, objectID=aObjects[c]);
            if (not structIsEmpty(stObj)) {
                // pickup status of parent nav node
                stObj.status = stNode.status;

                // sort containers out
                if (stObj.typename eq "daemon_html") {
                    if (arrayLen(stObj.aRelatedIDs) gt 0) addContainer(attributes.migrateDSN, stObj.objectID & '_relatedIDs', stObj.aRelatedIDs, 'displayTeaserRHColumn');
                    if (arrayLen(stObj.aNextStepIDs) gt 0) addContainer(attributes.migrateDSN, stObj.objectID & '_nextStepIDs', stObj.aNextStepIDs, 'displayTeaserRHColumn');
                    structDelete(stObj, "aRelatedIDs");
                    structDelete(stObj, "aNextStepIDs");
                }

                // add objectID to node's aObjectIDs array
                arrayAppend(aObjectIDs, aObjects[c]);
                addObject(attributes.sourceDSN, attributes.migrateDSN, stObj);
            }
        }
    }

    // create dmNavigation object
    stNode.aObjectIDs = aObjectIDs;
    application.o_dmNav.createData(dsn=attributes.migrateDSN, stProperties=stNode, bAudit=false);

    if (structKeyExists(stTree, depth) AND isArray(stTree[depth])) aChildren = stTree[depth];
    else aChildren = arrayNew(1);

    arrayAppend(aChildren, stNode.objectID);
    stTree[depth] = aChildren;
    </cfscript>
    </cfloop>

    <cfwddx action="CFML2WDDX" input="#stTree#" output="treeWDDX">
    <cffile action="WRITE" file="#expandPath(".")#\stTree.wddx" output="#treeWDDX#" addnewline="No">
<cfelse>
    <cffile action="READ" file="#expandPath(".")#\stTree.wddx" variable="treeWDDX">
    <cfwddx action="WDDX2CFML" input="#treeWDDX#" output="stTree">
</cfif>

<!--- sort fourQ tree out --->
<cfloop index="i" from="#arrayMin(structKeyArray(stTree))#" to="#arrayMax(structKeyArray(stTree))#">
    <cfset aNode = structFind(stTree, i)>
    <cfset lParentIDs = "">
    <cfloop index="oid" from="1" to="#arrayLen(aNode)#">
        <cfscript>
        stTemp = getObject(dsn=attributes.sourceDSN, objectID=aNode[oid]);
        if (i eq 1 AND isStruct(stTemp)) {
            // this is the Root node of the tree
            rootOID = stTemp.objectID;
            application.o_dmTree.setRootNode(dsn=attributes.migrateDSN, objectID=rootOID, objectName=stTemp.title, typeName='dmNavigation');
        } else if (isStruct(stTemp)) {
            // get node parent
            parentID = stTemp.stObjectData.aNavParent[arrayLen(stTemp.stObjectData.aNavParent)];

            if (listFind(lParentIDs, parentID) eq 0) {
                // get parent object
                stParent = getObject(dsn=attributes.sourceDSN, objectID=parentID);
                // create array of nav children for parent node
                aChildren = stParent.stObjectData.aNavChild;
                // loop through array creating nodes in correct order
                for (c = 1; c lte arrayLen(aChildren); c = c + 1) {
                    // get child object
                    stChild = getObject(dsn=attributes.sourceDSN, objectID=aChildren[c]);
                    // attach object to fourQ tree
                    application.o_dmTree.setYoungest(dsn=attributes.migrateDSN, parentID=parentID, objectID=stChild.objectID, objectName=stChild.title, typeName='dmNavigation');
                }
                // add parentID to list
                lParentIDs = listAppend(lParentIDs, parentID);
            }
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