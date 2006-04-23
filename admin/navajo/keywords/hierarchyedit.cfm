<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/admin.css">
</cfoutput>

<!--- CREATE NEW HIERARCHY --->

<cfif isDefined("FORM.createHierarchy")>
	<!--- Get root node --->
	<cfinvoke  component="fourq.utils.tree.tree" method="getRootNode" returnvariable="qRootNode"typename="categories"/>
	<!--- checking to see if hierarchy actually exists or not --->
	<cfquery name="qCheckNodeExistance" datasource="#application.dsn#">
		SELECT * FROM nested_tree_objects
		WHERE objectname = '#form.hierarchy#' AND typename = 'categories' AND parentID = '#qRootNode.objectID#'
	</cfquery>
	<!--- Get root categories ID and set child underneath --->
	<cfif NOT qCheckNodeExistance.recordCount>
	 	<cfinvoke  component="#application.packagepath#.farcry.category" method="addCategory" returnvariable="stStatus">
			<cfinvokeargument name="categoryID" value="#createUUID()#"/>
			<cfinvokeargument name="categoryLabel" value="#form.hierarchy#"/>
			<cfinvokeargument name="parentID" value="#qRootNode.objectID#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
		<cfset message = "#form.hierarchy# hiearchy added successfully">
	<cfelse>	
		<cfset message = "#form.hierarchy# already exists">
	</cfif>	
</cfif>

<!--- DELETE Hierarchy --->

<cfif isDefined("FORM.deleteHierarchy")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="deleteCategory" returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#FORM.categoryID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
	<cfset message = stStatus.message>
</cfif>

<!--- Add new Category to hiearchy --->
<cfif isDefined("form.addNewCategory")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="addCategory" returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#createUUID()#"/>
		<cfinvokeargument name="categoryLabel" value="#form.categoryLabel#"/>
		<cfinvokeargument name="parentID" value="#form.parentID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
	<!--- <cfdump var="#stStatus#"> --->
	<cfset message = "New category added to parent : #form.parentID#">
</cfif>

<!--- DELETE A Category --->

<cfif isDefined("form.deleteCategory")>
	<cfif NOT form.categoryID IS form.parentID>
		<cfinvoke  component="#application.packagepath#.farcry.category" method="deleteCategory"returnvariable="stStatus">
			<cfinvokeargument name="categoryID" value="#form.parentID#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
		<!--- <cfdump var="#stStatus#"> --->
		<cfset message = "category deletion successful">
	<cfelse>
		<cfset message = "You attempted to delete the root hierarchy node - use delete hierarchy function instead">	
	</cfif>
</cfif>

<cfif isDefined("message")>
	<cfoutput>
		<h4 align="center" style="color:red">#message#</h4>
	</cfoutput>
</cfif>

<table border="0"  cellpadding="0">
	<tr>
		<td colspan="2" align="center">
			<h5>Hierarchies</h5>
		</td>
	</tr>
	<tr>
		<td align="center">
			<strong>Existing Hierachies</strong>
		</td>
		<td align="left">
			<strong>Actions:</strong>
		</td>
	</tr>
	<tr>
		<td align="center" valign="top">
			<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierarchies">
			<form action="" method="post">
			<cfif qHierarchies.recordCount GT 0>
				<cfif NOT isDefined("form.displayHierarchy")>
					<cfoutput startrow="1" maxrows="1" query="qHierarchies" >
						<cfset form.categoryID = objectID>
						<cfset objectName = objectName>
					</cfoutput>
				<cfelse>
				<!--- <cfdump var="#qHierarchies#"> --->
					<cfoutput query="qHierarchies">
						<cfif qHierarchies.objectID is FORM.categoryID>
							<cfset objectName = qHierarchies.ObjectName>
						</cfif>
					</cfoutput>	
				</cfif>
				<select name="categoryID" >
				<cfoutput query="qHierarchies">
					<option value="#objectID#" <cfif objectID IS form.categoryID>selected</cfif>>#objectName#</option>
				</cfoutput>
				</select> 
				<input type="submit" name="displayHierarchy" value="Display" class="normalbttnstyle">
			<cfelse>
				No Metadata Hierarchies
			</cfif>
		</td>
		<td>
			<cfif qHierarchies.recordCount GT 0>
			<input type="submit" name="deleteHierarchy" value="Delete Selected Hierarchy" class="normalbttnstyle"><br>
			</cfif>
			<input type="text" name="hierarchy">
			<input type="submit" name="createHierarchy" value="Create New Hierarchy" class="normalbttnstyle">
			
			</form>
		</td>
	</tr>
</table>

<cfif isDefined("form.categoryID") AND qHierarchies.recordCount GT 0>

<cfinvoke  component="fourq.utils.tree.tree" method="getDescendants" returnvariable="qGetDescendants">
	<cfinvokeargument name="objectid" value="#form.categoryID#"/>
</cfinvoke>

<style>
	.selected {background-color:yellow;}
</style>

<cfparam name="style" default="">
<cfoutput>
<cfset basePos = 0>
<cfif isDefined("form.parentID") >
	<cfif form.categoryID EQ form.parentID>
		<cfset style = "background-color:red;color:white;">
	<cfelseif isDefined("form.deleteCategory")>
		<cfset style = "background-color:red;color:white;">
		<cfset form.parentID = form.categoryID>
	</cfif>
