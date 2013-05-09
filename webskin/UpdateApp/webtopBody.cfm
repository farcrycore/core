<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:processform action="Update Application" url="refresh">
	<ft:processformobjects typename="updateapp" />
</ft:processform>

<cfoutput><h1>Reload Application</h1></cfoutput>

<ft:form>	
	<cfset qMetadata = application.forms['UpdateApp'].qMetadata />

	<cfquery dbtype="query" name="qFieldSets">
	SELECT ftFieldset
	FROM qMetadata
	WHERE lower(ftFieldset) <> '#lcase("UpdateApp")#'
	ORDER BY ftseq
	</cfquery>
	
	<cfset lFieldSets = "" />
	<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
		<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
	</cfoutput>
	
	<cfif listLen(lFieldSets)>
					
		<cfloop list="#lFieldSets#" index="iFieldset">	
	
			<cfquery dbtype="query" name="qFieldset">
				SELECT 		*
				FROM 		qMetadata
				WHERE 		lower(ftFieldset) = '#lcase(iFieldset)#'
				ORDER BY 	ftSeq
			</cfquery>
			
			<ft:object typename="updateapp" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable="false" IncludeFieldSet="true" Legend="#iFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
	
		</cfloop>
	</cfif>
	
	<ft:buttonPanel>
		<ft:button value="Update Application" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />