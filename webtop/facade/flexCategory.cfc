<cfcomponent name="flex" hint="i'm the remote object for flex category manager">

<cffunction name="getCategories" returntype="any" access="remote">
	<cfscript>
		var oCat = createObject("component","#application.packagepath#.farcry.category");
		var qCats =	oCat.GETALLCATEGORIES();
		var theXmlDoc = xmlParse("<root>" & genXmlDoc(1,qCats.nright[1]-1,qCats.objectID[1],qCats) & "</root>");
	</cfscript>
	<cfreturn theXmlDoc>
</cffunction>

<cffunction name="sort" returntype="boolean" access="remote">
	<cfargument name="categoryid" type="uuid" required="true">
	
		<cfset qChildren = application.factory.oTree.getDescendants(objectid=arguments.categoryid, bIncludeSelf=false, depth=1) />
	
		<cfquery dbtype="query" name="qSortedChildren">
			SELECT objectid,parentid,UPPER(objectname) as catname FROM qChildren
			ORDER BY catname desc
		</cfquery>
		
		<cfif qSortedChildren.recordCount>
			<cfloop query="qSortedChildren">
				<cfset stResult = application.factory.oTree.moveBranch(objectid=qSortedChildren.objectid, parentid=arguments.categoryID, pos=1) />
			</cfloop>
		</cfif>
	<cfreturn true>
		
</cffunction>

<cffunction name="addCategory" returntype="struct" access="remote">
	<cfargument name="parentID" required="true" type="string">
	<cfargument name="newCategoryName" required="true" type="string">
	<cfargument name="categoryAlias" required="false" type="string" default="">
	<cfset var stResult = structNew()>
	<cfset var catObjectID = application.fc.utils.createJavaUUID()>
	
 	<cfscript>
		stResult["objectId"] = catObjectID;
        oCat = createObject("component", "#application.packagepath#.farcry.category");
	    oCat.addCategory(dsn=application.dsn,parentID=arguments.parentID,categoryID=catObjectID,categoryLabel=arguments.newCategoryName);       
        if(len(arguments.categoryAlias) GT 0){oCat.setAlias(categoryid=catObjectID, alias=arguments.categoryAlias);}
        
        stResult["success"] = true;
    </cfscript>
	<!--- <cfcatch>
		<cfset stResult.success = false>
		<cfset stResult.objectID = "">
	</cfcatch>
	</cftry> --->
	<cfreturn stResult>
</cffunction>

<cffunction name="update" returntype="boolean" access="remote">
	<cfargument name="objectid" type="uuid" required="true">
	<cfargument name="objectname" type="string" required="true">
	<cfargument name="alias" type="string" required="false" default="">

	<cfquery name="q" datasource="#application.dsn#">
	UPDATE nested_tree_objects
	SET objectname = '#trim(arguments.objectname)#'
	WHERE objectID = '#arguments.objectid#'
	</cfquery>

	<cfquery name="q" datasource="#application.dsn#">
	UPDATE #application.dbowner#categories
	SET categoryLabel = '#arguments.objectname#',alias = '#arguments.alias#'
	WHERE categoryid = '#arguments.objectid#'
	</cfquery>	
	
	<cfset oCat = createObject("component", "#application.packagepath#.farcry.category")>
	<cfset application.catid = oCat.getCatAliases()>	
	<cfreturn true>
</cffunction>

<cffunction name="delCategory" returntype="boolean" access="remote">
	<cfargument name="categoryId" required="true" type="string">

	<cfscript>
        oCat = createObject("component", "#application.packagepath#.farcry.category");
	    oCat.deleteCategory(categoryID=arguments.categoryId,dsn=application.dsn);       
        stResult.success = true;
    </cfscript>
	<cfreturn true>
</cffunction>

<cffunction name="moveBranchTo" returntype="any" access="remote">
	<cfargument name="objectID" type="uuid" required="true">
	<cfargument name="parentid" type="uuid" required="true">
	<cfargument name="pos" type="numeric" required="true">
	<!--- 
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID" hint="The object that is at the head of the branch to be moved.">
	<cfargument name="parentid" required="yes" type="UUID" hint="The node to which it will be attached as a child. Note this function attaches the node as an only child or as the first child to the left of a group of siblings.">
	<cfargument name="pos" required="false" default="1" type="numeric" hint="The position in the tree">

	 --->
	<cfscript>
		var oTree = createObject("component","#application.packagepath#.farcry.tree");
		var stRes = oTree.moveBranch(dsn=application.dsn,objectid=arguments.objectID,parentid=arguments.parentid,pos=arguments.pos);//,pos=arguments.pos
	</cfscript>
	<cfreturn stRes>
</cffunction>

<cffunction name="genXmlDoc" returntype="string" access="private">
	<cfargument name="nodeQId" type="numeric" required="true">
	<cfargument name="maxRightNode" type="numeric" required="true">
	<cfargument name="categoryID" type="string" required="false" default="">
	<cfargument name="qCats" type="query" required="true">
	
	<cfset var XmlDoc = "">
	
	<cfset XmlDoc=XmlDoc & chr(13) & "<category label=""#replace(replace(arguments.qCats.OBJECTNAME[arguments.nodeQId],'&amp;','&','ALL'),'&','&amp;','ALL')#"" alias=""#replace(replace(arguments.qCats.alias[arguments.nodeQId],'&amp;','&','ALL'),'&','&amp;','ALL')#"" parentId=""#arguments.qCats.parentID[arguments.nodeQId]#"" objectId=""#qCats.objectId[arguments.nodeQId]#"">">
	<cfset arguments.nodeQId = arguments.nodeQId + 1>
	
	<cfloop from="#arguments.nodeQId#" to="#arguments.qCats.recordCount#" index="qID">
		<cfif arguments.qCats.nright[qID] lte arguments.maxRightNode><!--- not at the end of the branch --->
			<cfif arguments.qCats.parentID[qID] eq arguments.categoryID>
				<cfif arguments.qCats.nleft[qID]+1 eq arguments.qCats.nright[qID]><!---this is a node without children in the nested tree model --->	
					<cfset XmlDoc = XmlDoc & chr(13) & "<category label=""#replace(replace(arguments.qCats.OBJECTNAME[qID],'&amp;','&','ALL'),'&','&amp;','ALL')#"" alias=""#replace(replace(arguments.qCats.alias[qID],'&amp;','&','ALL'),'&','&amp;','ALL')#"" parentId=""#arguments.qCats.parentID[qID]#"" objectId=""#arguments.qCats.objectId[qID]#""/>">
				<cfelse>				
					<cfset XmlDoc = XmlDoc & genXmlDoc(nodeQId= qID,maxRightNode=arguments.qCats.nright[qID]-1, categoryID=arguments.qCats.objectID[qID],qCats=arguments.qCats)>
				</cfif>
			</cfif>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfset XmlDoc = XmlDoc & chr(13) & "</category>" >
	<cfreturn XmlDoc>
	
</cffunction>

</cfcomponent>
