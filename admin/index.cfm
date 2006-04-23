<cfsetting enablecfoutputonly="true">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/index.cfm,v 1.102.2.1 2006/04/09 02:43:35 geoff Exp $
$Author: geoff $
$Date: 2006/04/09 02:43:35 $
$Name: milestone_3-0-1 $
$Revision: 1.102.2.1 $

|| DESCRIPTION || 
$Description: FarCry Admin Central Index. 
Notes:
section url param loads default iFrames

Nav tabs load from XML

Vars:
<title></title>
<body id="var">

pseudo logic:
check active section from url
is sec valid and permitted
is sub valid and permitted
load default iframes
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
$Developer: Pete Ottery (pot@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<!--- resolve default iframes for this section view --->
<cfparam name="url.sec" default="home" type="string">
<cfparam name="url.sub" default="" type="string">

<cfset oWebTop=application.factory.owebtop>
<cfset xmlWebtop=owebtop.xmlWebtop>

<!--- get subsection to display --->
<cfset aSubectionToDisplay = oWebTop.getSubSectionAsArray(url.sec, url.sub)>
<cfset aSections = oWebTop.getSectionsAsArray()>
<!--- TODO: Please explain? does this need to be done at all? could it be done in component? GB --->
<cfloop index="i" from="1" to="#ArrayLen(aSections)#">
	<cfset owebtop.fTranslateXMLElement(aSections[i])>
</cfloop>

<cfset secid=url.sec>
<cfset subid=url.sub>
<!--- <cfset sidebar=aSubectionToDisplay[1].xmlattributes.sidebar & "?sub=" & aSubectionToDisplay[1].xmlattributes.id & "&" & cgi.query_string>
<cfset content=aSubectionToDisplay[1].xmlattributes.content & "?" & cgi.query_string> --->
<cfset sidebar=oWebTop.getSidebarUrl(aSubectionToDisplay[1].XmlAttributes)>
<cfset content=oWebTop.getContentUrl(aSubectionToDisplay[1].XmlAttributes)> 

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<title>FarCry</title>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<script type="text/javascript" src="#application.url.farcry#/js/prototype.js"></script>
</head>
<body id="sec-#secid#">

	<div id="header">
	
		<div id="site-name">

			<h1>#application.config.general.sitetitle#</h1>
			<h2>#application.config.general.sitetagline#</h2>
		
		</div>
		
		<div id="admin-tools">
			<div id="powered-by"><img src="images/powered_by_farcry.gif" alt="farcry" /></div>
			<p>Logged in: <cfif StructKeyExists(session.dmProfile,"firstname")><strong>#session.dmProfile.firstname#</strong></cfif><br />
			(<a href="#application.url.farcry#/index.cfm?logout=1" target="_top">Logout</a><!---  | Help ---> | <a href="#application.url.conjurer#" target="_blank">View</a>)
			</p>
		</div>
		
		<div id="nav">
			<ul>
</cfoutput>
			<!--- determine available section tabs --->
			<cfloop from="1" to="#arraylen(aSections)#" index="i"><cfif request.dmsec.oAuthorisation.fCheckXMLPermission(aSections[i].xmlAttributes)>
			<cfoutput><li id="nav-#aSections[i].xmlAttributes.id#"<cfif arraylen(aSections) eq i> class="last<cfif url.sec EQ aSections[i].xmlAttributes.id> active</cfif>"<cfelseif url.sec EQ aSections[i].xmlAttributes.id> class="active"</cfif>><a href="index.cfm?sec=#aSections[i].xmlAttributes.id#">#trim(aSections[i].xmlAttributes.label)#</a></li></cfoutput>
			</cfif></cfloop>
<cfoutput> </ul>
		</div>
	
		<div class="clear"></div>
		
	</div>
	<div id="content-wrap">

		<div id="sidebar">
			<iframe src="#variables.sidebar#" name="sidebar" scrolling="auto" frameborder="0" id="iframe-sidebar"></iframe>
		</div>
		
		<div id="content">
			<iframe src="#variables.content#" name="content" scrolling="auto" frameborder="0" id="iframe-content"></iframe>
		</div>
		
		<div class="clear"></div>

	</div>
	
	<div id="footer">
		<p>Copyright &copy; Daemon 1997-#year(now())#, #createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</p>
	</div>
</cfoutput>

<!--- expander widget for sidebar/content iframes --->
<!--- 
TODO: 	should be based on section attribute in webtop.xml not specific sectionid
		this will enable custom admin sections to choose expander option. Options
		should include expand, contract, expand/contract and none ideally. GB
 --->
<cfswitch expression="#secid#">
	<cfcase value="home">
	<!--- do nothing for overview page --->
	</cfcase>
	<cfcase value="site">
	<!--- expands tree iframe for access to nested content --->
	<cfoutput>
	<a href="##" onclick="$('sidebar').style.width = '500px'; $('iframe-sidebar').style.width = '500px'; $('tree-button-max').style.display = 'none'; $('tree-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '300px 0'; $('content').style.marginLeft = '532px'; $('sec-#secid#').style.backgroundPosition = '-104px 0'; return false;" id="tree-button-max"><span>Maximise Tree</span></a>
	<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('tree-button-max').style.display = 'block'; $('tree-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '232px'; $('sec-#secid#').style.backgroundPosition = '-404px 0'; return false;" id="tree-button-min"><span>Default Tree Width</span></a>
	</cfoutput>
	</cfcase>
	<cfdefaultcase>
	<!--- contracts menu iframe to enable larger content editing area --->
	<cfoutput>
	<a href="##" onclick="$('sidebar').style.width = '0'; $('iframe-sidebar').style.width = '0'; $('content-button-max').style.display = 'none'; $('content-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '-201px 0'; $('content').style.marginLeft = '35px'; $('sec-#secid#').style.backgroundPosition = '-605px 0'; return false;" id="content-button-max"><span>Maximise Content Width</span></a>
	<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('content-button-max').style.display = 'block'; $('content-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '236px'; $('sec-#secid#').style.backgroundPosition = '-404px 0'; return false;" id="content-button-min"><span>Default Content Width</span></a>
	</cfoutput>
	</cfdefaultcase>
</cfswitch>

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">