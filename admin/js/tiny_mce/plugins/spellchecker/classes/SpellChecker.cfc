<!--- 
	@description ColdFusion port of SpellChecker.php
	@author Richard Davies
 --->
<cfcomponent name="SpellChecker" hint="" output="false">
	
	<!---
	  * FUNCTION: init
	  * Constructor.
	  * @param {Struct} config Configuration struct.
	  * @return component instance
	--->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor.">
		<cfargument name="config" type="struct" />
		<cfset this._config = Arguments.config />
		
		<cfreturn this />
	</cffunction>


	<!---
	  * FUNCTION: loopback
	  * Simple loopback function everything that gets in will be send back.
	  * @param $args.. Arguments.
	  * @return {Array} Array of all input arguments. 
	--->
	<cffunction name="loopback" access="package" returntype="any" output="false" hint="Simple loopback function everything that gets in will be send back.">
		<cfreturn Arguments />
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

		<cfreturn words />
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

		<cfreturn ArrayNew(1) />
	</cffunction>


	<!---
	 * Throws an error message back to the user. This will stop all execution.
	 *
	 * @param {String} $str Message to send back to user.
	--->
	<cffunction name="throwError" access="package" returntype="void" output="true" hint="Throws an error message back to the user. This will stop all execution.">
		<cfargument name="str" type="string" hint="Message to send back to user." />
		
		<cfset Arguments.str = ReReplace(Arguments.str, "(['""\\])", "\\\1", "all") />
		<cfoutput>{"result":"","id":"","error":{"errstr":"#Arguments.str#","errfile":"","errline":"","errcontext":"","level":"FATAL"}}</cfoutput>
		
		<cfabort />
	</cffunction>
	

	<cffunction name="preg_match_all" access="package" returntype="array" output="false" hint="Clone of PHP preg_match_all function.">
		<cfargument name="pattern" type="string" hint="Regular expression to match on." />
		<cfargument name="subject" type="string" hint="String to search for matches." />
		
		<cfset var Local = StructNew() />
		
		<!--- Do initial RE match --->
		<cfset Local.match = ReFindNoCase(Arguments.pattern, Arguments.subject, 1, true) />
		<!--- Determine the number of additional group matches found in RE --->
		<cfset Local.numGroups = ArrayLen(Local.match.pos) />
		<!--- Create multi-dimensional array to hold matched substrings --->
		<cfset Local.matches = ArrayNew(2) />
		
		<!--- Use length and position of RE matches to create array elements --->
		<cfset Local.numMatches = 0 />
		<cfloop condition="Local.match.pos[1] neq 0">
			<cfset Local.numMatches = Local.numMatches + 1 />
			
			<!--- Each RE group is an additional element in the 2nd dimention of the array --->
			<cfloop index="Local.i" from="1" to="#Local.numGroups#">
				<!--- Extract matched substring for each group match --->
				<cfset Local.matches[Local.numMatches][Local.i] = Mid(Arguments.subject, Local.match.pos[Local.i], Local.match.len[Local.i]) />
			</cfloop>
			
			<!--- Calculate new start position and search for another RE match --->
			<cfset Local.startPos = Local.match.pos[1] + Local.match.len[1] />
			<cfset Local.match = ReFindNoCase(Arguments.pattern, Arguments.subject, Local.startPos, true) />
		</cfloop>
		
		<cfreturn Local.matches />
	</cffunction>

</cfcomponent>
