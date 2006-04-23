

<cfset theFileName=attributes.filename>
<cfset suffix="default">
<cfset pos=find(".",theFileName)>
<cfif pos>
	<cfset suffix=RemoveChars(theFileName, 1, pos)>
</cfif>

<cfswitch expression="#suffix#">
<cfcase value="pdf">
	<cfset icon="pdf.gif">
</cfcase>
<cfcase value="doc,dot">
	<cfset icon="winword.gif">
</cfcase>
<cfcase value="ppt">
	<cfset icon="powerpnt.gif">
</cfcase>
<cfcase value="gif,jpg,jpeg,pjpeg,cpt,tiff,bmp">
	<cfset icon="pbrush.gif">
</cfcase>
<cfcase value="mov,ra">
	<cfset icon="mov.gif">
</cfcase>
<cfcase value="xls,xlt,xlm">
	<cfset icon="excel.gif">
</cfcase>
<cfcase value="mdb,mde,mda,mdw">
	<cfset icon="msaccess.gif">
</cfcase>
<cfcase value="wav,au,mid">
	<cfset icon="sound.gif">
</cfcase>
<cfcase value="mpp">
	<cfset icon="project.gif">
</cfcase>
<cfcase value="scr">
	<cfset icon="screensaver.gif">
</cfcase>

<!--- 
no winzip image at the moment
<cfcase value="zip">
	<cfset icon="winzip32.gif">
</cfcase>
--->

<cfcase value="rtf">
	<cfset icon="write.gif">
</cfcase>
<cfcase value="txt,log,bat">
	<cfset icon="wordpad.gif">
</cfcase>
<cfcase value="htm,html,cfm,dbm,shtml,dbml,cfml,asp">
	<cfif not parameterexists(http_user_agent)>
		<cfset icon="iexplore.gif">
	<cfelseif http_user_agent does not contain "IE">
		<cfset icon="netscape.gif">
	<cfelse>
		<cfset icon="iexplore.gif">
	</cfif>
</cfcase>
<cfdefaultcase>
	<cfset icon="unknown.gif">
</cfdefaultcase>
</cfswitch>

<cfset "caller.#attributes.r_stIcon#"=icon>