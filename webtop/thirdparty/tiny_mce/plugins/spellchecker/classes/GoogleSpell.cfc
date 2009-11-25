<!--- 
	@description ColdFusion port of GoogleSpell.php
	@author Richard Davies
 --->
<cfcomponent name="GoogleSpell" extends="SpellChecker" hint="Uses Google spellchecker API." output="false">

	<!---
	  * FUNCTION: init
	  * Constructor.
	  * @param {Struct} config Configuration struct.
	  * @return component instance
	--->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor.">
		<cfargument name="config" type="struct" />
		<cfset Super.init(config) />
		
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
		
		<cfset Local.wordstr = ArrayToList(Arguments.words, " ") />
		<cfset Local.matches = getMatches(Arguments.lang, Local.wordstr) />
		
		<cfset Local.words = ArrayNew(1) />
		<cfloop index="Local.i" from="1" to="#ArrayLen(Local.matches)#">
			<!--- Position indexes returned from Google are 0-based; Add one because CF functions are 1-based --->
			<cfset Local.words[Local.i] = Mid(Local.wordstr, Local.matches[Local.i][2]+1, Local.matches[Local.i][3]) />
		</cfloop>
		
		<cfreturn Local.words />
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
		<cfset Local.sug = ArrayNew(1) />
		<cfset Local.matches = getMatches(Arguments.lang, Arguments.word) />
		
		<cfif ArrayLen(Local.matches)>
			<cfset Local.sug = ListToArray(Local.matches[1][5], Chr(9)) />	<!--- Chr(9) = tab character --->
		</cfif>
		
		<cfreturn Local.sug />
	</cffunction>


	<cffunction name="getMatches" access="private" returntype="array" output="false" hint="">
		<cfargument name="lang" type="string" hint="Language code like sv or en." />
		<cfargument name="str" type="string" hint="String of words to spell check." />
		
		<cfset var Local = StructNew() />
		<cfset Local.url = "https://www.google.com/tbproxy/spell?lang=#Arguments.lang#&hl=en" />
		<cfset Local.ignoreDigits = this._config.GoogleSpell.ignoreDigits />
		<cfset Local.ignoreAllCaps = this._config.GoogleSpell.ignoreAllCaps />
		
		<cfxml variable="Local.xml">
			<cfoutput>
			<?xml version="1.0" encoding="utf-8" ?>
			<spellrequest textalreadyclipped="0" ignoredups="0" ignoredigits="#Local.ignoreDigits#" ignoreallcaps="#Local.ignoreAllCaps#"><text>#XmlFormat(Arguments.str)#</text></spellrequest>
			</cfoutput>
		</cfxml>
		
		<cftry>
			<cfhttp url="#Local.url#" method="post" result="Local.response" timeout="5" proxyServer="#this._config.cfhttp.proxyServer#" proxyPort="#this._config.cfhttp.proxyPort#" proxyUser="#this._config.cfhttp.proxyUser#" proxyPassword="#this._config.cfhttp.proxyPassword#">
				<cfhttpparam type="body" value="#Local.xml#" />
			</cfhttp>
			
			<cfcatch>
				<cfset Local.errorMsg = "The following error occurred while accessing the Google Spellchecker API: " />
				<cfset Local.errorMsg = Local.errorMsg & cfcatch.Message />
				<cfset throwError(Local.errorMsg) />
			</cfcatch>
		</cftry>

		<!--- Grab and parse content --->
		<cfset Local.matches = ArrayNew(2) />
		<cfset Local.matchRE = "<c o=""([^""]*)"" l=""([^""]*)"" s=""([^""]*)"">([^<]*)<\/c>" />
		<cfset Local.matches = preg_match_all(Local.matchRE, Local.response.FileContent) />
		
		<cfreturn Local.matches />
	</cffunction>

</cfcomponent>
