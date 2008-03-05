<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.fileFieldPrefix" default="">
<cfparam name="attributes.uploadType" default="file"> <!--- type of upload image/file --->
<cfparam name="attributes.fieldValue" default="">
<cfparam name="attributes.previewURL" default="">
<cfparam name="attributes.fieldLabel" default="Upload File:">
<cfparam name="attributes.bShowPreview" default="1">
<cfparam name="caller.output" default="">
<cfparam name="attributes.overWriteLabel" default="#application.rb.getResource("newFileOverwriteThisFile")#">

<cfset previewURL = attributes.previewURL> <!--- specific url of where item stored --->
<cfif previewURL EQ ""> <!--- set to default if not passed in --->
    <cfif attributes.uploadType EQ "file">
        <cfparam name="attributes.fieldLabel" default="#application.rb.getResource("fileLabel")#">  
        <cfset previewUrl = "#application.url.webroot#/files/">
    <cfelseif attributes.uploadType EQ "flash">
        <cfparam name="attributes.fieldLabel" default="#application.rb.getResource("fileLabel")#">
        <cfset flashPath = replaceNoCase(application.config.file.folderpath_flash, "\", "/", "ALL")>
        <cfset previewUrl = application.url.webroot & replaceNoCase(flashPath, application.path.project & "/www", "", "ALL") & "/">
    <cfelse>
        <cfparam name="attributes.fieldLabel" default="#application.rb.getResource("imageLabel")#">
        <cfset previewUrl = "#application.url.webroot#/images/">
    </cfif>
</cfif>

<cfset fileFieldPrefix = attributes.fileFieldPrefix>
<cfset fieldLabel = attributes.fieldLabel>
<cfset uploadType = attributes.uploadType>
<cfset overWriteLabel = attributes.overWriteLabel>
<cfset output = caller.output>
<cfif IsStruct(output) AND NOT StructIsEmpty(output)> <!--- called from a plp editform plp --->
    <cfset fieldValue = output[fileFieldPrefix]>
<cfelse>
    <cfset fieldValue = attributes.fieldValue>
</cfif>

<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfif fileFieldPrefix NEQ ""><cfoutput>
<label for="#fileFieldPrefix#_file_upload"><b>#fieldLabel#</b>
    <input type="file" name="#fileFieldPrefix#_file_upload" id="#fileFieldPrefix#_file_upload"><br />
</label>
<cfif fieldValue NEQ ""> <!--- shows current file --->
<nj:getFileIcon filename="#fieldValue#" r_stIcon="fileicon">
#overWriteLabel#<br />Existing #uploadType#: <img src="#application.url.farcry#/images/treeImages/#fileicon#"><cfif attributes.bShowPreview EQ 1>
<a href="#previewUrl##fieldValue#" target="_blank">#application.rb.getResource("previewUC")#</a></cfif> #fieldValue#
</cfif>
<input type="hidden" name="#fileFieldPrefix#_file_original" value="#fieldValue#">
</cfoutput></cfif>
<cfsetting enablecfoutputonly="false">