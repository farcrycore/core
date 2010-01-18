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
<!--- @@displayname: Standard Login Header --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<skin:loadCSS id="webtop" />

<skin:loadCSS id="farcry-form">
	<cfoutput>
	.uniForm .fieldset {
		margin:30px 0 0 0;
		padding:5px;
	}
	
	.uniForm .fieldset .legend {
		color:##324E7C;
		margin:0;
		padding:0px;
		font-size:107%;
	}
	
	.ctrlHolder {
		background:##E4E4E4;
	}
	
	.uniForm .ctrlHolder .label {
		font-weight: bold;
	}
	
	.uniForm .helpsection {
		margin:10px 0px;
	}
	
	.uniForm .buttonHolder{ text-align: right; margin:5px 0 10px 0;padding:5px;border:1px solid ##CCCCCC;border-width:1px 0px;background-color:##F4F4F4;}
	
	.uniForm .fc-button {padding:5px;}
	</cfoutput>
</skin:loadCSS>

<!------------------ 
START WEBSKIN
 ------------------>
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
	<title>#application.config.general.siteTitle# :: #application.applicationname#</title>

</head>

<body id="sec-login">
<div id="login">
	<div class="loginLogo">		
		<a href="#application.url.webroot#/index.cfm">
			<!--- if there is a site logo, use it instead of the default placeholder --->       
			<cfif structKeyExists(application.config.general,'siteLogoPath') and application.config.general.siteLogoPath NEQ "">
				<img src="#application.config.general.siteLogoPath#" alt="#application.config.general.siteTitle#" />
				<h1>#application.config.general.siteTitle#</h1>
				<span>#application.config.general.siteTagLine#</span>	
			<cfelse>
				<img src="#application.url.webtop#/images/logo_placeholder.gif" alt="#application.config.general.siteTitle#" />
			</cfif>
		</a>	
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">