<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/getFileIcon.cfm,v 1.8 2003/07/14 05:46:27 brendan Exp $
$Author: brendan $
$Date: 2003/07/14 05:46:27 $
$Name: b131 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Works out which icon to use for attachments$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

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
		<cfset icon="Winword.gif">
	</cfcase>
	<cfcase value="ppt">
		<cfset icon="POWERPNT.gif">
	</cfcase>
	<cfcase value="gif,jpg,jpeg,pjpeg,cpt,tiff,bmp,eps,png,tif,psd,ai">
		<cfset icon="Pbrush.gif">
	</cfcase>
	<cfcase value="mov,ra">
		<cfset icon="mov.gif">
	</cfcase>
	<cfcase value="xls,xlt,xlm">
		<cfset icon="excel.gif">
	</cfcase>
	<cfcase value="mdb,mde,mda,mdw">
		<cfset icon="Msaccess.gif">
	</cfcase>
	<cfcase value="wav,au,mid">
		<cfset icon="sound.gif">
	</cfcase>
	<cfcase value="mpp">
		<cfset icon="project.gif">
	</cfcase>
	<cfcase value="swf">
		<cfset icon="flash.gif">
	</cfcase>
	<cfcase value="scr">
		<cfset icon="screensaver.gif">
	</cfcase>
	<cfcase value="zip">
		<cfset icon="winzip_icon.gif">
	</cfcase>
	<cfcase value="exe">
		<cfset icon="exe_icon.gif">
	</cfcase>
	<cfcase value="rtf">
		<cfset icon="Write.gif">
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

<cfsetting enablecfoutputonly="no">