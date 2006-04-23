
<!--- getHierachies --->
<!--- <cfabort> --->
<!--- 
TODO

This page is a TOTAL disgrace - need to totally rework - was hacked together for interim solution

 --->

<script>
<cfoutput>
if (document.images) {
	catOpen = new Image(16,16);
	catOpen.src = '#application.url.farcry#/navajo/nimages/bno.gif';
	catClosed = new Image(16,16);
	catClosed.src = '#application.url.farcry#/navajo/nimages/bnc.gif';
}	
</cfoutput>
function toggleForm(selectedDiv)
	{
		el = document.getElementById(selectedDiv);
		toggleImageEl = document.getElementById( selectedDiv + "_toggle" );
		//alert(toggleImageEl);
		if (el.style.display == 'inline')			
		{
			el.style.display='none';
			toggleImageEl.src = catClosed.src;
		}	
		else	
		{
			el.style.display='inline';
			toggleImageEl.src = catOpen.src;
		}	
		//if (document.images) {document.images[id].src=eval(name+".src"); }	
	}
</script>	


<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierachies">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierarchies">
			
			<cfif qHierarchies.recordCount GT 0>
			<cfif NOT isDefined("form.displayHierarchy")>
				<cfoutput startrow="1" maxrows="1" query="qHierarchies" >
					<cfset form.hierarchyID = objectID>
					<cfset objectName = objectName>
				</cfoutput>
			<cfelse>
				<!--- <cfdump var="#qHierarchies#"> --->
				<cfoutput query="qHierarchies">
					<cfif qHierarchies.objectID is listGetAt(FORM.hierarchyID,1)>
						<cfset objectName = qHierarchies.ObjectName>
					</cfif>
				</cfoutput>	
			</cfif>
			<cfif stArgs.bIsForm>
			<form action="" method="post">
			</cfif>
			Existing Hierarchies:
			<select name="hierarchyID" class="formfield">
			<cfoutput query="qHierarchies">
				<option value="#objectID#" <cfif objectID IS form.hierarchyID>selected</cfif>>#objectName#</option>
			</cfoutput>
			</select> 
			
			<input type="submit" name="displayHierarchy" value="Display" class="normalbttnstyle" >
			<cfif stArgs.bIsForm>
			</form>
			</cfif>
			
			<cfelse>
				No Metadata Hierarchies
			</cfif>
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
</table>		

<cfif isDefined("form.hierarchyID")>

<cfinvoke  component="fourq.utils.tree.tree" method="getDescendants" returnvariable="qGetDescendants">
	<cfinvokeargument name="objectid" value="#listGetAt(form.hierarchyID,1)#"/>
</cfinvoke>

<cfparam name="style" default="">

<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lGetCategories">
	<cfinvokeargument name="objectID" value="#stArgs.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>

<cfif structKeyExists(stArgs,"lGetCategories") AND NOT len(lgetCategories)>
	<cfset lGetCategories = stArgs.lGetCategories>
</cfif>
<cfif NOT len(trim(lGetCategories)) AND isDefined("form.categoryID")>
	<cfset lGetCategories = form.categoryID>
</cfif>

<cfoutput>
<cfset basePos = 0>
<table border="0" cellspacing="0" cellpadding="0" align="center" style="width:300px">
	<tr>
		<td align="left">

<cfif stArgs.bIsForm>
<form action="" method="post" name="tree">
</cfif>
<table border="0" cellspacing="0" cellpadding="0">
<tr>
	<td>
		 <img src="#application.url.farcry#/navajo/nimages/bno.gif" width="16" height="16">
	</td>
	<td>
		<img src="#application.url.farcry#/navajo/nimages/hierarchy.gif">
	</td>
	<td>
	 #objectName#
	</td>
</tr>
</table>
</cfoutput>
<cfset startDivList = "">
<cfset endDivList = "">
<cfoutput query="qGetDescendants">
<cfset indent = basePos + ((nlevel-2)*16)>
<cfset numConnectors = (nlevel-2)>

<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetChildren">
	<cfinvokeargument name="objectid" value="#objectID#"/>
