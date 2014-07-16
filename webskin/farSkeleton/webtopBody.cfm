<cfsetting enablecfoutputonly="true" requesttimeout="999">
<!--- @@displayname: Export Skeleton --->

<!--- tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">


<cfset stSkeletonExport = application.fapi.getNewContentObject(typename="farSkeleton", key="NewExport") />
<cfset oSkeleton = application.fapi.getContentType("farSkeleton") />


<!--- create zip of data only and download --->
<ft:processForm action="downloaddata">
	<cfset zipFile = oSkeleton.zipSQLDATA()>
	<cfheader name="Content-disposition" value="attachment;filename=#application.applicationname#-data.zip" />
	<cfheader name="content-length" value="#getFileInfo(zipFile).size#" />
	<cfcontent type="application/zip" file="#zipFile#" reset="true" />
</ft:processForm>

<!--- create zip of code and data only and download --->
<ft:processForm action="downloadcode">
	<cfset zipFile = oSkeleton.zipInstaller(excludeMedia=true)>
	<cfheader name="Content-disposition" value="attachment;filename=#application.applicationname#-project.zip" />
	<cfheader name="content-length" value="#getFileInfo(zipFile).size#" />
	<cfcontent type="application/zip" file="#zipFile#" reset="true" />
</ft:processForm>

<!--- create zip of code, data and media and download --->
<ft:processForm action="downloadall">
	<cfset zipFile = oSkeleton.zipInstaller()>
	<cfheader name="Content-disposition" value="attachment;filename=#application.applicationname#-project-all.zip" />
	<cfheader name="content-length" value="#getFileInfo(zipFile).size#" />
	<cfcontent type="application/zip" file="#zipFile#" reset="true" />
</ft:processForm>

<ft:processForm action="deleteexport" url="refresh">
	<cfset stResult = oSkeleton.deleteSQLExportData()>
	<skin:bubble message="#stResult.message#" />
	<cfset stResult = oSkeleton.deleteOldExport() />
	<skin:bubble message="#stResult.message#" />
	<cfset structDelete(session.stTempObjectStoreKeys.farSkeleton,"NewExport")>
</ft:processForm>

<ft:processForm action="exportdata" url="refresh">
	<ft:processFormObjects typename="farSkeleton" bSessionOnly="true" />
	<cfset stResult = oSkeleton.exportStepCreateSQL(stSkeletonExport.objectid) />
	<cfif not stResult.bSuccess>
		<skin:bubble message="#stResult.message#" />
		<skin:location url="#cgi.script_name#?#cgi.query_string#" />
	</cfif>
</ft:processForm>



<!--- set view state --->
<cfset exportstate = "exportdata">
<cfset SQLDataSize = oSkeleton.getSQLDataSize()>
<cfif SQLDataSize gt 0>
	<cfset exportstate = "download">
</cfif>


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="jquery-ajaxq" />


<cfoutput>
<h1>Skeleton Export Utility</h1>

<style type="text/css">
.controls .multiField label {
	float: left;
	width: 16em;
	line-height: 1.8;
	overflow: hidden;
	white-space: nowrap;
	text-overflow: ellipsis;
}
</style>

