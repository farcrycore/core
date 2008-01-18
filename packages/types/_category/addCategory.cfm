<!--- addCategory.cfm --->

<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<!--- unicode support --->

<cfset stProperties = structNew() />
<cfset stProperties.objectid = arguments.categoryID />
<cfset stProperties.categoryLabel = arguments.categoryLabel />
<cfset stResult = createObject("component", application.stcoapi["dmCategory"].packagePath).createData(stProperties="#stProperties#") />


<cfscript>
	qChildren = application.factory.oTree.getChildren(objectid=arguments.parentID,typename='dmCategory');
	position = qChildren.recordCount + 1;
	stReturn = application.factory.oTree.setChild(objectName=arguments.categoryLabel,typename='dmCategory',parentID=arguments.parentID,objectID=arguments.categoryID,pos=position);

	stStatus.message = '#arguments.categoryLabel# successfully added';
	stStatus.status = true;
</cfscript>
