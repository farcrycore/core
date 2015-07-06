<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: CDN Migration Tool --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfif isdefined("url.copy")>
	<cftry>
		<cfset stResult = structnew() />
		<cfset stResult["file"] = url.copy />
		<cfset stResult["source"] = url.from />
		<cfset stResult["destination"] = url.to />
		
		<cfset application.fc.lib.cdn.ioCopyFile(source_location=url.from,source_file=url.copy,dest_location=url.to) />
		<cfset stResult["success"] = true />
		
		<cfcatch>
			<cfset application.fc.lib.error.logData(application.fc.lib.error.normalizeError(cfcatch)) />
			<cfset stResult = structnew() />
			<cfset stResult["success"] = false />
			<cfset stResult["error"] = cfcatch.message />
		</cfcatch>
	</cftry>
	
	<cfcontent type="text/json" variable="#ToBinary( ToBase64( serializeJSON(stResult) ) )#" reset="Yes">
</cfif>


<cfparam name="form.source_location" default="" />
<cfparam name="form.target_location" default="" />
<cfparam name="form.filter" default="" />
<cfparam name="form.copy" default="missing" />


<cfset qLocations = application.fc.lib.cdn.getLocations() />
<cfset qFiles = querynew("file,inSource,inTarget","varchar,bit,bit") />

<cfif len(form.source_location) and len(form.target_location) and form.source_location neq form.target_location>
	<cfset qSourceFiles = application.fc.lib.cdn.ioGetDirectoryListing(location=form.source_location,dir=form.filter) />
	<cfset qTargetFiles = application.fc.lib.cdn.ioGetDirectoryListing(location=form.target_location,dir=form.filter) />
	
	<cfset stFound = structnew() />
	<cfloop query="qSourceFiles">
		<cfif not structkeyexists(stFound,qSourceFiles.file)>
			<cfset stFound[qSourceFiles.file] = 1 />
		<cfelse>
			<cfset stFound[qSourceFiles.file] = stFound[qSourceFiles.file] + 1 />
		</cfif>
	</cfloop>
	<cfloop query="qTargetFiles">
		<cfif not structkeyexists(stFound,qTargetFiles.file)>
			<cfset stFound[qTargetFiles.file] = 2 />
		<cfelse>
			<cfset stFound[qTargetFiles.file] = stFound[qTargetFiles.file] + 2 />
		</cfif>
	</cfloop>
	
	
	<cfloop collection="#stFound#" item="thisfile">
		<cfset queryaddrow(qFiles) />
		<cfset querysetcell(qFiles,"file",thisfile) />
		<cfset querysetcell(qFiles,"inSource",bitand(stFound[thisfile],1) eq 1) />
		<cfset querysetcell(qFiles,"inTarget",bitand(stFound[thisfile],2) eq 2) />
	</cfloop>
	
	<cfquery dbtype="query" name="qFiles">select * from qFiles order by file</cfquery>
</cfif>

<admin:header>

