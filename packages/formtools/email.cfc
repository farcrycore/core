<cfcomponent extends="field" name="email" displayname="email" hint="Field component for Email types"> 
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.email" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#HTMLEditFormat(arguments.stMetadata.value)#" class="textInput email #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display. Activates mailto if recognised.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfsavecontent variable="html">
			<cfoutput>#ActivateURL(arguments.stMetadata.value)#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
		<cfif stResult.bSuccess and len(stFieldPost.Value) and not isvalid("email",stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is not a valid email address.") />
		</cfif>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

	<cfscript>
	/**
	 * This function takes URLs in a text string and turns them into links.
	 * Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
	 * Version 3 Updated to allow for ;
	 * 
	 * @param string 	 Text to parse. (Required)
	 * @param target 	 Optional target for links. Defaults to "". (Optional)
	 * @param paragraph 	 Optionally add paragraphFormat to returned string. (Optional)
	 * @return Returns a string. 
	 * @author Joel Mueller (lucas@thebitbucket.netjmueller@swiftk.com) 
	 * @version 3, August 11, 2004 
	 */
	function ActivateURL(string) {
		var nextMatch = 1;
		var objMatch = "";
		var outstring = "";
		var thisURL = "";
		var thisLink = "";
		var	target = IIf(arrayLen(arguments) gte 2, "arguments[2]", DE(""));
		var paragraph = IIf(arrayLen(arguments) gte 3, "arguments[3]", DE("false"));
		
		do {
			objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", string, nextMatch, true);
			if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
				outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
			} else {
				outString = outString & Mid(String, nextMatch, Len(string));
			}
			nextMatch = objMatch.pos[1] + objMatch.len[1];
			if (ArrayLen(objMatch.pos) GT 1) {
				// If the preceding character is an @, assume this is an e-mail address
				// (for addresses like admin@ftp.cdrom.com)
				if (Compare(Mid(String, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
					thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
					thisLink = "<A HREF=""";
					switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
						case "www.": {
							thisLink = thisLink & "http://";
							break;
						}
						case "ftp.": {
							thisLink = thisLink & "ftp://";
							break;
						}
					}
					thisLink = thisLink & thisURL & """";
					if (Len(Target) GT 0) {
						thisLink = thisLink & " TARGET=""" & Target & """";
					}
					thisLink = thisLink & ">" & thisURL & "</A>";
					outString = outString & thisLink;
					// String = Replace(String, thisURL, thisLink);
					// nextMatch = nextMatch + Len(thisURL);
				} else {
					outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
				}
			}
		} while (nextMatch GT 0);
			
		// Now turn e-mail addresses into mailto: links.
		outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
			
		if (paragraph) {
			outString = ParagraphFormat(outString);
		}
		return outString;
	}
	</cfscript>

</cfcomponent> 

