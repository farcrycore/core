<!---
	Name:			flashUpload.cfm
	Author:			Nahuel Foronda & Laura Arguello
	Created:		August 07, 2005
	This work is licensed under the Creative Commons Attribution-ShareAlike License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.

Please keep this notice to comply with license
------------------------------------------------------------------------------------------------------------------------------------------------
		
	Attributes:
		name: Required; Name of the tezt input with file name
		actionFile:  Required; File that will handle the upload. It can include query string variables to identify this file. Example: upload.cfm?id=15
		label: Label to put next to the control.
		fileTypes: extensions to accept, separated by semicolons. Example: *.jpg;*.png;*.gif
		fileDescription: Text to describe accepted files
		maxSize: maximum file size in Kb to upload. Default to no limit
		swf: name of the swf file that contains the io libraries. only needed if your swf is not in the same dir as your cfform
	
	Usage:
		This tag must be used with flashUploadInput tag.
		
		Example:
		default:
		<cf_flashUpload name="defaultFile" actionFile="upload.cfm">
			<cf_flashUploadInput />
		</cf_flashUpload>
		
		customized
		<cf_flashUpload label="Picture" name="myFile2" fileTypes="*.jpg;*.png;*.gif" fileDescription="Image files" actionFile="upload.cfm">
			<cf_flashUploadInput buttonStyle="corner-radius: 0;" inputStyle="fontWeight:bold" inputWidth="80" uploadButton="true" uploadButtonLabel="Upload Label" chooseButtonLabel="Choose file" progressBar="true" progressInfo="true" />
		</cf_flashUpload>

		View index file for more examples
		
		flashUploadInput Usage:
		Attributes:
			inputWidth: with of the text input where file name is shown
			buttonStyle: style applied to choose and upload buttons
			uploadButton:true/false, default true. Adds an upload button. If you set it false, you must put the generated variable called "theNameOfYourInput_uploadScript" in some other button ("theNameOfYourInput" is the name assigned in the flashUpload tag name attribute)
			progressBar: true/false default true. Adds a progress bar.
			progressInfo: true/false default true. Adds an output area to show progress info
			progressBarStyle: style of progress bar
			uploadButtonLabel: label of "Upload" button
			chooseButtonLabel: label of "File browse" button
			required: will make the file input required (it will validate if user just writes some text)
			message: validation failure message

--->

<cfparam name="attributes.fileTypes" default="*">
<cfparam name="attributes.fileDescription" default="All types">
<cfparam name="attributes.label" default="">
<cfparam name="attributes.maxSize" default="-1">
<cfparam name="attributes.swf" default="#application.url.farcry#/facade/fileUpload/fileUpload.swf">
<cfparam name="attributes.onComplete" default="">

<cfswitch expression="#ThisTag.ExecutionMode#">
<!--- Start tag processing --->
	<cfcase value="start">
		<!--- require name --->
		<cfif NOT structkeyexists(attributes,"name")>
			<cfthrow message="Name is a required attribute for cf_FlashUpload custom tag"/>
		</cfif>
		<cfif NOT structkeyexists(attributes,"actionFile")>
			<cfthrow message="actionFile is a required attribute for cf_FlashUpload custom tag"/>
		</cfif>
	</cfcase>
  </cfswitch>
  