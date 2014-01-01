<cfcomponent extends="forms"
	displayname="Fix refObjects Table" 
	hint="Utility to repair refObjects look up table for typenames." 
	output="false" brefobjects="false" bsystem="false">

<!--- 
 // form properties 
--------------------------------------------------------------------------------->
	<cfproperty name="bProcessTypes" type="boolean" default="1" 
		ftseq="10" ftLabel="Repair Types/Rules?"
		fthint="Rebuild references for refObjects for components where bRefObjects is true.">

	<cfproperty name="bPurgeTypes" type="boolean" default="1" 
		ftseq="20" ftLabel="Purge Types/Rules?"
		fthint="Remove references from refObjects for components where bRefObjects is false.">

	<cfproperty name="bFixNav" type="boolean" default="1" 
		ftseq="30" ftLabel="Remove rogue dmNavigation sub-objects?"
		fthint="Remove content referenced in dmNavigation that is not present in refObjects (ie. deleted, orphaned)">


<!--- 
 // form functions 
--------------------------------------------------------------------------------->
	<cffunction name="getTypesToFix" hint="A query of types/rules to process.">
		<cfargument name="bRefObjects" type="boolean" required="true">

		<cfset var qResult=queryNew("typename, displayname, icon, bSystem, bRefObjects, class")>

		<cfloop list="#structkeylist(application.stcoapi)#" index="typename">
			<cfif application.fapi.getContentTypeMetadata(typename=typename, md="class") neq "form">
				<cfset queryAddRow(qResult)>
				<cfset querySetCell(qResult, "typename", typename)>
				<cfset querySetCell(qResult, "displayname", application.fapi.getContentTypeMetadata(typename=typename, md="displayname", default="(unknown)"))>
				<cfset querySetCell(qResult, "icon", application.fapi.getContentTypeMetadata(typename=typename, md="icon", default="fa-wrench"))>
				<cfset querySetCell(qResult, "bSystem", application.fapi.getContentTypeMetadata(typename=typename, md="bSystem", default="false"))>
				<cfset querySetCell(qResult, "bRefObjects", application.fapi.getContentTypeMetadata(typename=typename, md="bRefObjects", default="true"))>
				<cfset querySetCell(qResult, "class", application.fapi.getContentTypeMetadata(typename=typename, md="class"))>
			</cfif>
		</cfloop>

		<cfquery name="qResult" dbtype="query">
			SELECT * FROM qResult
			WHERE bRefObjects = #arguments.bRefObjects#
		</cfquery>
		
		<cfreturn qResult>
	</cffunction>

	<cffunction name="fixNav" hint="Fix rogue dmNavigation sub-objects.">
		<cfset var stResult = structNew()>
		<cfset var qGetOrphanedItems = "">
		<cfset var lOrphanedNavs = "">

		<cfquery name="qGetOrphanedItems" datasource="#application.dsn#">
			SELECT data
			FROM #application.dbowner#dmNavigation_aObjectIDs
			WHERE data NOT IN
				(SELECT objectid FROM #application.dbowner#refObjects) 
		</cfquery>

		<cfif qGetOrphanedItems.recordCount>			
			<cfset lOrphanedNavs = quotedValueList(qGetOrphanedItems.data) >
			<cfquery name="qDeleteNav" datasource="#application.dsn#">
				DELETE
				FROM #application.dbowner#dmNavigation_aObjectIDs
				WHERE data IN (#preserveSingleQuotes(lOrphanedNavs)#) 
			</cfquery>
		</cfif>

		<cfset stResult.message = "Removed #qGetOrphanedItems.recordCount# missing dmNavigation items.">
		<cfset stResult.recordCount = qGetOrphanedItems.recordCount>
		<cfreturn stResult>
	</cffunction>


	<cffunction name="fixReferences" hint="Rebuild refObjects table.">
		<cfset var qTypes = getTypesToFix(bRefObjects=true)>
		<cfset var stResult = structNew()>
		<cfset stResult.message = "Processed #qTypes.recordCount# types and rules tables.<br>">

		<!--- only process types where component metadata bRefObjects is true --->
		<cfloop query="qTypes">
			<cftry>
				<!--- check if there are any content records in the table --->
				<cfquery name="qCheck" datasource="#application.dsn#">
					SELECT count(ObjectID) as counter 
					FROM #application.dbowner##qTypes.typename#
				</cfquery>
			
				<cfif qCheck.counter GT 0>
					<!--- remove references from refObjects --->
					<cfquery name="qDelete" datasource="#application.dsn#">
						DELETE FROM #application.dbowner#refObjects
						WHERE typename = '#qTypes.typename#'
					</cfquery>
					<!--- Do bulk insert into refObjects --->
					<cfquery name="qInsert" datasource="#application.dsn#">
						INSERT INTO refObjects (objectid, typename)
							SELECT ObjectID as objectid, '#qTypes.typename#' as typename
							FROM #application.dbowner##qTypes.typename#
					</cfquery>
				</cfif>

				<cfcatch>
					<cfset stResult.message = stResult.message & "Error repairing #qtypes.typename#. The component may not have been deployed.<br>">
				</cfcatch>
			</cftry>
		</cfloop>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="purgeReferences" hint="Remove references from refObjects table.">
		<cfset var qTypes = getTypesToFix(bRefObjects=false)>
		<cfset var stResult = structNew()>
		<cfset stResult.message = "Purged #qTypes.recordCount# types and rules tables.<br>">

		<cfloop query="qTypes">
			<cftry>
				<!--- remove references from refObjects where bRefObjects is false --->
				<cfquery name="qPurge" datasource="#application.dsn#">
					DELETE FROM #application.dbowner#refObjects
					WHERE typename = '#qTypes.typename#'
				</cfquery>
				<cfcatch>
					<cfset stResult.message = stResult.message & "Error purging #qtypes.typename#. The component may not have been deployed.<br>">
				</cfcatch>
			</cftry>
		</cfloop>

		<cfreturn stResult>
	</cffunction>
		

</cfcomponent>