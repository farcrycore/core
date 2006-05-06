<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/buildLink.cfm,v 1.16.2.2 2006/01/26 06:49:20 geoff Exp $
$Author: geoff $
$Date: 2006/01/26 06:49:20 $
$Name:  $
$Revision: 1.16.2.2 $

|| DESCRIPTION || 
$Description: Helps to construct a FarCry style link -- works out whether the links is a symlink or normal farcry link and checks for friendly url$
$TODO: make a corresponding UDF $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- navigation obj id$
$in: title -- link text $
$in: external -- external link for nav node $
$in: class -- css class for link$
$in: target -- target window for link$
$in: xCode -- eXtra code to be placed inside the anchor tag $
--->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.linktext" default="">
	<cfparam name="attributes.target" default="_self">
	<cfparam name="attributes.bShowTarget" default="false">
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.urlOnly" default="false">
	<cfparam name="attributes.xCode" default="">
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.stParameters" default="#StructNew()#">
	<cfparam name="attributes.JSWindow" default="0"><!--- Default to not using a Javascript Window popup --->
	<cfparam name="attributes.stJSParameters" default="#StructNew()#">

	
	<cfif attributes.target NEQ "_self" AND NOT attributes.urlOnly> <!--- If target is defined and the user doesn't just want the URL then it is a popup window and must therefore have the following parameters --->		
		<cfset attributes.JSWindow = 1>
		
		<cfparam name="Attributes.stJSParameters.Toolbar" default="0">
		<cfparam name="Attributes.stJSParameters.Status" default="1">
		<cfparam name="Attributes.stJSParameters.Location" default="0">
		<cfparam name="Attributes.stJSParameters.Menubar" default="0">
		<cfparam name="Attributes.stJSParameters.Directories" default="0">
		<cfparam name="Attributes.stJSParameters.Scrollbars" default="1">
		<cfparam name="Attributes.stJSParameters.Resizable" default="1">
		<cfparam name="Attributes.stJSParameters.Top" default="0">
		<cfparam name="Attributes.stJSParameters.Left" default="0">
		<cfparam name="Attributes.stJSParameters.Width" default="700">
		<cfparam name="Attributes.stJSParameters.Height" default="700">
	</cfif>
	
	
	<!---
	Only initialize FU if we're using Friendly URL's
	We cannot guarantee the Friendly URL Servlet exists otherwise
	--->
	<cfif application.config.plugins.fu>
		<cfset objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	</cfif>
	
	<cfif structKeyExists(attributes,"href")>
		<cfset href = attributes.href>
		
		<cfif NOT FindNoCase(attributes.href,"?")>
			<cfset href = "#href#?">
		</cfif>
	<cfelse>
		<cfif attributes.includeDomain>
	        <cfset href = "http://#cgi.http_host#">
	    <cfelse>
	        <cfset href = "">
	    </cfif>
	
		<!--- check for sim link --->
		<cfif len(attributes.externallink)>
			<!--- check for friendly url --->
			<cfif application.config.plugins.fu>
				<cfset href = href & objFU.getFU(attributes.externallink)>
			<cfelse>
				<cfset href = href & application.url.conjurer & "?objectid=" & attributes.externallink>
			</cfif>
		<cfelse>
			<!--- check for friendly url --->
			<cfif application.config.plugins.fu>
				<cfset href = href & objFU.getFU(attributes.objectid)>
			<cfelse>
				<cfset href = href & application.url.conjurer & "?objectid=" & attributes.objectid>
			</cfif>
		</cfif>
	</cfif>
	
	<!--- check for extra URL parameters --->
	<cfif NOT StructIsEmpty(attributes.stParameters)>
		<cfset stLocal = StructNew()>
		<cfset stLocal.parameters = "">
		<cfset stLocal.iCount = 0>
		<cfloop collection="#attributes.stParameters#" item="stLocal.key">
			<cfif stLocal.iCount GT 0>
				<cfset stLocal.parameters = stLocal.parameters & "&">
			</cfif>
			<cfset stLocal.parameters = stLocal.parameters & stLocal.key & "=" & URLEncodedFormat(attributes.stParameters[stLocal.key])>
			<cfset stLocal.iCount = stLocal.iCount + 1>
		</cfloop>

		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<!--- if FU is turned on then append extra URL parameters with a leading '?' --->
			<cfset href = href & "?" & stLocal.parameters>
		<cfelse>
		  	<!--- if FU is turned off then append extra URL parameters with a leading '&' as there will already be URL params (i.e. "?objectid=") --->
			<cfset href = href & "&" & stLocal.parameters>
		</cfif>
	</cfif>
	
	
	<!--- Are we meant to use the Javascript Popup Window? --->
	<cfif attributes.JSWindow>
	
		<cfset attributes.bShowTarget = 0><!--- No need to add the target to the <a href> as it is handled in the javascript --->
		
		<cfset jsParameters = "">
		<cfloop list="#structKeyList(Attributes.stJSParameters)#" index="i">
			<cfset jsParameters = ListAppend(jsParameters, "#i#=#attributes.stJSParameters[i]#")>
		</cfloop>
		<cfset href = "javascript:win=window.open('#href#', '#attributes.Target#', '#jsParameters#'); win.focus();">
		
		<!--- Has the javascript already been added to this page? --->
		<cfif NOT structKeyExists(request,"jsOpenWindowDefined")>
			
			<cfset request.jsOpenWindowDefined = 1>
			
			<cfsavecontent variable="jsOpenWindow">
			<cfoutput>
			<script type="text/javascript">
			function OpenFarcryWindow(URL,Target,Width,Height,Parameters) {
				
				if ((Width == 0) && (Height == 0)){
					if ((screen.Height >= 0) && (screen.Width >= 0))
					{
						var Width = screen.Width - 10;
						var Height = screen.Height - 100;
					}
					else if ((screen.availHeight >= 0) && (screen.availWidth >= 0)) {
						
						var Width = screen.availWidth - 10;
						var Height = screen.availHeight - 100;
					}
				}
				
			}		
			</script>
			</cfoutput>
			</cfsavecontent>
			
			<cfhtmlhead text="#jsOpenWindow#">
		</cfif>
	</cfif>
	
	
	<!--- Are we mean to display an a tag or the URL only? --->
	<cfif attributes.urlOnly EQ true>
		<!--- display the URL only --->
		<cfset tagoutput=href>

	<cfelse>
		<!--- display link --->
		<cfset tagoutput='<a href="#href#"'>
		<cfif len(attributes.class)>
			<cfset tagoutput=tagoutput & ' class="#attributes.class#"'>
		</cfif>
		<cfif len(attributes.xCode)>
			<cfset tagoutput=tagoutput & ' #attributes.xCode#'>
		</cfif>
		<cfif attributes.bShowTarget eq true>
			<cfset tagoutput=tagoutput & ' target="#attributes.target#"'>
		</cfif>
		<cfset tagoutput=tagoutput & '>'>
	</cfif>

<!--- thistag.ExecutionMode is END --->
<cfelse>
	<!--- Was only the URL requested? If so, we don't need to close any tags --->
	<cfif attributes.urlOnly EQ false>
		<cfif len(attributes.linktext)>
			<cfset tagoutput=tagoutput & trim(attributes.linktext) & '</a>'>
		<cfelse>
			<cfset tagoutput=tagoutput & trim(thistag.generatedcontent) & '</a>'>
		</cfif>
	</cfif>

	<!--- clean up whitespace --->
	<cfset thistag.GeneratedContent=tagoutput>
</cfif>

<cfsetting enablecfoutputonly="No">