<skin:htmlHead><cfoutput>
	<style>
		.selected, .selected td { background-color:##F9E6D4; }
		th.select, td.select { width:40px; }
		th.insource, td.insource, th.intarget, td.intarget { width:80px; }
		##files th.insource, td.insource { text-align:right; }
		td.insource, td.intarget, td.status { font-weight:bold; }
		.in-location-Yes { color:##01a100; }
		.in-location-No { color:##FF0000; }
		th.status, td.status { width:80px; }
		.status-not-applicable { color:##666666; }
		.status-success { color:##01a100; }
		.status-process { color:##C09853; }
		.status-failure { color:##FF0000; }
		.table-striped tbody tr:hover td { background-color:##FFF6EB; }
		.table-striped tbody tr.selected td { background-color:##F9E6D4; }
	</style>
	<script type="text/javascript">
		var files = #serializeJSON(listtoarray(valuelist(qFiles.file)))#;
		var processing = false;
		var processingfile = -1;
		
		function getNextFile(){
			var file = $j("##files tbody input[name=files]:checked").first().parents("tr");
			
			if (file.size()){
				return file.data("file") - 1;
			}
			else{
				return -1;
			}
		}
		
		function copyFiles(action){
			if (action==="toggle" && processing && processingfile>-1){
				processing = false;
			}
			else if ((action==="next" && processing) || (action==="toggle" && !processing)){
				processing = true;
				processingfile = getNextFile();
				
				if (processingfile>-1){
					$j("##file-"+(processingfile+1))
						.find(".status").removeClass("status-not-applicable").removeClass("status-success").removeClass("status-failure").addClass("status-process").html("...").attr("title","processing").end();
					
					$j.getJSON("#application.fapi.fixURL()#&copy="+encodeURI(files[processingfile])+"&from="+$j("##source_location").val()+"&to="+$j("##target_location").val(),function(data){
						if (data.success){
							$j("##file-"+(processingfile+1))
								.removeClass("selected")
								.find("input[name=files]").attr("checked",null).end()
								.find(".intarget").removeClass("in-location-No").removeClass("in-location-Yes").addClass("in-location-Yes").html("Yes").end()
								.find(".status").removeClass("status-not-applicable").removeClass("status-process").addClass("status-success").html("Done").end();
						}
						else{
							$j("##file-"+(processingfile+1))
								.removeClass("selected")
								.find("input[name=files]").attr("checked",null).end()
								.find(".status").removeClass("status-not-applicable").removeClass("status-process").addClass("status-failure").html("Error").attr("title",data.error).end();
						}
						
						copyFiles("next");
					});
				}
				else{
					processing = false;
				}
			}
		};
	</script>
</cfoutput>
<skin:onReady><cfoutput>
	$j("##allfiles").click(function(){
		var tr = $j("##files tbody input[name=files]").prop("checked",$j(this).prop("checked")).parents("tr.file");
		
		if ($j(this).prop("checked"))
			tr.addClass("selected");
		else
			tr.removeClass("selected")
	});
	$j("##files tbody tr").click(function(event){
		var target = $j(event.target), input = $j("input[name=files]",this), self = $j(this);
		
		if (!target.is("input"))
			input.prop("checked",!input.prop("checked"));
		
		if (input.prop("checked"))
			self.addClass("selected");
		else
			self.removeClass("selected");
	});
</cfoutput></skin:onReady>

<cfoutput>
	<h1><admin:resource key="webtop.utilities.cdnmigrator@title">CDN Migration Tool</admin:resource></h1>
	<admin:resource key="webtop.utilities.coapisqllog.blurb@html">
		<p>This tool makes it easy to migrate to CDN hosting, by making it easy to compare CDN locations and copy files between locations.</p>
	</admin:resource>
</cfoutput>

<ft:form>
	<ft:field label="Source Location" for="source_location">
		<cfoutput>
			<select id="source_location" name="source_location">
				<option value="">-- select --</option>
				<cfloop query="qLocations">
					<option value="#qLocations.name#" <cfif form.source_location eq qLocations.name> selected</cfif>>#qLocations.name# (#ucase(qLocations.type)#)</option>
				</cfloop>
			</select>
		</cfoutput>
	</ft:field>
	
	<ft:field label="Target Location" for="target_location">
		<cfoutput>
			<select id="target_location" name="target_location">
				<option value="">-- select --</option>
				<cfloop query="qLocations">
					<option value="#qLocations.name#" <cfif form.target_location eq qLocations.name> selected</cfif>>#qLocations.name# (#ucase(qLocations.type)#)</option>
				</cfloop>
			</select>
		</cfoutput>
	</ft:field>
	
	<ft:field label="Sub Directory" for="filter">
		<cfoutput>
			<input id="filter" name="filter" value="#form.filter#" size="15" placeholder="sub-directory">
		</cfoutput>
	</ft:field>
	
	<ft:buttonPanel>
		<cfif qFiles.recordcount>
			<ft:button value="Copy Files" onclick="copyFiles('toggle');return false;" />
		</cfif>
		<ft:button value="Compare" />
	</ft:buttonPanel>
	
	<cfif qFiles.recordcount>
		<ft:field label="Files" bMultiField="true">
			<cfoutput>
				<table id="files" class="table table-striped">
					<thead>
						<tr>
							<th class="select"><input type="checkbox" id="allfiles"></th>
							<th class="file">File</th>
							<th class="insource">In Source</th>
							<th class="intarget">In Target</th>
							<th class="status">Status</th>
						</tr>
					</thead>
					<tbody>
			</cfoutput>
			
			<cfloop query="qFiles">
				<cfoutput>
					<tr id="file-#qFiles.currentrow#" class="file" data-file="#qFiles.currentrow#">
						<td class="select"><input type="checkbox" name="files" value="#qFiles.file#"></td>
						<td class="file">#qFiles.file#</td>
						<td class="insource in-location-#yesnoformat(qFiles.inSource)#">#yesnoformat(qFiles.inSource)#</td>
						<td class="intarget in-location-#yesnoformat(qFiles.inTarget)#">#yesnoformat(qFiles.inTarget)#</td>
						<td class="status status-not-applicable">N/A</td>
					</tr>
				</cfoutput>
			</cfloop>
			
			<cfoutput>
					</tbody>
				</table>
			</cfoutput>
		</ft:field>
		
		<ft:buttonPanel>
			<ft:button value="Copy Files" onclick="copyFiles('toggle');return false;" />
		</ft:buttonPanel>
	</cfif>
</ft:form>

<admin:footer>

<cfsetting enablecfoutputonly="false" />