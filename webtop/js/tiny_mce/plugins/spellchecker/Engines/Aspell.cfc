<!--- We take our word list and send it through a command line to Aspell, we get back Text that we parse and send back a word list --->
<!--- For more info on Aspell see: http://aspell.sourceforge.net/ --->

<cfcomponent output="False">
	<cfset Init()>
	
	<cffunction name="Init" output="False">
		<!--- This is the system settings --->
		<cfset THIS.tempFolder = "c:\progra~1\aspell\tmp">
		<cfset THIS.apsell_dir = "c:\progra~1\aspell\bin">
		<cfset THIS.CMDFile = "C:\WINNT\SYSTEM32\cmd.exe">
	</cffunction>

	<cffunction name="Spell" output="False" returntype="Struct">
		<cfargument name="Content" required="Yes" type="string">
		<cfargument name="Language" required="No" type="string" default="en">
		<cfset var BadWords = "">
		<cfset var ArrayIndex = "">
		<cfset var Result = StructNew()>
		<cfset Result.Error = False>
		<cfset Result.Message = "">
		
		<cfset AspellData = SendToAspell(ARGUMENTS.Content,ARGUMENTS.Language)>
		<cfif AspellData.Error>
			<cfset Result = AspellData>
			<cfreturn Result>
		</cfif>

		<!--- Loop through the array and list all out BadWords --->
		<cfloop index="ArrayIndex" from="1" to="#ArrayLen(AspellData.Message)#">
			<cfset BadWords = ListAppend(BadWords,AspellData.Message[ArrayIndex].Word," ")>
		</cfloop>
		<cfset Result.Message = BadWords>
		
		<cfreturn Result>
	</cffunction>
	
	<cffunction name="Suggest" output="False" returntype="Struct">
		<cfargument name="Content" required="Yes" type="string">
		<cfargument name="Language" required="No" type="string" default="en">
		<cfset var Result = StructNew()>
		<cfset Result.Error = False>
		<cfset Result.Message = "">
		
		<cfset AspellData = SendToAspell(ARGUMENTS.Content,ARGUMENTS.Language)>
		<cfif AspellData.Error>
			<cfset Result = AspellData>
			<cfreturn Result>
		</cfif>
		
		<!--- Remove the commas --->
		<cfset Result.Message = Replace(AspellData.Message[1].Suggestions,",","","ALL")>
		
		<cfreturn Result>
	</cffunction>
	
	<cffunction name="SendToAspell" output="False" returntype="Struct">
		<cfargument name="Content" required="Yes" type="string">
		<cfargument name="Language" required="Yes" type="string">
		<cfset var AspellInput = "">
		<cfset var ContentLine = "">
		<cfset var tempfile = "spell_#randrange(1,1000)#">
		<cfset var SpellingOutput = "">
		<cfset var SpellResult = ArrayNew(1)>
		<cfset var WordLine = "">
		<cfset var Result = StructNew()>
		<cfset Result.Error = False>
		<cfset Result.Message = "">
		
		<!--- Takes care of those pesky smart quotes from MS apps, replaces them with regular quotes --->
		<cfset ARGUMENTS.Content = replacelist(ARGUMENTS.Content,"%u201C,%u201D","%22,%22")> 
		<cfset ARGUMENTS.Content = urlDecode(ARGUMENTS.Content)>
		
		<!--- need to escape special javascript characters such as ' --->
		<cfset ARGUMENTS.Content = replace(ARGUMENTS.Content,"'","\'","All")>
		<cfset ARGUMENTS.Content = replace(ARGUMENTS.Content,"""","\""","All")>
		
		<!--- We need to prepend each line with "^", so that Aspell doesn't try to process commands --->
		<cfloop list="#ARGUMENTS.Content#" index="ContentLine" delimiters="#chr(10)##chr(13)#">
			<cfset AspellInput = AspellInput & "^" & ContentLine & "#chr(10)##chr(13)#">
		</cfloop>
		<!--- 
			This is the interface to Aspell, and here is how it works:
			Through cfexecute, we can't send in the content as standard in, so the we have to write a 
			temp file, then pipe that into Aspell, we then delete the file when we are done
			Aspell Options:
			 --lang: Name of dictionary
			 -a: pipe mode compatibility
		 ---> 
		<cftry>
			<cffile action="Write" file="#THIS.tempFolder#\#tempfile#" output="#AspellInput#">
			<cfexecute name="#THIS.CMDFile#" arguments="/c type #THIS.tempFolder#\#tempfile# | #THIS.apsell_dir#\aspell --lang=#ARGUMENTS.Language# -a" timeout="100" variable="SpellingOutput"></cfexecute>
			<cffile action="DELETE" file="#THIS.tempFolder#\#tempfile#">
			<cfcatch type="any">
				<!--- If any error occurs, we just dump! --->
				<cffile action="WRITE" file="#ExpandPath(".")#\Error.txt" output="#cfcatch.Message##chr(10)##chr(13)##cfcatch.detail##chr(10)##chr(13)##cfcatch.StackTrace#">
				<cfset Result.Error = True>
				<cfset Result.Message = "Error Sending Command">
				<cfreturn Result>
			</cfcatch>
		</cftry>
		
		<cfif Trim(SpellingOutput) IS "">
			<!--- An empty response is no good --->
			<cfset Result.Error = True>
			<cfset Result.Message = "Invalid Response">
			<cfreturn Result>
		</cfif>
		<!--- Uncomment to debug --->
		<!--- <cffile action="WRITE" file="#ExpandPath(".")#\AspellOutput.txt" output="#SpellingOutput#"> --->
		<!--- 
			Example Output:
			@(#) International Ispell Version 3.1.20 (but really Aspell 0.50.3)
			*
			*
			*
			*
			*
			*
			*
			*
			& efditor 16 40: editor, auditor, editors, edit, effector, Edita, edited, effort, effete, EDT, EFT, erudite, idiot, mediator, editor's, radiator
			*
			*
			& instancez 4 60: instances, instance, instance's, instanced
			*
			*
			*
			*
			*
			*
		 --->
		
		<!--- removes the first line of the aspell output "@(#) International Ispell Version 3.1.20 (but really Aspell 0.50.3)" --->
		<cfset SpellingOutput = ListDeleteAt(SpellingOutput,1,"#chr(10)##chr(13)#")>
		
		<!--- Loop through the result and find the lines we want, and break them up into usable bits --->
		<cfloop list="#SpellingOutput#" index="WordLine" delimiters="#chr(10)##chr(13)#">
			<cfif find("&",WordLine) OR find("##",WordLine)>
				<!--- word that misspelled --->
				<cfset SpellResult[ArrayLen(SpellResult)+1] = StructNew()>
				<cfset SpellResult[ArrayLen(SpellResult)].Word = listGetAt(WordLine,"2"," ")>
				<cfset SpellResult[ArrayLen(SpellResult)].Suggestions = mid(WordLine,(WordLine.lastindexOf(':') + 2),(len(WordLine) - (WordLine.lastindexOf(':') + 2)))>
			</cfif>			
		</cfloop>
		
		<cfset Result.Message = SpellResult>
		
		<cfreturn Result>
	</cffunction>
	
</cfcomponent>