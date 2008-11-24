<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| DESCRIPTION ||
$Description: Image library administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<!--- set up page header --->
<admin:header title="Update application" />

<ft:processform action="Update Application" url="refresh">
	<ft:processformobjects typename="updateapp" />
</ft:processform>

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
	
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Update Application" />
	</ft:farcryButtonPanel>
</ft:form>

<admin:footer />