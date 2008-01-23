<!--- We take our word list and send it to google, we get back XML that we parse and send back a word list --->
<cfcomponent output="False">
	<cffunction name="Spell" output="False" returntype="Struct">
		<cfargument name="Content" required="Yes" type="string">
		<cfargument name="Language" required="No" type="string" default="en">
		<cfset var BadWords = "">
		<cfset var Result = StructNew()>
		<cfset Result.Error = False>
		<cfset Result.Message = "">
		
		<cfset googleData = SendToGoogle(ARGUMENTS.Content,ARGUMENTS.Language)>
		<cfif googleData.Error>
			<cfset Result = googleData>
			<cfreturn Result>
		</cfif>
		
		<!--- 
			Example Output:
			<spellresult error="0" clipped="2" charschecked="98"><c o="39" l="7" s="1">editor	auditor	edit	effector	Edita</c><c o="59" l="9" s="1">instance	instances	instance's	instanced</c></spellresult>
			We go through all the children tags and gath the offset (o) and the length (l)
			We then use that to extract the original mispelled word from our content
		 --->
		
		<cfloop index="XMLChildrenIndex" from="1" to="#ArrayLen(googleData.Message.spellresult.XMLChildren)#">
			<cfset BadWords = ListAppend(BadWords, Mid(ARGUMENTS.Content,googleData.Message.spellresult.XMLChildren[XMLChildrenIndex].XmlAttributes.o+1,googleData.Message.spellresult.XMLChildren[XMLChildrenIndex].XmlAttributes.l)," ")>
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
		
		<cfset googleData = SendToGoogle(ARGUMENTS.Content,ARGUMENTS.Language)>
		<cfif googleData.Error>
			<cfset Result = googleData>
			<cfreturn Result>
		</cfif>
		<!--- 
			Example Output:
			<spellresult error="0" clipped="2" charschecked="98"><c o="39" l="7" s="1">editor	auditor	edit	effector	Edita</c></spellresult>
			Similar output, except just for 1 word.
			We go through the one child and gather the list of words (tab seperated)
		 --->
		
		<!--- Replace a TAB with a SPACE --->
		<cfset Result.Message = Replace(googleData.Message.spellresult.XMLChildren[1].XMLText,"	"," ","ALL")>
		
		<cfreturn Result>
	</cffunction>
	
	<cffunction name="SendToGoogle" output="False" returntype="Struct">
		<cfargument name="Content" required="Yes" type="string">
		<cfargument name="Language" required="Yes" type="string">
		<cfargument name="textalreadyclipped" required="No" type="boolean" default="False">
		<cfargument name="ignoredups" required="No" type="boolean" default="False">
		<cfargument name="ignoredigits" required="No" type="boolean" default="True">
		<cfargument name="ignoreallcaps" required="No" type="boolean" default="True">
		<cfset var xmlpacket = "">
		<cfset var Result = StructNew()>
		<cfset Result.Error = False>
		<cfset Result.Message = "">
		
		<!--- We make up our packet to send to google, and then do lots of error checking --->
		<cfsavecontent variable="xmlpacket"><?xml version="1.0"?><cfoutput><spellrequest textalreadyclipped="#iif(ARGUMENTS.textalreadyclipped,"0","1")#" ignoredups="#iif(ARGUMENTS.ignoredups,"0","1")#" ignoredigits="#iif(ARGUMENTS.ignoredigits,"0","1")#" ignoreallcaps="#iif(ARGUMENTS.ignoreallcaps,"0","1")#">#ARGUMENTS.Content#</spellrequest></cfoutput></cfsavecontent>
		<cftry>
			<cfhttp method="post" url="https://www.google.com/tbproxy/spell?lang=#ARGUMENTS.Language#" timeout="5">
			   <cfhttpparam value="#xmlpacket#" type="body">
			</cfhttp>
			<cfcatch type="any">
				<cfset Result.Error = True>
				<cfset Result.Message = "Failed to contact Google">
			</cfcatch>
		</cftry>
		<cfif cfhttp.filecontent IS "" OR cfhttp.filecontent IS "connection failure">
			<cfset Result.Error = True>
			<cfset Result.Message = "Invalid Response">
		<cfelse>
			<!--- Uncomment to debug --->
			<!--- <cffile action="WRITE" file="#ExpandPath(".")#\GoogleOutput.txt" output="#cfhttp.filecontent#"> --->
			<cfset Result.Message = xmlParse(cfhttp.filecontent)>
		</cfif>
		
		<cfreturn Result>
	</cffunction>
	
</cfcomponent>