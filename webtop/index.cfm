<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

<cfprocessingDirective pageencoding="utf-8" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Get sections --->
<cfset stSections = application.factory.oWebtop.getItem() />

<!--- Default selected section is the first in the list --->
<cfparam name="url.sec" default="#listfirst(stSections.childorder)#" />

<!--- Default selected subsection is the first in the list --->
<cfparam name="url.sub" default="#listfirst(stSections.children[url.sec].childorder)#" />

<!--- For some reason we are getting here without logging in sometimes, so some variables need to be param'd --->
<cfparam name="session.writingDir" default="ltr" />
<cfparam name="session.userLanguage" default="en" />

<skin:loadCSS id="webtop" />
<skin:loadJS id="jquery" />

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<title>[#application.applicationname#] #application.config.general.sitetitle# - FarCry Webtop</title>
</head>
<body id="sec-#url.sec#">
	<table style="width:100%;height:100%;">
	<tr>
		<td style="height:77px;">
			<div id="header">
			
				<div id="site-name">
		
					<h1>#application.config.general.sitetitle#</h1>
					<h2>#application.config.general.sitetagline#</h2>
				
				</div>
				
				<div id="admin-tools">
					<div id="powered-by"><img src="images/powered_by_farcry.gif" alt="farcry" /></div>
					<p>Logged in: <cfif StructKeyExists(session.dmProfile,"firstname")><strong>#session.dmProfile.firstname#</strong></cfif><br />
					(<a href="#application.url.farcry#/index.cfm?logout=1" target="_top">Logout</a><!---  | Help ---> |  <skin:buildLink alias="home" target="_top">View</skin:buildLink>)
					</p>
				</div>
				
				<div id="nav">
					<ul>
		</cfoutput>
		
		<admin:loopwebtop parent="#stSections#" item="section" class="class">
			<!--- Output the menu link --->
			<cfoutput><li id="nav-#section.id#" class="#class#<cfif url.sec eq section.id> active</cfif>"><a href="index.cfm?sec=#section.id#">#trim(section.label)#</a></li></cfoutput>
		</admin:loopwebtop>
		
		<cfoutput> </ul>
				</div>
			
				<div class="clear"></div>
				
			</div>		
		</td>
	</tr>
	<tr>
		<td id="content-border" style="height:7px;background-color:##324E7C;"></td>
	</tr>
	<tr style="">
		<td style="vertical-align:top;">
			<table style="width:100%;height:100%;">
			<tr>
				<td id="sidebar" style="width:200px;padding: 0;background: transparent url('#application.url.webtop#/css/images/g2_sidebar_bg.gif') no-repeat 0 0;">
					<iframe src="#application.factory.oWebtop.getAttributeURL('#url.sec#.#url.sub#','sidebar',url)#" name="sidebar" scrolling="auto" frameborder="0" id="iframe-sidebar"></iframe>
				</td>
				<td id="content" style="height:100%;padding-top:10px;background: transparent url('#application.url.webtop#/css/images/g2_content_bg.gif') no-repeat -200px 0;">
					<div style="height:100%;margin-left:45px;">
						<iframe src="#application.factory.oWebtop.getAttributeURL('#url.sec#.#url.sub#','content',url)#" name="content" scrolling="auto" frameborder="0" id="iframe-content"></iframe>
					</div>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td id="footer" style="height:25px;">
			<div>
				<p>Copyright &copy; <a href="http://www.daemon.com.au" target="_blank">Daemon</a> 1997-#year(now())#, #createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</p>
			</div>		
		</td>
	</tr>
	</table>
	
	

</cfoutput>

<!--- expander widget for sidebar/content iframes --->
<cfset altexpansion = stSections.children[url.sec].altexpansion />
<cfif altexpansion eq "none">
	<!--- No expand / contract buttons --->
<cfelseif altexpansion gt 200>
	<!--- Alternate size is greater than the default size --->
	<cfoutput>
		<a href="##" id="tree-button-max"><span>Expand Sidebar</span></a>
		<a href="##" id="tree-button-min"><span>Default Sidebar</span></a>
	</cfoutput>	

	<skin:onReady>
		<cfoutput>
        	$j('##tree-button-max').click(function() {
				$j('##sidebar').css('width','#altexpansion#px');
				$j('##iframe-sidebar').css('width','#altexpansion#px');
				$j('##tree-button-max').css('display','none');
				$j('##tree-button-min').css('display','block');
				$j('##content-wrap').css('backgroundPosition','#altexpansion-201#px 0');
				$j('##content').css('marginLeft','#altexpansion+32#px');
				$j('##sec-#url.sec#').css('backgroundPosition','#altexpansion-605#px 0');
			});
        </cfoutput>
	</skin:onReady>
	

	<skin:onReady>
		<cfoutput>
		$j('##tree-button-min').click(function() {		
        	$j('##sidebar').css('width','200px'); 
			$j('##iframe-sidebar').css('width','200px'); 
			$j('##tree-button-max').css('display','block'); 
			$j('##tree-button-min').css('display','none'); 
			$j('##content-wrap').css('backgroundPosition','0 0'); 
			$j('##content').css('marginLeft','232px'); 
			$j('##sec-#url.sec#').css('backgroundPosition','-404px 0');             
		});
		</cfoutput>
	</skin:onReady>
	
<cfelseif altexpansion lt 200>
	<!--- Alternate size is smaller than the default size --->
	<cfoutput>
		<a href="##" id="content-button-max" title="Expand Sidebar"><span>Expand Sidebar</span></a>
		<a href="##" id="content-button-min" title="Default Sidebar"><span>Default Sidebar</span></a>
	</cfoutput>	

	<skin:onReady>
		<cfoutput>
        	$j('##content-button-max').click(function() {
				$j('##sidebar').css('width','#altexpansion#px'); 
				$j('##iframe-sidebar').css('width','#altexpansion#px'); 
				$j('##content-button-max').css('display','none'); 
				$j('##content-button-min').css('display','block'); 
				$j('##content-wrap').css('backgroundPosition','#altexpansion-201#px 0'); 
				$j('##content').css('marginLeft','#altexpansion+32#px'); 
				$j('##sec-#url.sec#').css('backgroundPosition','#altexpansion-605#px 0');
			});
        </cfoutput>
	</skin:onReady>
	

	<skin:onReady>
		<cfoutput>
		$j('##content-button-min').click(function() {			
        	$j('##sidebar').css('width','200px'); 
			$j('##iframe-sidebar').css('width','200px'); 
			$j('##content-button-max').css('display','block'); 
			$j('##content-button-min').css('display','none'); 
			$j('##content-wrap').css('backgroundPosition','0 0'); 
			$j('##content').css('marginLeft','232px'); 
			$j('##sec-#url.sec#').css('backgroundPosition','-404px 0');            
		});
		</cfoutput>
	</skin:onReady>
</cfif>

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">