<cfelse>
	<cfset form.parentID = form.categoryID>
	<cfset style = "background-color:red;color:white;">	
</cfif>
<table width="90%" border="1">
<tr><td valign="top">
<form action="" method="post" name="tree">

<table cellpadding="0" cellspacing="0">
<tr>
	<td>
		 <img src="#application.url.farcry#/navajo/nimages/branch_top_open.gif" width="16" height="16">
	</td>
	<td>
		<cfif style NEQ "">
		<img src="#application.url.farcry#/navajo/nimages/hierarchy_on.gif">
		<cfelse>
		<img src="#application.url.farcry#/navajo/nimages/hierarchy.gif">
		</cfif>
	</td>
<td>
<div id="#form.categoryID#" style="#style#" onClick="document.tree.parentID.value=this.id;tree.submit();">&nbsp;#objectName#</div>
</td>
</tr>
</table>
<input type="hidden" name="parentID" value="#form.parentID#">
</cfoutput>
<cfset startDivList = "">
<cfset endDivList = "">
<cfoutput query="qGetDescendants">
<cfif isDefined("form.parentID") >
	<cfif objectID EQ form.parentID>
		<cfset style = "background-color:red;color:white;">
	<cfelse>
		<cfset style = "">	
	</cfif>
</cfif>

<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetChildren">
	<cfinvokeargument name="objectid" value="#objectID#"/>
</cfinvoke>

<cfif qGetChildren.recordCount GT 0>
	<cfloop query="qGetChildren">
		<cfif qGetChildren.currentRow EQ 1>
			<cfset topObjectID =  qGetChildren.objectID>
		</cfif>
		<cfif qGetChildren.currentRow EQ qGetChildren.recordCount>
			<cfset bottomObjectID = qGetChildren.objectID>
		</cfif>
	</cfloop>
	
	<!--- Yes - i know listAppend should do exactly what is going on below - but it aint ok! :) --->
	<cfif listLen(startDivList) is 0>
	  <cfset startDivList = topObjectID>
	<cfelse>
	  <cfset startDivList = startDivList & ", " & topObjectID>
	</cfif>

	<cfif listLen(endDivList) is 0>
	  <cfset endDivList = bottomObjectID>
	<cfelse>
	  <cfset endDivList = endDivList & ", " & bottomObjectID>
	</cfif>
<cfelse>
	<cfif listLen(endDivList) is 0>
	  <cfset endDivList = qGetDescendants.ObjectID>
	</cfif>
</cfif>		

<cfset indent = basePos + ((nlevel-2)*16)>
<cfset numConnectors = (nlevel-2)>
<table cellpadding="0" cellspacing="0">
<tr>
<td>
	<img src="#application.url.farcry#/navajo/nimages/spacer.gif" width="16" height="16">
</td>
<td>
	<cfloop from="1" to="#numConnectors#" index="i">
	<td>
		<cfif listContains(endDivList,objectID) AND i EQ numConnectors>
			<img src="#application.url.farcry#/navajo/nimages/node_bottom.gif" width="16" height="16">
		<cfelse>
			<img src="#application.url.farcry#/navajo/nimages/connector.gif" width="16" height="16">
		</cfif>
	</td>
	</cfloop> 
</td>
<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetChildren">
	<cfinvokeargument name="objectid" value="#objectID#"/>
</cfinvoke>
<td>
<cfif qGetChildren.recordCount GT 0>
	<img src="#application.url.farcry#/navajo/nimages/branch_open.gif" width="16" height="16">
<cfelse>	
	<cfif listContains(endDivList,objectID)>
		<img src="#application.url.farcry#/navajo/nimages/node_bottom.gif" width="16" height="16">
	<cfelse>	
		<img src="#application.url.farcry#/navajo/nimages/node.gif" width="16" height="16">
	</cfif>
</cfif>
</td>
<td>
<cfif qGetChildren.recordCount GT 0>
	<cfif style neq "">
		<img src="#application.url.farcry#/navajo/nimages/category_on.gif"> 
	<cfelse>
		<img src="#application.url.farcry#/navajo/nimages/category.gif"> 
	</cfif>
<cfelse>	
	<img src="#application.url.farcry#/navajo/nimages/keyword.gif">
</cfif>	
</td>
<td>
<div id="#objectID#" style="#style#" onClick="document.tree.parentID.value=this.id;tree.submit();">&nbsp;#qGetDescendants.objectName#</div>
</td>
</tr>
</table>
</cfoutput>
<cfoutput>
</td>
<td valign="top">
<table>
<input type="hidden" name="categoryID" value="#form.categoryID#">
<input name="displayHierarchy" value="1" type="hidden">

<tr>
<td nowrap>
<strong>Actions :</strong><br>
<input type="submit" name="deleteCategory" value="Delete Selected Category" class="normalbttnstyle"><br>
<strong>OR</strong><br>
<input type="text" name="categoryLabel">
<input type="submit" name="addNewCategory" value="Add New Category To Selected Parent" class="normalbttnstyle">
</td>
</tr>
</form>
</table>

</td></tr></table>
</cfoutput>
</cfif>