<!--- 
	@description ColdFusion port of PSpellShell.php
	@author Richard Davies
 --->
<cfcomponent name="PSpellShell" extends="SpellChecker" hint="Uses Pspell/Aspell library." output="false">

	<!---
	  * FUNCTION: init
	  * Constructor.
	  * @param {Struct} config Configuration struct.
	  * @return component instance
	--->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor.">
		<cfargument name="config" type="struct" />
		<cfset Super.init(config) />

		<!--- Determine location of cmd.exe if running on a Windows server --->
		<cfif ReFindNoCase("win", Server.OS.Name)>
			<cfif FileExists(this._config.PSpellShell.cmd)>
				<cfset Variables.comspec = this._config.PSpellShell.cmd />
			<cfelseif FileExists("c:\windows\system32\cmd.exe")>
				<cfset Variables.comspec = "c:\windows\system32\cmd.exe" />
			<cfelseif FileExists("c:\winnt\system32\cmd.exe")>
				<cfset Variables.comspec = "c:\winnt\system32\cmd.exe" />
			<cfelse>
				<cfset throwError("Unable to locate cmd.exe! Check 'PSpellShell.cmd' config setting.") />
			</cfif>
		</cfif>
		
		<cfreturn this />
	</cffunction>


	<!---
	 * Spellchecks an array of words.
	 *
	 * @param {String} $lang Language code like sv or en.
	 * @param {Array} $words Array of words to spellcheck.
	 * @return {Array} Array of misspelled words.
	--->
	<cffunction name="checkWords" access="public" returntype="array" output="false" hint="Spellchecks an array of words.">
		<cfargument name="lang" type="string" hint="Language code like sv or en." />
		<cfargument name="words" type="array" hint="Array of words to spellcheck." />

		<cfset var Local = StructNew() />
		<cfset Local.cmd = getCMD(Arguments.lang) />
		<cfset Local.nl = Chr(13) & Chr(10) />
		
		<cfif FileExists(Variables.tmpfile)>
			<cffile action="write" file="#Variables.tmpfile#" output="!#Local.nl#^#ArrayToList(Arguments.words, '#Local.nl#^')#" />
		<cfelse>
			<cfset throwError("PSpell support was not found.") />
		</cfif>
		
		<cfexecute name="#Local.cmd.exec#" arguments="#Local.cmd.args#" variable="Local.data" timeout="5" />
		<cffile action="delete" file="#Variables.tmpfile#" />
		
		<cfset Local.matches = preg_match_all("& ([^ ]+) ", Local.data) />

		<cfset Local.dataArr = ArrayNew(1) />
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.matches)#">
			<cfset ArrayAppend(Local.dataArr, Local.matches[Local.i][2]) />
		</cfloop>
		
		<cfreturn Local.dataArr />
	</cffunction>


	<!---
	 * Returns suggestions for a specific word.
	 *
	 * @param {String} $lang Language code like sv or en.
	 * @param {String} $word Specific word to get suggestions for.
	 * @return {Array} Array of suggestions for the specified word.
	--->
	<cffunction name="getSuggestions" access="public" returntype="array" output="false" hint="Returns suggestions for a specific word.">
		<cfargument name="lang" type="string" hint="Language code like sv or en." />
		<cfargument name="word" type="string" hint="Specific word to get suggestions for." />
		
		<cfset var Local = StructNew() />
		<cfset Local.cmd = getCMD(Arguments.lang) />
		<cfset Local.nl = Chr(13) & Chr(10) />

		<cfif FileExists(Variables.tmpfile)>
			<cffile action="write" file="#Variables.tmpfile#" output="!#Local.nl#^#Arguments.word##Local.nl#" />
		<cfelse>
			<cfset throwError("Error opening tmp file.") />
		</cfif>

		<cfexecute name="#Local.cmd.exec#" arguments="#Local.cmd.args#" variable="Local.data" timeout="5" />
		<cffile action="delete" file="#Variables.tmpfile#" />
		
		<cfset Local.matches = preg_match_all("& [^:]+: (.*)", Local.data) />
		<cfset Local.suggestions = Trim(Local.matches[1][2]) />
		<cfset Local.suggestions = Replace(Local.suggestions, ", ", ",", "all") />
		
		<cfreturn ListToArray(Local.suggestions) />
	</cffunction>


	<cffunction name="getCMD" access="private" returntype="struct" output="false" hint="">
		<cfargument name="lang" type="string" hint="Language code." />
		
		<cfset var Local = StructNew() />
		<cfset Local.lang = validateLang(Arguments.lang) />

		<cfset Variables.tmpfile = GetTempFile(this._config.PSpellShell.tmp, "tinyspell") />
		
		<cfif ReFindNoCase("win", Server.OS.Name)>
			<cfset Local.cmd.exec = Variables.comspec />
			<cfset Local.cmd.args = "/c ""#this._config.PSpellShell.aspell#"" -a --lang=#Local.lang# --encoding=utf-8 -H < #Variables.tmpfile# 2>&1" />
		<cfelse>
			<cfset Local.cmd.exec = "cat" />
			<cfset Local.cmd.args = "#Variables.tmpfile# | #this._config.PSpellShell.aspell# -a --encoding=utf-8 -H --lang=#Local.lang#" />
		</cfif>
		
		<cfreturn Local.cmd />
	</cffunction>


	<!--- 
	 * Lang is user data used in a command shell argument. Validate it to avoid potential security issues.
	 *
	 * @param {String} $lang Language code like sv or en.
	 * @return {String} "Clean" language code
	--->
	<cffunction name="validateLang" access="private" returntype="string" output="false" hint="Scrub lang variable of any invalid characters.">
		<cfargument name="lang" type="string" hint="Language code." />
		
		<!--- If lang isn't a two letter string, default to English --->
		<cfif not isValid("regex", Arguments.lang, "^\w{2}$")>
			<cfset Arguments.lang = "en">
		</cfif>
		
		<cfreturn Arguments.lang />
	</cffunction>
	
</cfcomponent>