<cfswitch expression="#exportState#">

	<cfcase value="exportdata">
		<ft:form>
			
			<cfif stSkeletonExport.bSetupComplete>
				<div class="alert alert-warning">
					<i class="fa fa-info-circle"></i> Your export is now in progress...
				</div>

				<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#"
					legend="Export Skeleton Data" format="display" 
					lFields="lExcludeData" />
			<cfelse>
				<div class="alert alert-info">
					<i class="fa fa-info-circle"></i> Export your data and project skeleton using the form below. Excluding tables from the data export is optional.
				</div>

				<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#"
					legend="Export Skeleton Data" 
					lFields="lExcludeData" />

				<ft:buttonPanel>
					<ft:button id="btn-export" value="exportdata" text="Export Data" confirmText="Are you sure you want to export. This will lock your application and may take some time depending on the size of your data." />
				</ft:buttonPanel>
			</cfif>
			

			<cfif stSkeletonExport.bSetupComplete AND isStruct(stSkeletonExport.exportData)>

				<div id="exportTable-wrap">
					<p>Tables to Export: #arrayLen(stSkeletonExport.exportData.aTables)#</p>
					<p>DBs to Export: #stSkeletonExport.exportData.lDBTypes#</p>
					
					<table class="table table-striped">
					<cfloop from="1" to="#arrayLen(stSkeletonExport.exportData.aTables)#" index="iTable">
						<tr>
							<td>#stSkeletonExport.exportData.aTables[iTable].name#</td>
						
							
							<cfif stSkeletonExport.exportData.aTables[iTable].bComplete>
								<td><i id="progress-#iTable#" class="fa fa-check-square-o" style="color:green;" title="Complete"></i></td>
								<td id="response-#iTable#">Already Complete</td>
							<cfelse>
								<td><i id="progress-#iTable#" class="fa fa-times-circle" style="color:orange;" title="pending"></i></td>
								<td id="response-#iTable#"></td>
								<skin:onReady>
									$j.ajaxq('ajaxExportTable',{
								
									type: "POST",
									cache: false,
									url: '#application.url.webtop#/index.cfm?ajaxmode=1&type=farSkeleton&objectid=#stSkeletonExport.objectid#&view=ajaxExportTable&position=#iTable#&contentType=#stSkeletonExport.exportData.aTables[iTable].name#&bCoapi=#stSkeletonExport.exportData.aTables[iTable].bCoapi#', 
									
									beforeSend: function(data){
										$j('##progress-#iTable#').removeClass('fa-check-square-o').addClass('fa-spinner fa-spin').attr('title','Processing');
									},
									success: function(data){;
										
										$j('##response-#iTable#').html(data);

										if (data.BSUCCESS == true){
											$j('##progress-#iTable#').removeClass('fa-times-circle fa-spinner fa-spin').addClass('fa-check-square-o').css('color','green').attr('title','Success');
										} else {
											$j('##progress-#iTable#').removeClass('fa-times-circle fa-spinner fa-spin').addClass('fa-exclamation-triangle').css('color','red').attr('title','Error');
										}


										if (data.BEXPORTCOMPLETE == 1){
											$j('##btn-export-complete').prop("disabled", false).click();
										};

									}, 
									error: function(data){	
										$j('##progress-#iTable#').removeClass('fa-times-circle fa-spinner fa-spin').addClass('fa-exclamation-triangle').css('color','red').attr('title','Error');
										$j('##response-#iTable#').html(data.statusText);
										$j('##btn-retry').show();
									},
									complete: function(){
									},
									
									timeout: 60000
								});
											
								</skin:onReady>
							</cfif>
						
						</tr>
					</cfloop>
					</table>
				</div>

				<ft:buttonPanel>
					<ft:button id="btn-export-complete" value="View Downloads" disabled="true" />
				</ft:buttonPanel>
				
			</cfif>

		</ft:form>
	</cfcase>

	<cfcase value="download">
		<ft:form>
			<div class="alert alert-info">
				<i class="fa fa-info-circle"></i> You have successfully exported your database. Choose a project download option below.
			</div>

			<div style="padding-top: 5px">
				<h3><i class="fa fa-book fa-fw"></i> Project Data Only (#numberFormat(SQLDataSize, "9.99")# MB, uncompressed)</h3>
				<p>FarCry project data can be used to replace the data in an existing project, perform a database only installation or database migration.</p>
				<ft:button value="downloaddata" text="Download Data" icon="fa fa-download" class="btn-primary btn-large" disableOnSubmit="false" />
			</div>
			
			<div style="padding-top: 20px;">
				<h3><i class="fa fa-code fa-fw"></i> Project Code &amp; Data</h3>
				<p>This export includes the project data, code base, core framework and all installed plugins.</p>
				<ft:button value="downloadcode" text="Download Code &amp; Data" icon="fa fa-download" class="btn-primary btn-large" disableOnSubmit="false" />
			</div>
			
			<div style="padding-top: 20px">
				<h3><i class="fa fa-picture-o fa-fw"></i> Project Code, Data &amp; Media</h3>
				<p>Choose this option only if you want the complete kit and dice, including all images and files.</p>
				<ft:button value="downloadall" text="Download Code, Data &amp; Media" icon="fa fa-download" class="btn-primary btn-large" disableOnSubmit="false" />
			</div>

			<div style="padding-top: 20px">
				<hr>
				<h3><i class="fa fa-repeat fa-fw"></i> Delete Export and Start Again</h3>
				<ft:button value="deleteexport" text="Delete Export" icon="fa fa-trash-o" class="btn-large" disableOnSubmit="false" />
			</div>
		</ft:form>

	</cfcase>

</cfswitch>

</cfoutput>

<cfsetting enablecfoutputonly="false">