<cfsetting showdebugoutput="false" />

<!--- Setup Defaults --->
<cfparam name="Form.Id" default="">
<cfparam name="Form.cmd" default="">
<cfparam name="Form.Check" default="">
<cfparam name="Form.Lang" default="en">

<!--- Spelling Engine: Aspell, Google --->
<cfset Engine = "Google">

<!--- Error checking --->
<cfif Form.Id IS "" OR Form.Cmd IS "">
	<cfset XMLOutput(Form.Id,Form.Cmd,"Error in SpellCheck Engine, missing arguemnts",True)>
</cfif>

<cfif Form.Check IS "">
	<!--- The input is blank, so there is really nothing to do! --->
	<cfset XMLOutput(Form.Id,Form.Cmd,"")>
</cfif>

<cftry>
	<cfset objSpellEngine = CreateOBject("component","Engines." & Engine)>
	
	<!--- 
		Process the possible commands, and run the corresponding function
		We should get back a Struct with "Error" and "Message".
		The message (if no error) should contain a space delimited list.
		
		I have noted that the javascript layer is rather inefficient.  Since most spelling engines will send
		you the word and the suggestions at the same time, it would be better for us to send both back to javascript 
		and have javascript cache the entire record, then when it wants the suggestion, it just looks up the word and gets 
		the suggestions from cache, without making another ajax call.
	 --->
	<cfswitch expression="#Form.Cmd#">
		<cfcase value="spell">
			<!--- Send ALL the text, get back a list of mispelled words --->
			<cfset Result = objSpellEngine.Spell(Form.Check,Form.Lang)>
		</cfcase>
		<cfcase value="suggest">
			<!--- Send the one mispelled word, and get back the suggestions --->
			<cfset Result = objSpellEngine.Suggest(Form.Check,Form.Lang)>
		</cfcase>
		<cfdefaultcase>
			<cfset Respond(XMLOutput(Form.Id,Form.Cmd,"Invalid Command: " & Form.Cmd,True))>
		</cfdefaultcase>
	</cfswitch>
	<cfset Respond(XMLOutput(Form.Id,Form.Cmd,Result.Message,Result.Error))>
	<cfcatch type="Any">
		<!--- Oops, and error occured, output to disk (for debug) and report --->
		<cffile action="WRITE" file="#ExpandPath(".")#\Error.txt" output="#cfcatch.Message##chr(10)##chr(13)##cfcatch.detail##chr(10)##chr(13)##cfcatch.StackTrace#">
		<cfset Respond(XMLOutput(Form.Id,Form.Cmd,"General Application Error",True))>
	</cfcatch>
</cftry>


<cffunction name="XMLOutput" output="No" returntype="String">
	<cfargument name="Id" required="Yes" type="string">
	<cfargument name="cmd" required="Yes" type="string">
	<cfargument name="Content" required="Yes" type="string">
	<cfargument name="Error" required="No" type="boolean" default="false">
	<cfset var XMLString = "">
	<cfset var ErrorString = "false">
	
	<cfif ARGUMENTS.Error>
		<cfset XMLString = "<res id=""#ARGUMENTS.Id#"" error=""true"" cmd=""#ARGUMENTS.cmd#"" msg=""#ARGUMENTS.Content#"" />">
	<cfelse>
		<cfset XMLString = "<res id=""#ARGUMENTS.Id#"" error=""#ErrorString#"" cmd=""#ARGUMENTS.cmd#"">#ARGUMENTS.Content#</res>">
	</cfif>
	
	<cfreturn XMLString>
</cffunction>

<cffunction name="Respond" output="Yes" returntype="void">
	<cfargument name="Content" required="Yes" type="string">
	<!--- The following must be on the same line, or else a new line is put before the XML declaration, which is invalid --->
	<cfcontent reset="True" type="text/xml; charset=utf-8"><?xml version="1.0" encoding="utf-8" ?>
	<cfoutput>#ARGUMENTS.Content#</cfoutput>
	<cfabort>
</cffunction>