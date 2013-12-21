<cfsetting enablecfoutputonly="true">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<cfset oContainer = application.fapi.getContentType(typename="container")>

<ft:processform action="Delete" >
	<cfif structKeyExists(form, "objectid")>
		<cfloop list="#objectid#" index="iObjectID">
			<cfset returnstruct = oContainer.delete(iObjectID)>
		</cfloop>	
	</cfif>
</ft:processForm>


<cfset qList = oContainer.getSharedContainers()>

<ft:objectadmin 
	typename="container"
	title="Reflected Containers"
	qRecordSet="#qList#"
	bshowactionlist="false"
	lbuttons="add,delete"
	lcustomcolumns="Containers:cellActions"
	columnList=""
	sortableColumns="label"
	lFilterFields="label"
	sqlorderby="label" />


<cfsetting enablecfoutputonly="false">