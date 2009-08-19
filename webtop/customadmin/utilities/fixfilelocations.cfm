<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Fix file locations --->
<!--- @@description: Files are stored in a secure directory or a public directory depending on their security. This utility finds files that are not in the correct location and moves them. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset stWrong = structnew() />
<cfset wrong = 0 />

<cfloop collection="#application.stCOAPI#" item="thistype">
	<cfif listcontains("type,rule",application.stCOAPI[thistype].class)>
		<cfloop collection="#application.stCOAPI[thistype].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#thistype#.stProps.#thisprop#.metadata.ftType") and application.stCOAPI[thistype].stProps[thisprop].metadata.ftType eq "file">
				<cfparam name="stWrong[thistype]" default="#structnew()#" />
				<cfparam name="stWrong[thistype][thisprop]" default="#querynew('objectid,label,filename,shouldbe')#" />
				<cfset o = application.fapi.getContentType(typename=thistype) />
				<cfquery datasource="#application.dsn#" name="q">
					select		objectid,label,#thisprop#
					from		#application.dbowner##thistype#
					where		#thisprop#<>''
				</cfquery>
				
				<cfloop query="q">
					<cfset stLocation = o.getFileLocation(objectid=q.objectid,typename=thistype,fieldname=thisprop) />
					<cfif structkeyexists(stLocation,"isCorrectLocation") and not stLocation.isCorrectLocation>
						<cfset queryaddrow(stWrong[thistype][thisprop]) />
						<cfset querysetcell(stWrong[thistype][thisprop],"objectid",q.objectid) />
						<cfset querysetcell(stWrong[thistype][thisprop],"label",q.label) />
						<cfset querysetcell(stWrong[thistype][thisprop],"filename",listlast(q[thisprop][q.currentrow],"\/")) />
						<cfset querysetcell(stWrong[thistype][thisprop],"shouldbe",stLocation.locationShouldBe) />
					</cfif>
				</cfloop>
				
				<cfset wrong = wrong + stWrong[thistype][thisprop].recordcount />
			</cfif>
		</cfloop>
	</cfif>
</cfloop>

<cfset message = "" />
<ft:processForm action="Fix files">
	<cfloop collection="#stWrong#" item="thistype">
		<cfloop collection="#stWrong[thistype]#" item="thisprop">
			<cfloop query="stWrong.#thistype#.#thisprop#">
				<cfset aVars = arraynew(1) />
				<cfset aVars[1] = label />
				<cfset aVars[2] = filename />
				<cfset aVars[3] = thistype />
				<cfset aVars[4] = thisprop />
				
				<cfif shouldbe eq "public">
					<cfset application.formtools.file.oFactory.moveToPublic(objectid=objectid,typename=thistype,stMetadata=application.stCOAPI[thistype].stProps[thisprop].metadata) />
					<cfset message = message & application.fapi.getResource("webtop.utilities.fixfilelocations.topublic@text","'{2}' ({3}) moved to public directory<br />","",aVars) />
				<cfelse>
					<cfset application.formtools.file.oFactory.moveToSecure(objectid=objectid,typename=thistype,stMetadata=application.stCOAPI[thistype].stProps[thisprop].metadata) />
					<cfset message = message & application.fapi.getResource("webtop.utilities.fixfilelocations.tosecure@text","'{2}' ({3}) moved to secure directory<br />","",aVars) />
				</cfif>
			</cfloop>
		</cfloop>
	</cfloop>
</ft:processForm>

<admin:header />

<cfoutput><h1>#application.fapi.getResource("webtop.utilities.fixfilelocations@title","Fix file locations")#</h1></cfoutput>
<admin:resource key="webtop.utilities.fixfilelocations.explanation@text"><cfoutput>
	<p>FarCry 5.2 introduced a number of CDN features:</p>
	<ul>
		<li>approved public files are now streamed directly from the web server instead of through ColdFusion, which improves performance significantly</li>
		<li>draft and secured files are stored in a secure directory and will only be streamed to the user if they have permission</li>
	</ul>
	<p>In established applications there will be many files that are not in correct place. Some draft files will be in the public directory. While these files will be served correctly, they should still be migrated to the correct location.</p>
</cfoutput></admin:resource>

<cfif len(message)>
	<cfoutput><p class="success">#message#</p></cfoutput>
<cfelseif wrong>
	<admin:resource key="webtop.utilities.fixfilelocations.wrongfiles@text" variables="#wrong#"><cfoutput>
		<p class="error">This application has {1} file/s in incorrect locations.</p>
	</cfoutput></admin:resource>
	
	<ft:form><ft:button value="Fix files" /></ft:form>
<cfelse>
	<admin:resource key="webtop.utilities.fixfilelocations.nowrongfiles@text" variables="#wrong#"><cfoutput>
		<p class="success">This application has no files in incorrect locations.</p>
	</cfoutput></admin:resource>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />