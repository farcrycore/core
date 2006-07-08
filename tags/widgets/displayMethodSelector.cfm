<cfsetting enablecfoutputonly="true">
<!--- import tag library --->
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<!--- quit tag if its not start mode --->
<cfif thistag.ExecutionMode eq "end"><cfexit /></cfif>

<cfparam name="attributes.typename" default="">
<cfparam name="attributes.prefix" default="">
<cfparam name="attributes.fieldLabel" default="#application.adminBundle[session.dmProfile.locale].displayMethodLabel#">
<cfparam name="caller.output" default="#StructNew()#">
<cfparam name="caller.stObj" default="#StructNew()#">
<cfparam name="attributes.fieldValue" default="">
<cfparam name="attributes.fieldName" default="DisplayMethod">

<cfset typename = attributes.typename>
<cfset fieldLabel = attributes.fieldLabel>
<cfset fieldValue = attributes.fieldValue>

<cfset output = caller.output>
<cfif fieldValue EQ "">
	<cfif StructKeyExists(caller.output,"displaymethod")>
		<cfset fieldValue = caller.output.displaymethod>
	<cfelseif StructKeyExists(caller.stObj,"displaymethod")>
		<cfset fieldValue = caller.stObj.displaymethod>
	<cfelse>
		<cfset fieldValue = "displayPageStandard">
	</cfif>
</cfif>
<cfif typename NEQ "">
	<!--- get the templates for this type --->
	<nj:listTemplates typename="#typename#" prefix="#attributes.prefix#" r_qMethods="qMethods"><cfoutput>
	<label for="#attributes.fieldName#"><b>#fieldLabel#</b>
		<!---No display methods for this content item type --->
		 <cfif qMethods.RecordCount EQ 0>
			No display methods for this content item type
			<input type="hidden" name="#attributes.fieldName#" value="">
		<cfelse>
			<select name="#attributes.fieldName#" size="1">
			<cfloop query="qMethods"><option value="#qMethods.methodname#"<cfif qMethods.methodname EQ fieldValue> selected="selected"</cfif>>#qMethods.displayname#</option>
			</cfloop>
			</select>
		</cfif>
		<br />
	</label>
</cfoutput></cfif>
<cfsetting enablecfoutputonly="false">