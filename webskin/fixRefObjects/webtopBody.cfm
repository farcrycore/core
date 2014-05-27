<cfsetting enablecfoutputonly="true" requesttimeout="2000">
<cfprocessingDirective pageencoding="utf-8">
<!--- @@displayname: Repair refObjects Table --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- enforce developer permissions on this utility --->
<sec:CheckPermission 
	permission="Developer" result="bPermitted"
	error="true"
	errorMessage="Your role does not have <strong>Developer</strong> permissions.">

<!--- 
 // process form 
--------------------------------------------------------------------------------->
<ft:processForm action="Repair Table">
	<ft:processFormObjects typename="fixRefObjects">
		<cfif stproperties.bProcessTypes>
			<cfset stResult = fixReferences()>
			<skin:bubble title="Update Type/Rule References" message="#stResult.message#" tags="success" />
		</cfif>
		<cfif stproperties.bPurgeMissingObjects>
			<cfset stResult = purgeMissingReferences()>
			<skin:bubble title="Purge Missing Object References" message="#stResult.message#" tags="success" />
		</cfif>
		<cfif stproperties.bPurgeTypes>
			<cfset stResult = purgeReferences()>
			<skin:bubble title="Purge Unused Type/Rule References" message="#stResult.message#" tags="success" />
		</cfif>
		<cfif stproperties.bFixNav>
			<cfset stResult = fixNav()>
			<skin:bubble title="Navigation Sub-Objects" message="#stResult.message#" tags="success" />
		</cfif>
		<!--- <cfdump var="#stproperties#" label="Stuff in the form" /> --->
	</ft:processFormObjects>
</ft:processForm>


<!--- 
 // view 
--------------------------------------------------------------------------------->
<cfoutput><h1>Repair refObjects Table</h1></cfoutput>
<ft:form>
	<ft:object typename="fixRefObjects" />
	<ft:buttonPanel>
		<ft:button value="Repair Table" textOnSubmit="Fixing..." priority="primary" />
	</ft:buttonPanel>
</ft:form>


<!--- 
 // refObjects Health Report 
--------------------------------------------------------------------------------->
<cfset qTypes = getTypesToFix()>

<cfoutput><h2>refObjects Usage<h2></cfoutput>

<cfoutput query="qTypes" group="class">
	<h3>#qtypes.class#</h3>
	<table class="table table-striped table-condensed">
		<thead>
			<tr>
				<th>&nbsp;</th>
				<th>Tablename</th>
				<th>Display Name</th>
				<th>System</th>
				<th>Use refObjects</th>
				<th>Ref Count</th>
				<th>Content Count</th>
			</tr>
		</thead>
		<tbody>
			<cfoutput>
				
				<cfif qtypes.refcount eq "ERROR" OR qTypes.rowCount eq "ERROR">
					<!--- error: likely component is not deployed --->
					<cfset rowclass = 'class="error"'>
				<cfelseif qtypes.refcount gt qtypes.rowCount>
					<!--- should not be more references than content items --->
					<cfset rowclass = 'class="error"'>
				<cfelseif NOT qtypes.brefObjects AND qTypes.refCount gt 1>
					<!--- if not using refObjects there should not be any references --->
					<cfset rowclass = 'class="warning"'>
				<cfelseif qtypes.bSystem AND qTypes.bRefObjects>
					<!--- system types should not need refObjects --->
					<cfset rowclass = 'class="warning"'>
				<cfelse>
					<cfset rowclass = "">
				</cfif>

				<tr #rowclass#>
					<td><i class="fa #qtypes.icon#"></i></td>
					<td>#qtypes.typename#</td>
					<td>#qtypes.displayname#</td>
					<td>#qtypes.bSystem#</td>
					<td>#qtypes.bRefObjects#</td>
					<td>#qtypes.refCount#</td>
					<td>#qtypes.rowCount#</td>
				</tr>
			</cfoutput>
		</tbody>
	</table>
</cfoutput>


</sec:checkpermission>
<cfsetting enablecfoutputonly="false">