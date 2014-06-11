<!---
 * Diff Match and Patch
 *
 * Copyright 2006 Google Inc.
 * http://code.google.com/p/google-diff-match-patch/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @author fraser@google.com (Neil Fraser)
 * on Jan 11, 2012
 *
 *
 * ColdFusion wrapper class for Diff, Match and Patch Library
 * Marco Spescha, @maertsch
 * on Mar 07, 2012
 *
--->
<cfcomponent>
	
	<cffunction name="init" access="public" returntype="struct" output="false">
		<cfargument name="javaloader" required="false" />
		
		<!--- load java-class with javaloader if not already provided --->
		<cfif not isDefined('arguments.javaloader')>
			<cfset this.javaloader = createObject("component", "farcry.core.packages.farcry.javaloader.JavaLoader").init(listtoarray(
				expandPath('/farcry/core/packages/lib/diff/diff_match_patch-current.jar')
			)) />
		<cfelse>
			<cfset this.javaloader = arguments.javaloader />
		</cfif>
		
		<!--- get and save diff-match-patch instance --->
		<cfset this.dmp = getDiffMatchPatchInstance() />
		
		<cfreturn this />
	</cffunction>
	
	
	<!--- Private --->
	
	<cffunction name="getDiffMatchPatchInstance" access="private" returntype="any" output="false">
		
		<cfreturn this.javaloader.create('name.fraser.neil.plaintext.diff_match_patch').init() />
	</cffunction>
	
	
	<!--- Public --->
	
	<cffunction name="diff_main" access="public" returntype="array" output="false">
		<cfargument name="text1" type="string" required="true" />
		<cfargument name="text2" type="string" required="true" />
		
		<cfreturn this.dmp.diff_main(javacast("string",arguments.text1),javacast("string",arguments.text2)) />
	</cffunction>
	
	<cffunction name="diff_cleanupSemantic" access="public" returntype="void" output="false">
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.diff_cleanupSemantic(arguments.diffs) />
	</cffunction>
	
	<cffunction name="diff_cleanupEfficiency" access="public" returntype="void" output="false">
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.diff_cleanupEfficiency(arguments.diffs) />
	</cffunction>
	
	<cffunction name="diff_levenshtein" access="public" returntype="void" output="false">
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.diff_levenshtein(arguments.diffs) />
	</cffunction>
	
	<cffunction name="diff_prettyHtml" access="public" returntype="void" output="false">
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.diff_prettyHtml(arguments.diffs) />
	</cffunction>
	
	<cffunction name="match_main" access="public" returntype="void" output="false">
		<cfargument name="text" required="true" />
		<cfargument name="pattern" required="true" />
		<cfargument name="loc" required="true" />
		
		<cfreturn this.dmp.match_main(arguments.text,arguments.pattern,arguments.loc) />
	</cffunction>
	
	<cffunction name="patch_make_text" access="public" returntype="void" output="false">
		<cfargument name="text1" type="string" required="true" />
		<cfargument name="text2" type="string" required="true" />
		
		<cfreturn this.dmp.patch_make(arguments.text1,arguments.text2) />
	</cffunction>
	
	<cffunction name="patch_make_diffs" access="public" returntype="void" output="false">
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.patch_make(arguments.diffs) />
	</cffunction>
	
	<cffunction name="patch_make_text_diffs" access="public" returntype="void" output="false">
		<cfargument name="text1" required="true" />
		<cfargument name="diffs" required="true" />
		
		<cfreturn this.dmp.patch_make(arguments.text1, arguments.diffs) />
	</cffunction>
	
	<cffunction name="patch_toText" access="public" returntype="void" output="false">
		<cfargument name="patches" required="true" />
		
		<cfreturn this.dmp.patch_toText(arguments.patches) />
	</cffunction>
	
	<cffunction name="patch_fromText" access="public" returntype="void" output="false">
		<cfargument name="text" required="true" />
		
		<cfreturn this.dmp.patch_fromText(arguments.text) />
	</cffunction>
	
	<cffunction name="patch_apply" access="public" returntype="void" output="false">
		<cfargument name="patches" required="true" />
		<cfargument name="text1" required="true" />
		
		<cfreturn this.dmp.patch_apply(arguments.patches, arguments.text1) />
	</cffunction>
	
</cfcomponent>