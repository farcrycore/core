<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Add / Remove Plugins --->

<cfif isdefined("url.icon")>
	<cfset qPlugins = application.fc.lib.system.getPlugins() />
	<cfquery dbtype="query" name="qPlugins">select * from qPlugins where id='#url.icon#'</cfquery>
	<cfcontent file="#expandpath('/farcry/plugins/#qPlugins.id#/install/#qPlugins.icon#')#">
</cfif>

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:processform action="Apply Changes">
	<cfset application.fc.lib.system.writeConstructorXML(plugins=form.plugins) />
	<cflocation url="#application.fapi.fixURL(addvalues='updateall=1')#" addtoken="false" />
</ft:processform>

<cfif isdefined("url.upload")>
	<cfif not isdefined("form.name")>
		<skin:bubble message="You must provide a directory / plugin id for the the upload" tags="error" />
	<cfelseif not isdefined("form.file")>
		<skin:bubble message="You must select a zip file upload" tags="error" />
	<cfelse>
		<!--- Upload and unzip plugin --->
		<cffile action="upload" accept="application/zip" mode="777" nameconflict="unique" filefield="file" destination="#GetTempDirectory()#" result="stUpload">
		<cfset zipRoot = "#GetTempDirectory()##createuuid()#">
		<cfdirectory action="create" directory="#zipRoot#">
		<cfzip action="unzip" file="#stUpload.serverDirectory#/#stUpload.serverFile#" recurse="true" destination="#zipRoot#">
		
		<!--- Backup old version --->
		<cfif directoryexists("#expandpath('/farcry/plugins')#/#form.name#")>
			<cfset newdir = "bak_#form.name#_#dateformat(now(),'yyyymmdd')##timeformat(now(),'hhmmss')#" />
			<cfdirectory action="rename" directory="#expandpath('/farcry/plugins')#/#form.name#" newdirectory="#expandpath('/farcry/plugins')#/#newdir#">
			<skin:bubble message="The existing '#form.name#' plugin has been backed up to #newdir#" />
		</cfif>
		
		<!--- Move new plugin files out of temp (if the zip only had one sub directory, then move that) --->
		<cfdirectory action="list" directory="#zipRoot#" recurse="false" name="qChildren">
		<cfif qChildren.recordcount eq 1 and qChildren.type[1] eq "dir">
			<cfdirectory action="rename" directory="#zipRoot#/#qChildren.name[1]#" newdirectory="#expandpath('/farcry/plugins')#/#form.name#">
			<cfdirectory action="delete" directory="#zipRoot#" recurse="true" />
		<cfelse>
			<cfdirectory action="rename" directory="#zipRoot#" newdirectory="#expandpath('/farcry/plugins')#/#form.name#">
		</cfif>
		
		<cffile action="delete" file="#stUpload.serverDirectory#/#stUpload.serverFile#">
		
		<cfif listfindnocase(url.currentselection,form.name)>
			<skin:bubble message="The new '#form.name#' plugin has been uploaded." />
		<cfelse>
			<skin:bubble message="The new '#form.name#' plugin has been uploaded. Would you like to <a href='##' class='select-new-plugin' data-plugin='#form.name#'>select it</a>?" />
		</cfif>
	</cfif>
</cfif>


<admin:header title="Add / Remove Plugins">

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="jquery-modal" />
<skin:loadCSS id="jquery-modal" />
<skin:htmlHead><cfoutput>
	<style type="text/css">
		.change-summary .remove { color:##FF0000; }
		.change-summary .add { color:##00DD00; }
		
		.plugin dt { float: left; clear: left; width: 180px; font-weight: bold; }
		.plugin dd { float:left; clear:right; margin-left:10px; padding:0; }
			.plugin dd.status { font-weight:bold; color:##ffa500; }
			.plugin dd.status.status-unknown { color:##666666; }
			.plugin dd.status.status-good { color:##00dd00; }
		.plugin .select, .plugin .picture { vertical-align:middle; }
		.plugin .information h2 { margin:0; line-height:30px; }
	</style>
	<script type="text/javascript">
		function getSelected(){
			var result = [];
			
			$j("input.select-plugin:checked").each(function(){
				result.push(this.value);
			});
			
			return result;
		}
		
		function updateChangeSummary(){
			var added = [], removed = [], summary = "";
			
			$j("input.select-plugin").each(function(){
				var currentvalue = $j(this).data("currentvalue");
				var newvalue = ($j(this).attr("checked")==="checked");
				var title = $j(this).parents("tr.plugin").find("h2").text();
				
				if (currentvalue !== newvalue){
					if ($j(this).attr("checked")==="checked")
						added.push(title);
					else
						removed.push(title);
				}
			});
			
			summary = added.length ? "<span class='add'>+ " + added.join(",&nbsp;&nbsp;") + "</span>" : "";
			if (added.length && removed.length)
				summary += ",&nbsp;&nbsp;";
			summary += removed.length ? "<span class='remove'>- " + removed.join(",&nbsp;&nbsp;") + "</span>" : "";
			
			$j(".change-summary").html(summary);
		}
		
		function uploadFile(){
			$fc.openModal("<h1>Upload New Plugin</h1><p>Upload a zip file containing the new plugin. It will be extracted into the specified directory.</p><form method='post' action='#application.fapi.fixURL(addvalues='upload=true',removevalues='updateall,currentselection')#&amp;currentselection="+getSelected().join(",")+"' enctype='multipart/form-data' class='uniForm'><div class='ctrlHolder inlineLabels'><label class='label' for='name'>Directory</label><div class='multiField'><input class='textInput required' type='text' id='name' name='name' placeholder='pluginid'></div><br style='clear: both;'></div><div class='ctrlHolder inlineLabels'><label class='label' for='name'>ZIP File</label><div class='multiField'><input type='file' id='file' name='file'></div><br style='clear: both;'></div><div class='buttonHolder ui-widget-header'><a href='##' onclick='$fc.closeModal();return false'>cancel</a>&nbsp;&nbsp;&nbsp;<button class='fc-btn ui-priority-primary jquery-ui-btn ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only' title='Upload' value='Upload' role='button' type='submit'><span class='ui-button-text'>Upload</span></button></div></form>",500,400,true,true);
		}
		
		$j(document).delegate(".plugin","click",function(ev){
			var tr = $j(ev.target).parents("tr.plugin");
			
			if (tr.is(".selected"))
				tr.removeClass("selected").find("input").attr("checked",false);
			else
				tr.addClass("selected").find("input").attr("checked",true);
			
			updateChangeSummary();
		});
		
		$j(document).delegate(".select-new-plugin","click",function(ev){
			var plugin = $j(ev.target).data("plugin");
			
			$j("input.select-plugin[value="+plugin+"]").trigger("click").attr("checked",true);
		});
		
		<cfif isdefined("url.currentselection")>
			$j(function(){
				var currentselection = #serializeJSON(listtoarray(url.currentselection))#;
				
				$j("input.select-plugin").each(function(){
					var $el = $j(this);
					
					if ($el.is(":checked") && currentselection.indexOf(this.value) === -1)
						$el.trigger("click").attr("checked",false);
					else if (!$el.is(":checked") && currentselection.indexOf(this.value) > -1)
						$el.trigger("click").attr("checked",true);
				});
			});
		</cfif>
	</script>
</cfoutput></skin:htmlHead>

<cfset qPlugins = application.fc.lib.system.getPlugins() />
<cfset currentPlugins = application.plugins />

<cfoutput><h1><admin:resource key="utilities.addremoveplugins">Add / Remove Plugins</admin:resource></h1></cfoutput>

<ft:form action="#application.fapi.fixURL(removevalues='updateall,upload,currentselection')#">
	<ft:buttonPanel>
		<cfoutput><span class="change-summary"></span>&nbsp;&nbsp;&nbsp;</cfoutput>
		<ft:button value="Upload New Plugin" onclick="uploadFile();return false;" priority="secondary" />
		<ft:button value="Apply Changes" confirmtext="This will restart the application and deploy all non-destructive schema changes. Are you sure you want to continue?" priority="primary" />
	</ft:buttonPanel>
	
	<cfoutput>
		<table class="farcry-objectadmin table table-striped table-hover">
			<thead>
				<tr>
					<th class="select">&nbsp;</th>
					<th class="information">Plugin</th></th>
					<th class="picture">Thumbnail</th></th>
				</tr>
			</thead>
			<tbody>
	</cfoutput>
	<cfoutput query="qPlugins">
		<tr class="plugin plugin-#qPlugins.type# <cfif listfindnocase(currentPlugins,qPlugins.id)>selected</cfif> <cfif qPlugins.currentrow mod 2>alt</cfif>">
			<td class="select">
				<input class="select-plugin" type="checkbox" name="plugins" value="#qPlugins.id#" data-currentvalue="<cfif listfindnocase(currentPlugins,qPlugins.id)>true<cfelse>false</cfif>" <cfif listfindnocase(currentPlugins,qPlugins.id)>checked</cfif>>
			</td>
			<td class="information">
				<h2>#qPlugins.name#</h2>
				<p>#qPlugins.description#</p>
				<dl>
					<cfif len(qPlugins.version)>
						<dt>Version</dt>
						<dd>#qPlugins.version#</dd>
					</cfif>
					
					<cfif len(qPlugins.releaseDate)>
						<dt>Release Date</dt>
						<dd>#dateformat(qPlugins.releaseDate,"d mmm yyyy")#</dd>
					</cfif>
					
					<cfif len(qPlugins.license)>
						<dt>License</dt>
						<dd>#qPlugins.license#</dd>
					</cfif>
					
					<cfif len(qPlugins.homeURL)>
						<dt>Home</dt>
						<dd><a href="#qPlugins.homeURL#">#qPlugins.homeURL#</a></dd>
					</cfif>
					
					<cfif len(qPlugins.docURL)>
						<dt>Documentation</dt>
						<dd><a href="#qPlugins.docURL#">#qPlugins.docURL#</a></dd>
					</cfif>
					
					<cfif len(qPlugins.bugURL)>
						<dt>Home</dt>
						<dd><a href="#qPlugins.bugURL#">#qPlugins.bugURL#</a></dd>
					</cfif>
					
					<cfif len(qPlugins.requiredPlugins)>
						<dt>Required Plugins</dt>
						<dd>#replace(qPlugins.requiredPlugins,',',', ','ALL')#</dd>
					</cfif>
					
					<cfif len(qPlugins.requiredCoreVersions)>
						<dt>Required Core Versions</dt>
						<dd>#replace(qPlugins.requiredCoreVersions,',',', ','ALL')#</dd>
					</cfif>
					
					<cfif len(qPlugins.status)>
						<dt>Status</dt>
						<dd class="status <cfif listfindnocase("good,unknown",qPlugins.status)>status-#lcase(qPlugins.status)#</cfif>">#qPlugins.status#</dd>
					</cfif>
				</dl>
			</td>
			<td class="picture">
				<cfif len(qPlugins.icon)>
					<img class="thumbnail" src="#application.fapi.fixURL(addvalues='icon=#qPlugins.id#',removevalues='updateall,upload,currentselection')#" alt="">
				</cfif>
			</td>
		</tr>
	</cfoutput>
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
	
	<ft:buttonPanel>
		<cfoutput><span class="change-summary"></span>&nbsp;&nbsp;&nbsp;</cfoutput>
		<ft:button value="Upload New Plugin" onclick="uploadFile();return false;" priority="secondary" />
		<ft:button value="Apply Changes" confirmtext="This will restart the application and deploy all non-destructive schema changes. Are you sure you want to continue?" priority="primary" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>



<cfsetting enablecfoutputonly="false" />