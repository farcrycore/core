<cfsetting enablecfoutputonly="true">
<!--- @@displayname: System Information --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset qSections = getWebskins(typename="farCOAPI",prefix="webtopSystem") />

<cfset queryaddcolumn(qSections,"seq","integer",arraynew(1)) />

<cfloop query="qSections">
	<cfif isdefined("application.stCOAPI.farCOAPI.stWebskins.#qSections.methodname#.seq")>
		<cfset querysetcell(qSections,"seq",application.stCOAPI.farCOAPI.stWebskins[qSections.methodname].seq,qSections.currentrow) />
	<cfelse>
		<cfset querysetcell(qSections,"seq",100000,qSections.currentrow) />
	</cfif>
</cfloop>

<cfquery dbtype="query" name="qSections">
	select * from qSections order by seq
</cfquery>


<cfoutput>
	<h1>System Information</h2>
</cfoutput>

<ft:form>
	<cfloop query="qSections">
		<ft:fieldset legend="#qSections.displayname#">
			<skin:view stObject="#stObj#" webskin="#qSections.methodname#" />
		</ft:fieldset>
	</cfloop>
</ft:form>

<cfsetting enablecfoutputonly="false">