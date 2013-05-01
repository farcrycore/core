<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Fix file locations --->
<!--- @@description: Files are stored in a secure directory or a public directory depending on their security. This utility finds files that are not in the correct location and moves them. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset qWrong = querynew("typename,property,objectid,label,filename,currentlocation,correctlocation") />

<cfloop collection="#application.stCOAPI#" item="thistype">
	<cfif listcontains("type,rule",application.stCOAPI[thistype].class)>
		<cfloop collection="#application.stCOAPI[thistype].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#thistype#.stProps.#thisprop#.metadata.ftType") and application.stCOAPI[thistype].stProps[thisprop].metadata.ftType eq "file">
				<cfset o = application.fapi.getContentType(typename=thistype) />
				<cfquery datasource="#application.dsn#" name="q">
					select		objectid,label,#thisprop#
					from		#application.dbowner##thistype#
					where		#thisprop#<>''
				</cfquery>
				
				<cfloop query="q">
					<cfset stCheck = application.formtools.file.oFactory.checkFileLocation(objectid=q.objectid,typename=thistype,stMetadata=application.stCOAPI[thistype].stProps[thisprop].metadata) />
					<cfif structkeyexists(stLocation,"correct") and not stLocation.correct>
						<cfset queryaddrow(qWrong) />
						<cfset querysetcell(qWrong,"typename",thistype) />
						<cfset querysetcell(qWrong,"property",thisprop) />
						<cfset querysetcell(qWrong,"objectid",q.objectid) />
						<cfset querysetcell(qWrong,"label",q.label) />
						<cfset querysetcell(qWrong,"filename",listlast(q[thisprop][q.currentrow],"\/")) />
						<cfset querysetcell(qWrong,"currentlocation",stLocation.currentlocation) />
						<cfset querysetcell(qWrong,"correctlocation",stLocation.correctlocation) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cfif>
</cfloop>

<cfset message = "" />
<ft:processForm action="Fix files">
	<cfloop query="qWrong">
		<cfset aVars = arraynew(1) />
		<cfset aVars[1] = qWrong.label />
		<cfset aVars[2] = qWrong.filename />
		<cfset aVars[3] = qWrong.thistype />
		<cfset aVars[4] = qWrong.thisprop />
		
		<cfset application.fc.lib.file.ioMoveFile(source_location=qWrong.currentlocation,source_file=qWrong.filename,dest_location=qWrong.correctlocation) />
		
		<cfif qWrong.correctlocation eq "publicfiles">
			<cfset message = message & application.fapi.getResource("webtop.utilities.fixfilelocations.topublic@text","'{2}' ({3}) moved to public directory<br />","",aVars) />
		<cfelse>
			<cfset message = message & application.fapi.getResource("webtop.utilities.fixfilelocations.tosecure@text","'{2}' ({3}) moved to secure directory<br />","",aVars) />
		</cfif>
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
<cfelseif qWrong.recordcount>
	<admin:resource key="webtop.utilities.fixfilelocations.wrongfiles@text" variables="#qWrong.recordcount#"><cfoutput>
		<p class="error">This application has {1} file/s in incorrect locations.</p>
	</cfoutput></admin:resource>
	
	<ft:form><ft:button value="Fix files" /></ft:form>
<cfelse>
	<admin:resource key="webtop.utilities.fixfilelocations.nowrongfiles@text"><cfoutput>
		<p class="success">This application has no files in incorrect locations.</p>
	</cfoutput></admin:resource>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />