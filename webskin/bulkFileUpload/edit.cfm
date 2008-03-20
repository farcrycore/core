<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="developer">

	<cfoutput>
		<h2>#application.rb.getResource("coapi.bulkFileUpload.general.heading","Bulk File Upload")#</h2>
	</cfoutput>
	
	<ft:processform action="Upload files">
		<ft:processformobjects typename="bulkFileUpload" r_stObject="stObj" />
		<cfparam name="stObj.result" default="" />
		<cfoutput>#stObj.result#</cfoutput>
	</ft:processform>

	<ft:form>
		<ft:object typename="bulkFileUpload" />
		
		<ft:farcryButtonPanel>
			<ft:farcryButton value="Upload files" />
		</ft:farcryButtonPanel>
	</ft:form>
	
	<cfoutput>
		<h3>#application.rb.getResource("coapi.bulkFileUpload.general.instructions","Instructions:")#</h3>
		<p>#application.rb.getResource("coapi.bulkFileUpload.general.uploadfileblurb","<p>This utility will quickly upload multiple files into Farcry</p><p>You will need to supply a .zip file that contains the files to be uploaded. Files and Directories contained in the .zip file will be recreated within Farcry under the selected node.</p>")#</p>
	</cfoutput>
	
</sec:CheckPermission>

<admin:footer />

<cfsetting enablecfoutputonly="false" />