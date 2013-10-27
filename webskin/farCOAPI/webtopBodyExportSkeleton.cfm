<!--- tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<skin:loadJS id="jquery" />
<skin:loadJS id="jquery.ajaxq" lFiles="#application.url.webtop#/thirdparty/jquery.ajaxq/jquery.ajaxq-0.0.1.js" />


<!--- ENVIRONMENT VARIABLES --->
<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
<cfset stSkeletonExport = application.fapi.getNewContentObject(typename="farSkeleton", key="NewExport") />
<cfset bExportComplete = application.fapi.getContentType("farSkeleton").isExportComplete(stSkeletonExport.objectid) />

<ft:processForm action="Start Again" url="refresh">
	<cfset structDelete(session.stTempObjectStoreKeys.farSkeleton,"NewExport")>
</ft:processForm>


<ft:processForm action="Download Package">

	<cfif fileExists("#application.path.webroot#/project.zip")>
		<cffile action="delete"  file="#application.path.webroot#/project.zip">	
	</cfif>
	

	<cfset oZip.AddFiles(zipFilePath="#application.path.webroot#/project.zip", directory="#application.path.project#/project_export", recurse="true", compression=0, savePaths="false") />
	

	<skin:location url="/project.zip" />
</ft:processForm>

<ft:processForm action="Delete Old Export" url="refresh">
	
	<cfset stResult = application.fapi.getContentType("farSkeleton").deleteOldExport() />
	
	<skin:bubble message="#stResult.message#" />
	<skin:location url="#cgi.script_name#?#cgi.query_string#" />

</ft:processForm>

<ft:processForm action="Export Now" url="refresh">
	
	<ft:processFormObjects typename="farSkeleton" bSessionOnly="true" />

	<cfset stResult = application.fapi.getContentType("farSkeleton").exportStepCreateSQL(stSkeletonExport.objectid) />

	<cfif not stResult.bSuccess>
		<skin:bubble message="#stResult.message#" />
		<skin:location url="#cgi.script_name#?#cgi.query_string#" />
	</cfif>


		
</ft:processForm>



<skin:loadJS id="jquery-ajaxq" />

<ft:form>
	
	
	<cfif not len(stSkeletonExport.name)>
		<cfset stSkeletonExport.name = "#application.applicationName#" />
		<cfset stSkeletonExport.updateAppKey = "1" />
		<cfset stSkeletonExport.bIncludeMedia = "1" />

		<cfset application.fapi.setData(stProperties="#stSkeletonExport#", bSessionOnly="true") />

		<cfset stSkeletonExport = application.fapi.getContentObject(typename="#stSkeletonExport.typename#", objectid="#stSkeletonExport.objectid#") />
	</cfif>


	<cfif stSkeletonExport.bSetupComplete>
		<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#" format="display" legend="Export for Hosting" lFields="name,updateAppKey,bIncludeMedia,lExcludeData" />
	<cfelse>
		<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#" legend="Export for Hosting" lFields="name,updateAppKey,bIncludeMedia,lExcludeData" />
	</cfif>
	

	<cfif stSkeletonExport.bSetupComplete AND isStruct(stSkeletonExport.exportData)>
		<cfoutput>
		<cfif bExportComplete>
			<p><i id="progress" class="fa fa-check-square-o" style="color:green;" title="Complete"></i> Export is Complete</p>
		<cfelse>
			<div id="exportTable-wrap">
				<p>Tables to Export: #arrayLen(stSkeletonExport.exportData.aTables)#</p>
				<p>DBs to Export: #stSkeletonExport.exportData.lDBTypes#</p>
			
				
				<table class="table" style="width:auto;">
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
								url: '/index.cfm?ajaxmode=1&type=farSkeleton&objectid=#stSkeletonExport.objectid#&view=ajaxExportTable&position=#iTable#&sqlFilesPath=#urlEncodedFormat(stSkeletonExport.exportData.sqlFilesPath)#', 
								
								beforeSend: function(data){
									$j('##progress-#iTable#').removeClass('fa-check-square-o').addClass('fa-spinner fa-spin').attr('title','Processing');
								},
								success: function(data){;
									$j('##progress-#iTable#').removeClass('fa-times-circle fa-spinner fa-spin').addClass('fa-check-square-o').css('color','green').attr('title','Success');
									$j('##response-#iTable#').html(data);

									if (data.BEXPORTCOMPLETE == 1){
										$j('##exportTable-wrap').html('<p><i id="progress" class="fa fa-check-square-o" style="color:green;" title="Complete"></i> Export is Complete</p>');
										$j('##btn-export').hide('slow');
										$j('##btn-download').show();
										$j('##btn-start-again').show();

									}
									
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
		</cfif>
		
		</cfoutput>
	</cfif>
	
	<ft:buttonPanel>
		<cfif NOT isStruct(stSkeletonExport.exportData) OR NOT bExportComplete>
			<ft:button id="btn-export" value="Export Now" confirmText="Are you sure you want to export. This will lock your application and may take some time depending on the size of your data." />
			<ft:button id="btn-start-again" value="Start Again" style="display:none;" />
		<cfelse>
			<ft:button id="btn-start-again" value="Start Again" />
		</cfif>
		

		<cfif directoryexists('#application.path.project#/project_export/farcry')>
			<ft:button id="btn-download" value="Download Package" style="" priority="primary" />
		<cfelse>
			<ft:button id="btn-download" value="Download Package" style="display:none;" />
		</cfif>

		<cfif directoryexists('#application.path.project#/project_export')>
			<ft:button id="btn-delete-package" value="Delete Old Export" style="" />
		</cfif>
		

	</ft:buttonPanel>
</ft:form>




















