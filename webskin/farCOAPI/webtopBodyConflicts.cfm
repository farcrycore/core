<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: COAPI Conflict --->
<!--- @@description: Details about conflicts for a specific content type --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="url.typename" />
<cfset typeid = listlast(url.typename,".") />

<cfset stDiff = application.fc.lib.db.diffSchema(typename=url.typename,dsn=application.dsn) />


<admin:header />

<skin:htmlHead><cfoutput>
	<style type="text/css">
		div.ctrlHolder label.label.field, div.ctrlHolder label.label.index { font-weight:normal; }
		label.table { font-weight:bold; }
		strong { font-weight:bold; }
		
		.undeployed { color:##23d729; }
		.deleted { color:##ff0000; }
		.altered { color:##d78b23; }
	</style>
</cfoutput></skin:htmlHead>

<ft:form target="_parent" action="#application.url.webtop#/admin/coapioverview.cfm">
	<cfoutput>
		<input type="hidden" name="typename" value="#url.typename#" />
		<div class="">
			<fieldset class="fieldset">
				<h2 class="legend">Conflicts</h2>
	</cfoutput>
	
	<cfloop collection="#stDiff.tables#" item="thistable">
		<cfswitch expression="#stDiff.tables[thistable].resolution#">
			<cfcase value="x">
				<cfoutput>
					<div  class="ctrlHolder inlineLabels" >
						<label for="#typename#_#thistable#_table" class="label altered">#thistable#</label>
						
						<div class="multiField">
							<label for="field_#thistable#_ignore" class="table">
								<input type="radio" name="field_#thistable#" id="field_#thistable#_ignore" value="#thistable#" checked onclick="$j('.#thistable# input[name^=\'field_#thistable#\'].ignore,.#thistable# input[name^=\'index_#thistable#\'].ignore').attr('checked','checked');" />
								<strong>Ignore All</strong>
							</label>
							<label for="field_#thistable#_deploy" class="table">
								<input type="radio" name="field_#thistable#" id="field_#thistable#_deploy" value="#thistable#" onclick="$j('.#thistable# input[name^=\'field_#thistable#\'].default,.#thistable# input[name^=\'index_#thistable#\'].default').attr('checked','checked');" />
								Deploy All Defaults
							</label>
						</div>
						
						<br style="clear:both;">
					</div>
				</cfoutput>
				
				<cfloop collection="#stDiff.tables[thistable].fields#" item="thisfield">
					<cfswitch expression="#stDiff.tables[thistable].fields[thisfield].resolution#">
						<cfcase value="x">
							<cfoutput>
								<div  class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label altered field">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisfield#_conflicts">#thisfield#</span></label>
									<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
									
									<div class="multiField">
										<label for="field_#thistable#_#thisfield#_ignore">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" class="ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="field_#thistable#_#thisfield#_repair">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_repair" class="default" value="repair" />
											Repair
										</label>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
						<cfcase value="+">
							<cfoutput>
								<div  class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label undeployed field">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisfield#_conflicts">#thisfield#</span></label>
									<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
									
									<div class="multiField">
										<label for="field_#thistable#_#thisfield#_ignore">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" class="ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="field_#thistable#_#thisfield#_deploy">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_deploy" class="default" value="deploy" />
											Deploy
										</label>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
						<cfcase value="-">
							<cfoutput>
								<div class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label altered field">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisfield#_conflicts">#thisfield#</span></label>
									<skin:tooltip id="index_#thistable#_#thisfield#_conflicts" selector="##index_#thistable#_#thisfield#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].fields[thisfield])#" />
									
									<div class="multiField">
										<label for="field_#thistable#_#thisfield#_ignore">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="field_#thistable#_#thisfield#_drop">
											<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_drop" class="default" value="drop" />
											Drop
										</label>
										
										<cfset foundoption = false />
										<cfsavecontent variable="renameoptions">
											<select name="field_#thistable#_#thisfield#_rename_new" id="field_#thistable#_#thisfield#_rename_new">
												<option value="">-- select --</option>
												<cfloop collection="#stDiff.tables[thistable].fields#" item="otherfield">
													<cfif structkeyexists(stDiff.tables[thistable].fields[otherfield],"resolution") and stDiff.tables[thistable].fields[thisfield].resolution eq "-">
														<option value="#otherfield#">#otherfield#</option>
														<cfset foundoption = true />
													</cfif>
												</cfloop>
											</select>
										</cfsavecontent>
										
										<cfif foundoption>
											<label for="field_#thistable#_#thisfield#_rename">
												<input type="radio" name="field_#thistable#_#thisfield#" id="field_#thistable#_#thisfield#_rename" value="rename" />
												Rename
												
												#renameoptions#
											</label>
										</cfif>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
					</cfswitch>
				</cfloop>
				
				<cfloop collection="#stDiff.tables[thistable].indexes#" item="thisindex">
					<cfswitch expression="#stDiff.tables[thistable].indexes[thisindex].resolution#">
						<cfcase value="x">
							<cfoutput>
								<div class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label altered index">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisindex#_conflicts">#thisindex#</span></label>
									<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
									
									<div class="multiField">
										<label for="index_#thistable#_#thisindex#_ignore">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" class="ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="index_#thistable#_#thisindex#_repair">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_repair" class="default" value="repair" />
											Repair
										</label>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
						<cfcase value="+">
							<cfoutput>
								<div  class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label undeployed index">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisindex#_conflicts">#thisindex#</span></label>
									<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
									
									<div class="multiField">
										<label for="index_#thistable#_#thisindex#_ignore">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" class="ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="index_#thistable#_#thisindex#_deploy">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_deploy" class="default" value="deploy" />
											Deploy
										</label>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
						<cfcase value="-">
							<cfoutput>
								<div  class="ctrlHolder inlineLabels #thistable#" >
									<label for="#typename#_#thistable#_table" class="label deleted index">&nbsp;&nbsp;&nbsp;<span id="index_#thistable#_#thisindex#_conflicts">#thisindex#</span></label>
									<skin:tooltip id="index_#thistable#_#thisindex#_conflicts" selector="##index_#thistable#_#thisindex#_conflicts" message="#summariseChanges(argumentCollection=stDiff.tables[thistable].indexes[thisindex])#" />
									
									<div class="multiField">
										<label for="index_#thistable#_#thisindex#_ignore">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_ignore" value="ignore" checked />
											Ignore
										</label>
										<label for="index_#thistable#_#thisindex#_drop">
											<input type="radio" name="index_#thistable#_#thisindex#" id="index_#thistable#_#thisindex#_drop" class="default" value="drop" />
											Drop
										</label>
									</div>
									
									<br style="clear:both;">
								</div>
							</cfoutput>
						</cfcase>
					</cfswitch>
				</cfloop>
			</cfcase>
			<cfcase value="+">
				<cfoutput>
					<div  class="ctrlHolder inlineLabels" >
						<label for="#typename#_#thistable#_table" class="label undeployed">#thistable#</label>
						
						<div class="multiField">
							<label for="table_#thistable#_ignore">
								<input type="radio" name="table_#thistable#" id="table_#thistable#_ignore" value="ignore" checked />
								Ignore
							</label>
							<label for="table_#thistable#_deploy">
								<input type="radio" name="table_#thistable#" id="table_#thistable#_deploy" value="deploy" />
								Deploy
							</label>
						</div>
						
						<br style="clear:both;">
					</div>
				</cfoutput>
			</cfcase>
			<cfcase value="-">
				<cfoutput>
					<div  class="ctrlHolder inlineLabels" >
						<label for="#typename#_#thistable#_table" class="label altered">#thistable#</label>
						
						<div class="multiField">
							<label for="table_#thistable#_ignore">
								<input type="radio" name="table_#thistable#" id="table_#thistable#_ignore" value="ignore" checked />
								Ignore
							</label>
							<label for="table_#thistable#_drop">
								<input type="radio" name="table_#thistable#" id="table_#thistable#_drop" value="drop" />
								Drop
							</label>
						</div>
						
						<br style="clear:both;">
					</div>
				</cfoutput>
			</cfcase>
		</cfswitch>
	</cfloop>
	
	<cfoutput>
			</fieldset>
		</div>
	</cfoutput>
	
	<ft:buttonPanel>
		<cfoutput>
			<label>Show debug output <input type="checkbox" name="debug" value="1"<cfif (structkeyexists(form,"debug") and form.debug) or (structkeyexists(url,"debug") and url.debug)> checked</cfif>></label>&nbsp;
			<label>Show SQL <input type="checkbox" name="sql" value="1"<cfif (structkeyexists(form,"sql") and form.sql) or (structkeyexists(url,"sql") and url.sql)> checked</cfif>></label>&nbsp;
		</cfoutput>
		<ft:button value="Deploy Changes" />
		<ft:button value="Cancel" />
	</ft:buttonPanel>
</ft:form>

<admin:footer />

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