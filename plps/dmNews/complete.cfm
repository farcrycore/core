<!--- 
dmNews PLP
 - complete (complete.cfm)
--->

<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfset bComplete = true>

<!--- 
Not sure what all this all codswallop does...  probably deprecated
	<cfparam name="FORM.bDisplayTitle" default="0">
	<cfif NOT FindNoCase(Form.FieldNames, "bDisplayTitle")>
		<cfset Form.FieldNames = Form.FieldNames & ",bDisplayTitle">
	</cfif>
	
	<cfparam name="FORM.bUseCache" default="0">
	<cfif NOT FindNoCase(Form.FieldNames, "bUseCache")>
		<cfset Form.FieldNames = Form.FieldNames & ",bUseCache">
	</cfif>
	
	<cfparam name="form.editform.showImagesForm.selectFile" default="">
	<cfscript>
		output.teaserImage=form.editform.showImagesForm.selectFile;
	</cfscript>
	
	<cfif len(trim(form.teaser)) eq 0><cfset form.teaser=output.teaser></cfif>

	<cfif len(trim(form.body)) eq 0><cfset form.body=output.body></cfif>
	<cf_UpdateOutput>
	
	<cf_PLPNavigationButtons OnClick="HTMLEditcopyValue();">
	
	<cf_UpdateOutput> 
--->
