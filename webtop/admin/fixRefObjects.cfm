<cfsetting enablecfoutputonly="Yes" requesttimeout="2000">
	
<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab" result="bPermitted" />

<cfif bPermitted>
	<cfif isDefined("Form.submit")>
		<cfparam name="Form.bProcessTypes" default=true >
		<cfparam name="Form.bProcessRules" default=true >
		<cfparam name="Form.lExcludeItems" default=true ><!--- a list of types and rules to be excluded from the process --->

		<!--- loop through all types and rules --->
		<cfif Form.bProcessTypes>
			<cfoutput><h4>Started TYPES update</h4></cfoutput>
			<cfloop collection="#application.types#" item="key">
				<cfif NOT listFindNoCase(Form.lExcludeItems,key)>
					<cfoutput>Started #key#<br /></cfoutput><cfflush>
					<cftry>
						
						<cfset oType = createObject("component", application.types[key].typepath) >
						<cfset safeName = oType.getTableName() >
						
						<cfset bRefObjects = true /><!--- Assume true unless specifically instructed not too. --->
						
						<cfif isDefined("application.stCoapi.#safeName#.bRefObjects") AND NOT application.stCoapi[safeName].bRefObjects>
							<cfset bRefObjects = false />
						</cfif>
						
						<cfif bRefObjects>
							<!--- get objectId list for removal --->
							<cfquery name="qTypes" datasource="#application.dsn#">
								SELECT count(ObjectID) as counter 
								FROM #application.dbowner##safeName#
							</cfquery>
						
							<cfif qTypes.counter GT 0>
								<!--- remove references from refObjects --->
								<cfquery name="qDelRefs" datasource="#application.dsn#">
									DELETE FROM #application.dbowner#refObjects
									WHERE typename = '#safeName#'
								</cfquery>
								<!--- Do bulk insert into refObjects --->
								<cfquery name="qInsertRefs" datasource="#application.dsn#">
									INSERT INTO refObjects (objectid, typename)
										SELECT ObjectID as objectid, '#safeName#' as typename
										FROM #application.dbowner##safeName#
								</cfquery>
							</cfif>
							<cfoutput>Finished #key# - #qTypes.counter# records<br /><hr /></cfoutput><cfflush>
						<cfelse>
							<!--- remove references from refObjects --->
							<cfquery name="qDelRefs" datasource="#application.dsn#">
								DELETE FROM #application.dbowner#refObjects
								WHERE typename = '#safeName#'
							</cfquery>
							<cfoutput>IGNORED #key# - bRefObjects has been set to false. RefObjects cleared.<br /><hr /></cfoutput><cfflush>	
						</cfif>
						<cfcatch><cfoutput>Error fixing #key# - perhaps type has not been deployed #cfcatch.toString()#<br /><hr /></cfoutput></cfcatch>
					</cftry>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif Form.bProcessRules>
			<cfoutput><h4>Started RULES update</h4></cfoutput>
			<cfloop collection="#application.rules#" item="key">
				<cfif NOT listFindNoCase(Form.lExcludeItems,key)>
					<cfoutput>Started #key#<br /></cfoutput><cfflush>
					<cftry>
						<cfset oRule = createObject("component", application.rules[key].rulepath) >
						<cfset safeName = oRule.getTableName() >
						
						
						<cfset bRefObjects = true /><!--- Assume true unless specifically instructed not too. --->
						
						<cfif isDefined("application.stCoapi.#safeName#.bRefObjects") AND NOT application.stCoapi[safeName].bRefObjects>
							<cfset bRefObjects = false />
						</cfif>
						
						<cfif bRefObjects>
							<!--- get objectId list for removal --->
							<cfquery name="qRules" datasource="#application.dsn#">
								SELECT count(ObjectID) as counter 
								FROM #application.dbowner##safeName#
							</cfquery>
						
							<cfif qRules.counter GT 0>
								<!--- remove references from refObjects --->
								<cfquery name="qDelRefs" datasource="#application.dsn#">
									DELETE FROM #application.dbowner#refObjects
									WHERE typename = '#safeName#'
								</cfquery>
								<!--- Do bulk insert into refObjects --->
								<cfquery name="qInsertRefs" datasource="#application.dsn#">
									INSERT INTO refObjects (objectid, typename)
										SELECT ObjectID as objectid, '#safeName#' as typename
										FROM #application.dbowner##safeName#
								</cfquery>
							</cfif>
						
							<cfoutput>Finished #key# - #qRules.counter# records<br /><hr /></cfoutput><cfflush>
						
						<cfelse>
							<!--- remove references from refObjects --->
							<cfquery name="qDelRefs" datasource="#application.dsn#">
								DELETE FROM #application.dbowner#refObjects
								WHERE typename = '#safeName#'
							</cfquery>
							<cfoutput>IGNORED #key# - bRefObjects has been set to false. RefObjects cleared.<br /><hr /></cfoutput><cfflush>	
						</cfif>
						
						<cfcatch><cfoutput>Error fixing #key# - perhaps rule has not been deployed<br /><hr /></cfoutput></cfcatch>
					</cftry>
				</cfif>
			</cfloop>
		</cfif>
	
		<cfif Form.bFixNav>
			<cfoutput><h4>Started dmNavigation Fix</h4></cfoutput>
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
			<cfoutput>Removed #qGetOrphanedItems.recordCount# missing dmNav items</cfoutput>
		</cfif>
		
		<cfoutput><h4>Repair process has completed.</h4></cfoutput>
	
	<cfelse>
		<cfoutput>
		<script type="text/javascript">
			function show(el) {
				document.getElementById(el).style.display = "block";
			}
			function hide(el) {
				document.getElementById(el).style.display = "none";
			}
		</script>
		<h3>Repair refObjects Table</h3>
		<form action="" method="post">
		<h4>Types and Rules</h4>
		Process Types? : <input type="Radio" name="bProcessTypes" value="true" checked /> Yes <input type="Radio" name="bProcessTypes" value="false" /> No
		<br />
		Process Rules? : <input type="Radio" name="bProcessRules" value="true" checked /> Yes <input type="Radio" name="bProcessRules" value="false" /> No

		<h4>Missing dmNavigation sub-nodes:</h4>
		Remove rogue dmNavigation sub-objects? : <input type="Radio" name="bFixNav" value="true" checked /> Yes <input type="Radio" name="bFixNav" value="false" /> No

		<h4>Exclude the following types and rules: </h4>
		<p id="open" style="display:block;cursor:pointer;" onclick="show('types');show('close');hide('open');">&raquo;&raquo; click to expand list</p>
		<p id="close" style="display:none;cursor:pointer;" onclick="hide('types');show('open');hide('close');">&raquo;&raquo; click to hide list</p>

		<table id="types" style="display:none;">
			<tr>
				<th>Types</th>
				<th>Rules</th>
			</tr>
			<tr>
				<td style="vertical-align: top;">
					<cfloop collection="#application.types#" item="key">
					<input type="Checkbox" name="lExcludeItems" value="#key#" /> #key# <br />
					</cfloop>
				</td>
				<td style="vertical-align: top;">
					<cfloop collection="#application.rules#" item="key">
					<input type="Checkbox" name="lExcludeItems" value="#key#" /> #key# <br />
					</cfloop>
				</td>
			</tr>
		</table>
		<input type="Submit" name="submit" value="Repair References" />
		</form>
		</cfoutput>
	</cfif>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="No">