<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: COAPI Conflict --->
<!--- @@description: Details about conflicts for a specific content type --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="url.typepath" />
<cfset typeid = listlast(url.typepath,".") />

<cfset stDiff = application.fc.lib.db.diffSchema(typename=url.typepath,dsn=application.dsn) />


<skin:loadJS id="fc-jquery" />
<skin:htmlHead><cfoutput>
	<style type="text/css">
		div.ctrlHolder label.label.field, div.ctrlHolder label.label.index { font-weight:normal; }
		label.table { font-weight:bold; }
		strong { font-weight:bold; }
		
		.undeployed { color:##23d729; }
		.deleted { color:##ff0000; }
		.altered { color:##d78b23; }
		input[type=radio] {
			margin-top: 2px !important;
		}
	</style>
</cfoutput></skin:htmlHead>

<ft:form target="_parent" action="#application.url.webtop#/index.cfm?id=admin.coapi.coapitools.coapioverview">
	<cfoutput>
		<input type="hidden" name="typename" value="#url.typepath#" />
		<div class="">
			<fieldset class="fieldset">
				<h2 class="legend">Conflicts</h2>
	</cfoutput>
	
	<cfloop collection="#stDiff.tables#" item="thistable">
		<cfswitch expression="#stDiff.tables[thistable].resolution#">
			<cfcase value="x">
				<ft:field label="&nbsp;<strong>#thistable#</strong>" bMultiField="true" style="font-weight:bold; border-bottom:2px solid ##ddd;">
					<cfoutput>
						<label for="field_#thistable#_ignore" class="radio inline">
							<input type="radio" name="field_#thistable#" id="field_#thistable#_ignore" value="#thistable#" checked onclick="$j('.table-#thistable#.ignore').prop('checked',true);" />
							Ignore All
						</label>
						<label for="field_#thistable#_deploy" class="radio inline">
							<input type="radio" name="field_#thistable#" id="field_#thistable#_deploy" value="#thistable#" onclick="$j('.table-#thistable#.default').prop('checked',true);" />
							Deploy All Defaults
						</label>
					</cfoutput>
				</ft:field>
				
				<cfloop collection="#stDiff.tables[thistable].fields#" item="thisfield">
					<cfswitch expression="#stDiff.tables[thistable].fields[thisfield].resolution#">
						<cfcase value="x">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisfield#_conflicts'>#thisfield#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
								<cfoutput>
									<label for="field_#thistable#_#thisfield#_ignore" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" class="table-#thistable# ignore" value="ignore" checked />
										Ignore
									</label>
									<label for="field_#thistable#_#thisfield#_repair" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_repair" class="table-#thistable# default" value="repair" />
										Repair
									</label>
								</cfoutput>
							</ft:field>
						</cfcase>
						<cfcase value="+">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisfield#_conflicts'>#thisfield#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
								<cfoutput>
									<label for="field_#thistable#_#thisfield#_ignore" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" class="table-#thistable# ignore" value="ignore" checked />
										Ignore
									</label>
									<label for="field_#thistable#_#thisfield#_deploy" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_deploy" class="table-#thistable# default" value="deploy" />
										Deploy
									</label>
								</cfoutput>
							</ft:field>
						</cfcase>
						<cfcase value="-">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisfield#_conflicts'>#thisfield#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
								<cfoutput>
									<label for="field_#thistable#_#thisfield#_ignore" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" class="table-#thistable# ignore default" value="ignore" checked />
										Ignore
									</label>
									<label for="field_#thistable#_#thisfield#_drop" class="radio inline">
										<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_drop" class="table-#thistable#" value="drop" />
										Drop
									</label>
									
									<cfset foundoption = false />
									<cfsavecontent variable="renameoptions">
										<select name="field_#thistable#_#thisfield#_rename_new" id="field_#thistable#_#thisfield#_rename_new" onchange="$j('##field_#thistable#_#thisfield#_rename').prop('checked',true);">
											<option value="">-- select --</option>
											<cfloop collection="#stDiff.tables[thistable].fields#" item="otherfield">
												<cfif structkeyexists(stDiff.tables[thistable].fields[otherfield],"resolution") and stDiff.tables[thistable].fields[thisfield].resolution eq "-">
													<cfif otherfield neq thisfield>
														<option value="#otherfield#">#otherfield#</option>
														<cfset foundoption = true />
													</cfif>
												</cfif>
											</cfloop>
										</select>
									</cfsavecontent>
									
									<cfif foundoption>
										<label for="field_#thistable#_#thisfield#_rename" class="radio inline">
											<input type="radio" class="rename" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_rename" value="rename" />
											Rename
										</label>
										&nbsp;#trim(renameoptions)#
									</cfif>
								</cfoutput>
							</ft:field>
						</cfcase>
					</cfswitch>
				</cfloop>
				
				<cfloop collection="#stDiff.tables[thistable].indexes#" item="thisindex">
					<cfswitch expression="#stDiff.tables[thistable].indexes[thisindex].resolution#">
						<cfcase value="x">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisindex#_conflicts'>#thisindex#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
								<cfoutput>
									<label for="index_#thistable#_#thisindex#_ignore" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" class="table-#thistable# ignore" value="ignore" checked />
										Ignore
									</label>
									<label for="index_#thistable#_#thisindex#_repair" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_repair" class="table-#thistable# default" value="repair" />
										Repair
									</label>
								</cfoutput>
							</ft:field>
						</cfcase>
						<cfcase value="+">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisindex#_conflicts'>#thisindex#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
								<cfoutput>
									<label for="index_#thistable#_#thisindex#_ignore" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" class="table-#thistable# ignore" value="ignore" checked />
										Ignore
									</label>
									<label for="index_#thistable#_#thisindex#_deploy" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_deploy" class="table-#thistable# default" value="deploy" />
										Deploy
									</label>
								</cfoutput>
							</ft:field>
						</cfcase>
						<cfcase value="-">
							<ft:field label="&nbsp;<span id='index_#thistable#_#thisindex#_conflicts'>#thisindex#</span>" bMultiField="true">
								<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
								<cfoutput>
									<label for="index_#thistable#_#thisindex#_ignore" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" class="table-#thistable# ignore" value="ignore" checked />
										Ignore
									</label>
									<label for="index_#thistable#_#thisindex#_drop" class="radio inline">
										<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_drop" class="table-#thistable# default" value="drop" />
										Drop
									</label>
								</cfoutput>
							</ft:field>
						</cfcase>
					</cfswitch>
				</cfloop>
			</cfcase>
			<cfcase value="+">
				<ft:field label="#thistable#" bMultiField="true">
					<cfoutput>
						<label for="table_#thistable#_ignore" class="radio inline">
							<input type="radio" name="table_#thistable#" id="table_#thistable#_ignore" value="ignore" checked />
							Ignore
						</label>
						<label for="table_#thistable#_deploy" class="radio inline">
							<input type="radio" name="table_#thistable#" id="table_#thistable#_deploy" value="deploy" />
							Deploy
						</label>
					</cfoutput>
				</ft:field>
			</cfcase>
			<cfcase value="-">
				<ft:field label="#thistable#" bMultiField="true">
					<cfoutput>
						<label for="table_#thistable#_ignore" class="radio inline">
							<input type="radio" name="table_#thistable#" id="table_#thistable#_ignore" value="ignore" checked />
							Ignore
						</label>
						<label for="table_#thistable#_drop" class="radio inline">
							<input type="radio" name="table_#thistable#" id="table_#thistable#_drop" value="drop" />
							Drop
						</label>
					</cfoutput>
				</ft:field>
			</cfcase>
		</cfswitch>
	</cfloop>
	
	<cfoutput>
			</fieldset>
		</div>
	</cfoutput>
	
	<ft:buttonPanel>
		<cfoutput>
			<div class="pull-right">
				<input id="showdebug" type="checkbox" name="debug" style="margin:0" value="1"<cfif (structkeyexists(form,"debug") and form.debug) or (structkeyexists(url,"debug") and url.debug)> checked</cfif>> <label for="showdebug">Show debug output</label>&nbsp;
				<input id="showsql" type="checkbox" name="sql" style="margin:0" value="1"<cfif (structkeyexists(form,"sql") and form.sql) or (structkeyexists(url,"sql") and url.sql)> checked</cfif>> <label for="showsql">Show SQL</label>&nbsp;
				<ft:button value="Deploy Changes" />
				<ft:button value="Cancel" />
			</div>
		</cfoutput>
	</ft:buttonPanel>
</ft:form>


<cffunction name="summariseChanges" output="false" returntype="string" hint="Returns a string summarising the changes">
	<cfargument name="resolution" type="string" required="true" hint="+,x,-" />
	<cfargument name="oldMetadata" type="struct" required="false" />
	<cfargument name="newMetadata" type="struct" required="false" />
	
	<cfset var result = "" />
	<cfset var thisprop = "" />
	<cfset var itemtype = "field" />
	
	<cfif (arguments.resolution eq "+" and listsort(structkeylist(arguments.newMetadata),"textnocase") eq "fields,name,type") or (arguments.resolution neq "+" and listsort(structkeylist(arguments.oldMetadata),"textnocase") eq "fields,name,type")>
		<cfset itemtype = "index" />
	</cfif>
	
	<cfif itemtype eq "index"><!--- Index --->
		<cfswitch expression="#arguments.resolution#">
			<cfcase value="+">
				<cfset result = "<span class='undeployed index'>+ [#arraytolist(arguments.newMetadata.fields)#]</span>" />
			</cfcase>
			<cfcase value="x">
				<cfset result = "<span class='altered index'>[#arraytolist(arguments.oldMetadata.fields)#] => [#arraytolist(arguments.newMetadata.fields)#]</span>" />
			</cfcase>
			<cfcase value="-">
				<cfset result = "<span class='deleted index'>- [#arraytolist(arguments.oldMetadata.fields)#]</span>" />
			</cfcase>
		</cfswitch>
	<cfelse><!--- Field --->
		<cfswitch expression="#arguments.resolution#">
			<cfcase value="+">
				<cfset result = "<span class='undeployed field'>+ #arguments.newMetadata.name#</span>" />
			</cfcase>
			<cfcase value="x">
				<cfset result = "<table>" />
				<cfloop list="type,default,nullable,precision" index="thisprop">
					<cfset result = "#result#<tr><td class='altered field'><strong>#thisprop#</strong>&nbsp;</td><td class='altered field'>#arguments.oldMetadata[thisprop]#</td><td class='altered field'>&nbsp;=>&nbsp;</td><td class='altered field'>#arguments.newMetadata[thisprop]#</td></tr>" />
				</cfloop>
				<cfset result = "#result#</table>" />
			</cfcase>
			<cfcase value="-">
				<cfset result = "<span class='deleted field'>- #arguments.oldMetadata.name#</span>" />
			</cfcase>
		</cfswitch>
	</cfif>
	
	<cfreturn result />
</cffunction>

<cfsetting enablecfoutputonly="false" />