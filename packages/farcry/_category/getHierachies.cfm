

<!--- Get root node --->
<cfinvoke component="#application.packagepath#.farcry.tree" method="getRootNode" typename="categories" returnvariable="qRoot">

<cfif not qRoot.recordCount>
	<cfinvoke component="#application.packagepath#.farcry.tree" method="setRootNode" typename="categories" objectID="#createUUID()#" objectName="root" >
	<cfinvoke component="#application.packagepath#.farcry.tree" method="getRootNode" typename="categories" returnvariable="qRoot">
</cfif>

<cfinvoke component="#application.packagepath#.farcry.tree" method="getChildren" objectID="#qRoot.objectID#" returnvariable="qHierarchies">