</cfinvoke>
<!--- This little cfif block establishes a list of objectIDs which will need to be encased in a div block --->
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
	<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetBChildren">
		<cfinvokeargument name="objectid" value="#bottomobjectID#"/>
	</cfinvoke>
	
	<cfif NOT qGetBChildren.recordCount>
	<cfif listLen(endDivList) is 0>
	  <cfset endDivList = bottomObjectID>
	<cfelse>
	  <cfset endDivList = endDivList & ", " & bottomObjectID>
	</cfif>
	</cfif>
<cfelse>
	<cfif listLen(endDivList) is 0>
	  <cfset endDivList = qGetDescendants.ObjectID>
	</cfif>
</cfif>	

<cfif listContains(startDivList,objectID)><!---  &lt;div&gt;  --->
	<div id="#objectID#" style="display:inline"> 
	<cfset ListDeleteAt(startDivList,listContains(startDivList,objectID))> 
</cfif>
<table  border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
	<img src="#application.url.farcry#/navajo/nimages/spacer.gif" width="16" height="16">
</td>
<cfloop from="1" to="#numConnectors#" index="i">
	<td>
		<!--- <cfif listContains(endDivList,objectID) AND i EQ numConnectors>
			<img src="#application.url.farcry#/navajo/nimages/node_bottom.gif" width="16" height="16">
		<cfelse>
			<img src="#application.url.farcry#/navajo/nimages/connector.gif" width="16" height="16">
		</cfif> --->
		<img src="#application.url.farcry#/navajo/nimages/spacer.gif" width="16" height="16">
	</td>
</cfloop> 
<!--- <td>
	<img src="#application.url.farcry#/navajo/nimages/spacer.gif" width="#indent#" height="16">
</td>
 ---><td>
<cfif qGetChildren.recordCount GT 0>
	<img onClick="toggleForm('#topobjectID#');" src="#application.url.farcry#/navajo/nimages/bno.gif" width="16" height="16" id="#topObjectID#_toggle">
<cfelse>	
	<!--- <cfif listContains(endDivList,objectID)>
		<img src="#application.url.farcry#/navajo/nimages/node_bottom.gif" width="16" height="16">
	<cfelse>	
		<img src="#application.url.farcry#/navajo/nimages/node.gif" width="16" height="16">
	</cfif>	 --->
	<img src="#application.url.farcry#/navajo/nimages/spacer.gif" width="16" height="16">
</cfif>
</td>
<td>
<cfif qGetChildren.recordCount GT 0>
	<img  src="#application.url.farcry#/navajo/nimages/category.gif"> 
<cfelse>	
	<img src="#application.url.farcry#/navajo/nimages/keyword.gif">
</cfif>	
</td>
<td>
	<cfif NOT qGetChildren.recordCount>
	<input value="#qGetDescendants.objectID#"  type="checkbox" name="categoryID" <cfif listContains(lGetCategories,objectID)>checked</cfif>> 
	</cfif> &nbsp;#qGetDescendants.objectName# 

</td>
</tr>
</table>
<cfif listContains(endDivList,qGetDescendants.objectID) >

	</div> <!--- &lt;/div&gt; ---> <!--- #endDivList# --->
	<!--- Need to check if this is the last child	 --->
	<cfquery datasource="#application.dsn#" name="qIsLast">
		SELECT MAX(nRight) as nRight FROM  nested_tree_objects 
		WHERE parentID = '#parentID#'
	</cfquery>
	<cfset listDeleteAt(endDivList,listContains(endDivList,qGetDescendants.objectID))>  
	<cfif qISLast.nRight EQ qGetDescendants.nRight >
		</div>  <!--- &lt;/div&gt; <!--- --->gape --->
	</cfif>

</cfif>


</cfoutput>
<cfoutput>
<table border="0" cellspacing="0" cellpadding="0">
<tr><td>&nbsp;</td></tr>
<tr>
	<td>

		<input type="hidden" name="hierarchyID" value="#listGetAt(form.hierarchyID,1)#">
		<input type="hidden" name="displayHierarchy" value="1">
		<cfif stArgs.bIsForm>
		<input type="submit" value="Apply Metadata" name="apply" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" >
		</cfif>
	</td>
</tr>
</table>
<cfif stArgs.bIsForm>
</form>
</cfif>
</td></tr></table>
</cfoutput>


</cfif>



