<cfprocessingDirective pageencoding="utf-8">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<cfscript>
		
	bDelete = application.security.checkPermission(object=application.navid.rubbish,permission="delete");
	q4 = createObject("component","farcry.core.packages.fourq.fourq");
	if(bDelete)
	{
		oTree = createObject("component","#application.packagepath#.farcry.tree");
		oNav = createObject("component",application.types['dmNavigation'].typepath);
		
		//delete trash root children objects 
		stObj = oNav.getData(objectid=application.navid.rubbish);
		for(i = 1;i LTE arrayLen(stObj.aObjectIds);i=i+1)
		{
			typename = q4.findType(stObj.aObjectIds[i]);
			o = createObject("component",application.types[typename].typepath);
			o.delete(objectid=stObj.aObjectIds[i]);
		}
		//clear array objects from trash node - and update the object
		stObj.aObjectIds = arrayNew(1);
		structDelete(stObj,"datetimecreated");
		stObj.datetimelastupdated = createODBCDateTime(now());
		oNav.setData(stProperties=stObj);
		qDesc = oTree.getDescendants(objectid=application.navid.rubbish);		
		for(i = 1;i LTE qDesc.recordCount;i=i+1)
		{	writeoutput(qDesc.objectid[i]);
			oNav.delete(objectid=qDesc.objectid[i]);
		}
		
	}
	
</cfscript>


<nj:updateTree objectId="#application.navid.rubbish#">