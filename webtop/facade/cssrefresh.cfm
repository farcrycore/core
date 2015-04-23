<cfsetting enablecfoutputonly="true" />

<cfset aCurrentStylesheets = deserializejson(form.stylesheets) />
<cfset aNewStylesheets = arraynew(1) />

<cfloop from="1" to="#arraylen(aCurrentStylesheets)#" index="i">
	<cfset st = structnew() />
	<cfset st["id"] = aCurrentStylesheets[i].id />
	
	<cfif refindnocase("^https?://",aCurrentStylesheets[i].href)>
		<cfset st["href"] = aCurrentStylesheets[i].href />
	<cfelseif findnocase(application.url.cache,aCurrentStylesheets[i].href)>
		<cfset hashID = listrest(aCurrentStylesheets[i].id,"-") />
		
		<cfif structkeyexists(application.fc.stCSSLibraries,hashID) and structkeyexists(application.fc.stCSSLibraries[hashID],"lFullFilebaseHREFs") and len(application.fc.stCSSLibraries[hashID].lFullFilebaseHREFs)>
			<cfset stCSS = application.fc.stCSSLibraries[hashID] />
			
			<cfset latest = createdatetime(1970,1,1,1,1,1) />
			<cfloop list="#stCSS.lFullFilebaseHREFs#" index="thisfile">
				<cfset stAttr = getFileInfo(expandpath(thisfile)) />
				<cfif datecompare(latest,stAttr.lastmodified) lt 0>
					<cfset latest = stAttr.lastmodified />
				</cfif>
			</cfloop>
			
			<cfif not structkeyexists(stCSS,"modified") or datecompare(stCSS.modified,latest) lt 0>
				<cfset stCSS.modified = latest />
				<cfset stCSS.sCacheFileName = application.fc.utils.combine(	id=stCSS.id,
																			files=stCSS.lFullFilebaseHREFs,
																			type="css",
																			prepend=stCSS.prepend,
																			append=stCSS.append) />
			</cfif>
			
			<cfset st["href"] = "#application.url.cache#/#stCSS.sCacheFileName#" />
		<cfelse>
			<cfset st["href"] = aCurrentStylesheets[i].href />
		</cfif>
		<cfset arrayappend(aNewStylesheets,st) />
	<cfelse>
		<cfif structKeyExists(aCurrentStylesheets[i], "href") AND fileExists(expandPath(listfirst(aCurrentStylesheets[i].href,".")))>
			<cfset stAttr = getFileInfo(expandPath(listfirst(aCurrentStylesheets[i].href,"."))) />
			<cfif refindnocase("(\?|&)modified=",aCurrentStylesheets[i].href)>
				<cfset st["href"] = rereplacenocase(aCurrentStylesheets[i].href,"(\?|&)modified=[^&]+","\1modified=#dateformat(stAttr.lastmodified,'yyyymmdd')##timeformat(stAttr.lastmodified,'HHmmss')#") />
			<cfelseif find("?",aCurrentStylesheets[i].href)>
				<cfset st["href"] = aCurrentStylesheets[i].href & "&modified=#dateformat(stAttr.lastmodified,'yyyymmdd')##timeformat(stAttr.lastmodified,'HHmmss')#" />
			<cfelse>
				<cfset st["href"] = aCurrentStylesheets[i].href & "?modified=#dateformat(stAttr.lastmodified,'yyyymmdd')##timeformat(stAttr.lastmodified,'HHmmss')#" />
			</cfif>
			<cfset arrayappend(aNewStylesheets,st) />
		</cfif>
	</cfif>
</cfloop>


<cfcontent type="text/json" variable="#ToBinary( ToBase64( serializeJSON(aNewStylesheets) ) )#" reset="Yes" />

<cfsetting enablecfoutputonly="false" />