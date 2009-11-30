<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<!--- environment variables --->
<cfparam name="bFormSubmitted" default="false" type="boolean" />
<cfparam name="message_error" default="" type="string" />
<cfparam name="ObjectAction" default="" type="string" />

<cfset oType = CreateObject("component","#application.packagepath#.rules.container")>

<ft:processform action="Delete" >
	<cfif structKeyExists(form, "objectid")>
		<cfloop list="#objectid#" index="iObjectID">
			<cfset returnstruct = oType.delete(iObjectID)>
			<cfif NOT returnstruct.bSuccess>
				<cfset message_error = returnstruct.message>
			</cfif>
		</cfloop>	
	</cfif>
</ft:processForm>

<cfset qList = oType.getSharedContainers()>

<!---------------------------------------------------------- 
VIEW:
	- build shared container administration
----------------------------------------------------------->

<admin:header title="Reflected Containers" />

<ft:objectadmin 
	typename="container"
	title="Reflected Containers"
	qRecordSet="#qList#"
	bshowactionlist="false"
	lbuttons=""
	lcustomcolumns="Containers:cellActions"
	columnList=""
	sortableColumns="label"
	lFilterFields="label"
	sqlorderby="label" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />