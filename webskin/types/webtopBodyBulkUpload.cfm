<cfsetting enablecfoutputonly="true" />
<!--- @@viewbinding: type --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/core" prefix="core" />

<!--- ensure component metadata for bulk upload is set --->
<cfif 
	NOT application.stCOAPI[stObj.name].bBulkUpload
	OR NOT len(application.stCOAPI[stObj.name].bulkUploadTarget)>
	<cfabort showerror="#application.stCOAPI[stObj.name].displayName# (#application.stCOAPI[stObj.name].typepath#) must have bBulkUpload='true' component metadata and ftbulkuploadtarget='true' on a relevant media property for bulk upload.">	
</cfif>

<cfif isdefined("url.parentType")>
	<cfset mode = "formtool" />
<cfelse>
	<cfset mode = "standalone" />
</cfif>

<!--- Find default properties and upload target --->
<cfset uploadTarget = application.stCOAPI[stObj.name].bulkUploadTarget />
<cfset lDefaultFields = application.stCOAPI[stObj.name].bulkUploadDefaultFields />
<cfset lEditFields = application.stCOAPI[stObj.name].bulkUploadEditFields />

<cfset lFileIDs = "">

<cfset exit = false />
<ft:processform action="Save and Close">
	<ft:processformobjects typename="#stObj.name#">
		<cfset lFileIDs = listAppend(lFileIDs, stProperties.objectid)>
	</ft:processformobjects>
	<cfset exit = true />
</ft:processform>
<cfif exit>
	<cfoutput>
		<script type="text/javascript">
			<cfif mode eq "formtool">
				$j('###url.fieldname#', parent.document).val($j('###url.fieldname#', parent.document).val() + ',' + '#lFileIDs#');
				$fc.closeBootstrapModal();
			<cfelse>
				parent.$fc.closeBootstrapModal();
			</cfif>
		</script>
	</cfoutput>
	<cfexit method="exittemplate" />
</cfif>

<cfif structkeyexists(form,"action")>
	<cfset url.action = form.action />
</cfif>

<!--- Handle upload request --->
<cfif structkeyexists(url,"action") and url.action eq "upload">
	<cftry>
		<cfset allowedExtensions = "" />
		<cfif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftAllowedExtensions")>
			<cfset allowedExtensions = application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftAllowedExtensions />
		<cfelseif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftAllowedFileExtensions")>
			<cfset allowedExtensions = application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftAllowedFileExtensions />
		</cfif>
		
		<cfset sizeLimit = 0 />
		<cfif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftSizeLimit")>
			<cfset sizeLimit = application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftSizeLimit />
		<cfelseif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftMaxSize")>
			<cfset sizeLimit = application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftMaxSize />
		</cfif>
		
		<cfset filename = application.fc.lib.cdn.ioUploadFile(location="temp",destination="",field="file",nameconflict="makeunique",acceptextensions=allowedExtensions,sizeLimit=sizeLimit) />
		
		<cfset stDefaults = structnew() />
		<cfloop list="#lDefaultFields#" index="thisprop">
			<cfif structkeyexists(form,thisprop)>
				<cfset stDefaults[thisprop] = form[thisprop] />
			</cfif>
		</cfloop>
		
		<cfset stTask = {
			objectid = application.fapi.getUUID(),
			tempfile = filename,
			typename = stObj.name,
			targetfield = uploadTarget,
			defaults = stDefaults
		} />
		<cfset application.fc.lib.tasks.addTask(taskID=stTask.objectid,jobID=form.uploaderID,action="bulkupload.upload",details=stTask) />
		
		<!--- session only object for webskins --->
		<cfset fileObjectID = application.fapi.getUUID()>
		<cfset application.fapi.setData(typename=stObj.name,objectid=fileObjectID,bSessionOnly="true") />
		
		<cfset stResult = structnew() />
		<cfset stResult["files"] = arraynew(1) />
		<cfset stResult["files"][1] = structnew() />
		<cfset stResult["files"][1]["name"] = listlast(URLDecode(filename),"/") />
		<cfset stResult["files"][1]["url"] = application.fapi.fixURL(removevalues="upload",addvalues="action=view&uploader=#form.uploaderID#&file=#fileObjectID#") />
		<cfset stResult["files"][1]["thumbnail_url"] = "" />
		<cfset stResult["files"][1]["delete_url"] = "" />
		<cfset stResult["files"][1]["delete_type"] = "DELETE" />
		<cfset stResult["files"][1]["fileID"] = form.fileID />
		<cfset stResult["files"][1]["taskID"] = stTask.objectid />
		<cfset stResult["files"][1]["objectid"] = fileObjectID />
		
		<cfcatch>
			<cfset stResult = structnew() />
			<cfset stResult["error"] = application.fc.lib.error.normalizeError(cfcatch) />
			<cfset application.fc.lib.error.logData(stResult.error) />
		</cfcatch>
	</cftry>
	
	<cfset application.fapi.stream(content=stResult,type="json") />
</cfif>


<!--- Handle status check request --->
<cfif structkeyexists(url,"action") and url.action eq "status">
	<cftry>
		<cfset stResult = structnew() />
		<cfset stResult["files"] = application.fc.lib.tasks.getResults(jobID=url.uploader) />
		<cfset stResult["htmlhead"] = arraynew(1) />
		
		<cfloop from="1" to="#arraylen(stResult.files)#" index="i">
			<cfset stFile = stResult.files[i] />
			<cfif not structkeyexists(stFile,"error") and isdefined("stFile.result.objectid")>
				<cftry>
					<cfset stFile["stObject"] = getData(objectid=stFile.result.objectID) />
					<cfset stFile["teaserHTML"] = getView(stObject=stFile.stObject,template="librarySelected") />
					<cfset stFile["editHTML"] = "" />
				
					<cfif len(lEditFields)>
						<cfsavecontent variable="stFile.editHTML"><ft:object stObject="#stFile.stObject#" lFields="#lEditFields#" bIncludeFieldset="false" /></cfsavecontent>
					</cfif>

					<cfcatch>
						<cfset stFile["error"] = application.fc.lib.error.normalizeError(cfcatch) />
						<cfset application.fc.lib.error.logData(stResult.error) />
					</cfcatch>
				</cftry>
			<cfelseif not structkeyexists(stFile,"error") and isdefined("stFile.result.error")>
				<cfset stFile["error"] = stFile.result.error />
			</cfif>
		</cfloop>
		
		<cfif structkeyexists(stResult, "files") and arraylen(stResult.files)>
			<core:inHead variable="aHead" />
			<cfset stResult["htmlhead"] = aHead />
		</cfif>
		
		<cfcatch>
			<cfset stResult = structnew() />
			<cfset stResult["error"] = application.fc.lib.error.normalizeError(cfcatch) />
			<cfset application.fc.lib.error.logData(stResult.error) />
		</cfcatch>
	</cftry>
	
	<cfset application.fapi.stream(content=stResult,type="json") />
</cfif>


<!--- Handle save object request --->
<cfif structkeyexists(url,"action") and url.action eq "save">
	<cftry>
		<cfset stResult = structnew() />
		
		<ft:processform>
			<ft:processformobjects typename="#stObj.name#" />
		</ft:processform>
		
		<cfif len(lSavedObjectIDs)>
			<cfset stResult["stObject"] = getData(objectid=lSavedObjectIDs) />
			<cfset stResult["teaserHTML"] = getView(stObject=stResult.stObject,template="librarySelected") />
			<cfset stResult["editHTML"] = "" />
			
			<cfif len(lEditFields)>
				<cfsavecontent variable="stResult.editHTML"><ft:object stObject="#stResult.stObject#" lFields="#lEditFields#" bIncludeFieldset="false" /></cfsavecontent>
			</cfif>
		</cfif>
		
		<cfcatch>
			<cfset stResult = structnew() />
			<cfset stResult["error"] = application.fc.lib.error.normalizeError(cfcatch) />
			<cfset application.fc.lib.error.logData(stResult.error) />
		</cfcatch>
	</cftry>
	
	<cfset application.fapi.stream(content=stResult,type="json") />
</cfif>


<!--- Get name of type --->
<cfif structkeyexists(application.stCOAPI[stObj.name],"displayname") and len(application.stCOAPI[stObj.name].displayname)>
	<cfset typelabel = application.stCOAPI[stObj.name].displayname />
<cfelse>
	<cfset typelabel = stObj.name />
</cfif>

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadJS id="jquery-file-upload" />
<skin:loadJS id="fc-underscore" />
<skin:loadJS id="fc-backbone" />
<skin:loadJS id="fc-handlebars" />
<skin:loadJS id="bulk-upload" />
<skin:loadCSS id="fc-jquery-ui" />
<skin:loadCSS id="fc-fontawesome" />
<skin:loadCSS id="bulk-upload" />

<skin:htmlHead><cfoutput>
	<style type="text/css">
		.fa-info, .fa-times, .fa-save {
			cursor:pointer;
		}
		.info {
			display:none;
		}
			.info .key {
				color:##a020f0;
			}
			.info .number {
				color:##ff0000;
			}
			.info .string {
				color:##000000;
			}
			.info .boolean {
				color:##ffa500;
			}
			.info .null {
				color:##0000ff;
			}
		.remove-results {
			cursor: pointer;
		}
	</style>
	<script id="upload-area-template" type="text/x-handlebars-template">
		<div class="targetarea">
			<span class="btn btn-primary btn-large fileinput-button">
				<i class="fa fa-plus fa-white"></i>
				<span>Add files...</span>
				<!-- The file input field used as target for the file upload widget -->
				<input id="fileupload" type="file" name="file" multiple>
			</span>
			<p>or drag and drop files here</p>
		</div>
	</script>
	<script id="added-file-template" type="text/x-handlebars-template">
		<span class="pull-right">
			<span class="status">#application.fapi.getResource(key='webtop.utilities.bulkupload.status.queuedToUpload@text',default='Queued to upload')#</span>
			<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeunuploaded@text',default='Cancel upload')#"></i>
		</span>
		<div class="information">
			<span class="name">{{name}}</span>
			<span class="size">{{filesize size}}</span>
		</div>
	</script>
	<script id="uploading-file-template" type="text/x-handlebars-template">
		<span class="pull-right">
			<span class="status">#application.fapi.getResource(key='webtop.utilities.bulkupload.status.uploading@text',default='Uploading <span class="progress-loaded">{{filesize progress.loading}}</span> of <span class="progress-total">{{filesize progress.total}}</span>, <span class="progress-bitrate">{{bitrate progress.bitrate}}</span>')#</span>
			<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeunuploaded@text',default='Cancel upload')#"></i>
		</span>
		<div class="information">
			<span class="name">{{name}}</span>
			<span class="size">{{filesize size}}</span>
		</div>
		<div class="progress active progress-striped">
			<div class="bar" style="width:{{percentage progress.loaded progress.total}};"></div>
		</div
	</script>
	<script id="uploaddone-file-template" type="text/x-handlebars-template">
		<span class="pull-right">
			<span class="status"><i class='fa fa-spinner fa-spin'></i> #application.fapi.getResource(key='webtop.utilities.bulkupload.status.queuedForProcessing@text',default='Queued for processing')#</span>
			<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeunprocessed@text',default='Remove file (this file will still be added to the database)')#"></i>
		</span>
		<div class="information">
			<span class="name">{{name}}</span>
			<span class="size">{{filesize size}}</span>
		</div>
	</script>
	<script id="editable-file-template" type="text/x-handlebars-template">
		<table>
			<tr>
				<td width='30%' valign='top' class='teaser'>
					{{{teaserHTML}}}
				</td>
				<td width='70%' class='form'>
					{{{editHTML}}}
				</td>
				<td width='50px' valign='top' class='actions'>
					<i class='save fa fa-save' title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.save@text',default='Save content changes')#"></i>
					<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeprocessed@text',default='Remove file (this file will not be removed from the database)')#"></i>
				</td>
			</tr>
		</table>
	</script>
	<script id="saved-file-template" type="text/x-handlebars-template">
		<span class="pull-right">
			<span class="status">#application.fapi.getResource(key='webtop.utilities.bulkupload.status.saved@text',default='Saved')#</span>
			<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeprocessed@text',default='Remove file (this file will not be removed from the database)')#"></i>
		</span>
		<div class="information">
			{{##if teaserHTML}}
				{{{teaserHTML}}}
			{{else}}
				<span class="name">{{name}}</span>
				<span class="size">{{filesize size}}</span>
			{{/if}}
		</div>
	</script>
	<script id="failed-file-template" type="text/x-handlebars-template">
		<span class="pull-right">
			<span class="status">#application.fapi.getResource(key='webtop.utilities.bulkupload.status.failed@text',default='Failed')#</span>
			<i class="remove fa fa-times" title="#application.fapi.getResource(key='webtop.utilities.bulkupload.hint.removeunprocessed@text',default='Remove file')#"></i>
		</span>
		<div class="information">
			{{##if teaserHTML}}
				{{teaserHTML}}
			{{else}}
				<span class="name">{{name}}</span>
				<span class="size">{{filesize size}}</span>
			{{/if}}
		</div>
		<div class="alert alert-error">
			<span class="pull-right">
				<i class="fa fa-info"></i>
			</span>
			{{error.message}}
			<div class='info'><pre>{{syntaxhighlight error}}</pre></div></div>
		</div>
	</script>
	<script id="general-error-template" type="text/x-handlebars-template">
		<div class="alert alert-error">
			<i class="remove fa fa-times"></i>
			<span class="pull-right">
				<i class="fa fa-info"></i>
			</span>
			{{error.message}}
			<div class='info'><pre>{{syntaxhighlight error}}</pre></div></div>
		</div>
	</script>
</cfoutput></skin:htmlHead>

<skin:onReady><cfoutput>
	Window.app = {};
	Window.app.uploaderID = "#application.fapi.getUUID()#";
	
	Window.app.errorCollection = new ErrorCollection();
	Window.app.errorCollectionView = new ErrorCollectionView({
		el : $j("##bubbles")[0],
		collection : Window.app.errorCollection
	});
	
	Window.app.fileCollection = new FileCollection();
	Window.app.fileCollection.updateOptions({
		statusURL : "#application.fapi.fixURL(addvalues='action=status')#",
		uploaderID : Window.app.uploaderID,
		generalErrors : Window.app.errorCollection
	});
	Window.app.fileCollectionView = new FileCollectionView({
		el : $j(".upload-queue")[0],
		collection : Window.app.fileCollection,
		editableProperties : #serializeJSON(listtoarray(lEditFields))#
	});
	
	Window.app.uploadView = new FileUploadView({
		el : $j(".upload-target")[0],
		collection : Window.app.fileCollection,
		generalErrors : Window.app.errorCollection,
		
		uploaderID : Window.app.uploaderID,
		defaultProperties : #serializeJSON(listtoarray(lDefaultFields))#,
		
		<cfif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftSizeLimit") 
			and len(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftSizeLimit)>
			
			sizeLimit : #application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftSizeLimit#,
		</cfif>
		
		<cfif structkeyexists(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata,"ftAllowedExtensions") 
			and len(application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftAllowedExtensions)>
			
			allowedExtensions : "#application.stCOAPI[stObj.name].stProps[uploadTarget].metadata.ftAllowedExtensions#",
		</cfif>
		
		uploadURL : "#application.fapi.fixURL(addValues='action=upload')#",
		saveURL : "#application.fapi.fixURL(addvalues='action=save')#"
	});
	
	$j("##defaultProperties .title").click(function(){
		$j("##defaultProperties .body").slideToggle();
	});
</cfoutput></skin:onReady>

<cfoutput>
	<h1>
		<cfif len(application.stCOAPI[stObj.name].icon)>
			<i class="fa #application.stCOAPI[stObj.name].icon#"></i>
		<cfelse>
			<i class="fa fa-file"></i>
		</cfif>
		#typelabel#<!--- : <admin:resource key="webtop.utilities.bulkupload@title">Bulk Upload</admin:resource> --->
	</h1>
</cfoutput>

<ft:form>
	
	<!--- Show form for editing the default properties --->
	<cfif len(lDefaultFields)>
		<cfoutput>
			<div id="defaultProperties">
				<div class="title">
					<i class="fa fa-sort pull-right"></i>
					<admin:resource key="webtop.utilities.bulkupload.defaultproperties.title@text">Default Properties</admin:resource>
				</div>
				<div class="body">
					<admin:resource key="webtop.utilities.bulkupload.defaultproperties.description@html">
						<p>These values will be set on all future uploads.</p>
					</admin:resource>
					<ft:object typename="#stObj.name#" prefix="default" lFields="#lDefaultFields#" />
				</div>
			</div>
		</cfoutput>
	</cfif>
</ft:form>

<ft:form>
	
	<!--- Show drag / drop area --->
	<cfoutput>
		<div class="upload-target"></div>
		<div class="upload-queue"></div>
	</cfoutput>
	
	<ft:buttonPanel>
		<ft:button value="Save and Close" />
		<ft:button value="Close" onclick="$fc.closeBootstrapModal();" />
	</ft:buttonPanel>
	
</ft:form>

<cfsetting enablecfoutputonly="false" />