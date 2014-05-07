<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="developer">

	<cfoutput>
		<h2>#application.rb.getResource("coapi.bulkFileUpload.headings.bulkfileupload@text","Bulk File Upload")#</h2>
	</cfoutput>
	
	<ft:processform action="Upload files">
		<ft:processformobjects typename="bulkFileUpload" r_stObject="stObj" />
		<cfparam name="stObj.result" default="" />
		<cfoutput>#stObj.result#</cfoutput>
	</ft:processform>

	<ft:form>
		<ft:object typename="bulkFileUpload" />
		
		<ft:buttonPanel>
			<ft:button value="Upload files" />
		</ft:buttonPanel>
	</ft:form>
	
	<cfoutput>
		<h3>#application.rb.getResource("coapi.bulkFileUpload.labels.instructions@text","Instructions:")#</h3>
		<admin:resource key="coapi.bulkFileUpload.messages.uploadfileblurb@text">
			<p>This utility will quickly upload multiple files into FarCry</p>
			<p>You will need to supply a .zip file that contains the files to be uploaded. Files and Directories contained in the .zip file will be recreated within FarCry under the selected node.</p>
		</admin:resource>
	</cfoutput>
	
</sec:CheckPermission>

<admin:footer />

<cfsetting enablecfoutputonly="false" />