<cfsetting enablecfoutputonly="true" /> 
<!--- @@displayname: Export Skeleton --->


<!--- tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<!--- ENVIRONMENT VARIABLES --->
<cfset stSkeletonExport = application.fapi.getNewContentObject(typename="farSkeleton", key="NewExport") />
<cfset oSkeleton = application.fapi.getContentType("farSkeleton") />
<cfset bExportComplete = oSkeleton.isExportComplete(stSkeletonExport.objectid) />



<!--- 
 // process form 
--------------------------------------------------------------------------------->
<!--- ## remove all data from the ./myproject/install directory and reset for export --->
<ft:processForm action="Refresh Data" url="refresh">
	<cfset oSkeleton.deleteSQLExportData()>
	<cfset structDelete(session.stTempObjectStoreKeys.farSkeleton,"NewExport")>
</ft:processForm>

<!--- ## create zip of data only and download --->
<ft:processForm action="Download Data">
	<cfset zipFile = oSkeleton.zipSQLDATA()>
	<skin:location url="/#zipFile#" />
</ft:processForm>


<ft:processForm action="Delete Old Export" url="refresh">
	<cfset stResult = oSkeleton.deleteOldExport() />
	<cfset structDelete(session.stTempObjectStoreKeys.farSkeleton,"NewExport")>
	<skin:bubble message="#stResult.message#" />
	<!--- GB: who is your daddy, and what does he do? --->
	<!--- <skin:location url="#cgi.script_name#?#cgi.query_string#" /> --->
</ft:processForm>


<ft:processForm action="Export Data" url="refresh">
	<ft:processFormObjects typename="farSkeleton" bSessionOnly="true" />

	<cfset stResult = oSkeleton.exportStepCreateSQL(stSkeletonExport.objectid) />

	<cfif not stResult.bSuccess>
		<skin:bubble message="#stResult.message#" />
		<skin:location url="#cgi.script_name#?#cgi.query_string#" />
	</cfif>
		
</ft:processForm>



<!--- 
 // view: skeleton export 
--------------------------------------------------------------------------------->
<!--- set form state --->
<cfset SQLDataSize = oSkeleton.getSQLDataSize()>
<cfif SQLDataSize gt 0>
	<cfset exportstate = "download">
<cfelse>
	<cfset exportstate = "exportdata">
</cfif>


<skin:loadJS id="jquery" />
<skin:loadJS id="jquery.ajaxq" lFiles="#application.url.webtop#/thirdparty/jquery.ajaxq/jquery.ajaxq-0.0.1.js" />

<cfoutput>
	<h1>Skeleton Export Utility</h1>
</cfoutput>
<!--- <skin:pop /> --->


<cfswitch expression="#exportState#">
<cfcase value="download">
<!--- 
 // view: download exported skeleton
--------------------------------------------------------------------------------->
<ft:form>
	<ft:button value="Delete Old Export" icon="fa fa-bolt" class="btn-large" />

	<cfoutput><div>
	<h3><i class="fa fa-book"></i> Project Data Only (#numberFormat(SQLDataSize, "99.99")# Mb)</h3>
	<p>FarCry project data can be used to replace the data in an existing project, perform a database only installation or database migration.</p>
	</cfoutput>
	<ft:button value="Download Data" icon="fa fa-download" class="btn-primary btn-large" />
	<ft:button value="Refresh Data" icon="fa fa-repeat" class="btn-large" />
	<cfoutput></div></cfoutput>
	
	<cfoutput><div style="padding-top: 15px">
	<h3><i class="fa fa-code"></i> Project Code &amp; Data</h3></cfoutput>
	<cfoutput><p>This export includes the project data, code base, core framework and all installed plugins.</p></cfoutput>
	<ft:button value="Download Code &amp; Data" icon="fa fa-download" class="btn-primary btn-large" />
	<cfoutput></div></cfoutput>
	
	<cfoutput><div style="padding-top: 15px">
	<h3><i class="fa fa-picture-o"></i> Project Media, Code, &amp; Data</h3></cfoutput>
	<cfoutput><p>Choose this option only if you want the complete kit and dice, including all images and files.</p></cfoutput>
	<ft:button value="Download Media, Code, &amp; Data" icon="fa fa-download" class="btn-primary btn-large disabled" />
	<cfoutput></div></cfoutput>
</ft:form>

</cfcase>

<cfcase value="exportdata">
<!--- 
 // view: export project data
--------------------------------------------------------------------------------->
<ft:form>
	
	<cfif stSkeletonExport.bSetupComplete>
		<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#"
			legend="Export Skeleton Data" format="display" 
			lFields="lExcludeData" />
	<cfelse>
		<ft:object typename="#stSkeletonExport.typename#" objectid="#stSkeletonExport.objectid#"
			legend="Export Skeleton Data" 
			lFields="lExcludeData" />
	</cfif>
	

	<cfif stSkeletonExport.bSetupComplete AND isStruct(stSkeletonExport.exportData)>
		<cfoutput>
		<cfif bExportComplete>
			<p><i id="progress" class="fa fa-check-square-o" style="color:green;" title="Complete"></i> Export is Complete</p>
		<cfelse>
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
								url: '/index.cfm?ajaxmode=1&type=farSkeleton&objectid=#stSkeletonExport.objectid#&view=ajaxExportTable&position=#iTable#', 
								
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
		<ft:button id="btn-export" value="Export Data" confirmText="Are you sure you want to export. This will lock your application and may take some time depending on the size of your data." />
	</ft:buttonPanel>
</ft:form>
</cfcase>

</cfswitch>

<cfsetting enablecfoutputonly="false" /> 