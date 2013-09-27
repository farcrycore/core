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
<!--- @@displayname: jQuery tools: Tool Tip --->
<!--- @@description: Displays a tool tip on hover.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- 
	@@examples:
	<p>Linking a tool tip to a DOM element using the id attribute</p>
	<code>
		<skin:tooltip message="Stuff!" selector="#a-123" />
		<a href="javascript:void(0);" id="a-123">Things</a>
	</code>
	
	<p>Linking a tooltip to a DOM element using the id attribute and 
		doing an HTML style tooltip</p>
	<code>
		<skin:tooltip selector="#a-123">
		  <b>THINGS!</b>
		</skin:tooltip>
		<a href="javascript:void(0);" id="a-123">Things</a>
	</code>
	
	<p>Linking a tool tip to several DOM elements using the class
		selector</p>
	<code>
		<skin:tooltip selector=".yadda">
		   <b>THINGS!</b>
		</skin:tooltip>
		<a class="yadda" href="javascript:void(0);">Thing 1</a>
		<a class="yadda" href="javascript:void(0);">Thing 2</a>
		<a class="yadda" href="javascript:void(0);">Thing Red</a>
		<a class="yadda" href="javascript:void(0);">Thing Blue</a>
	</code>
--->

<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.id" default="" /><!--- id used to ensure the tooltip is only loaded once per id. --->
<cfparam name="attributes.selector" type="string" /><!--- The id of the dom element that you wish to have the tooltip display on hover. --->
<cfparam name="attributes.message" default="" /><!--- The actual message. If this is blank, the text between the opening and the closing tag will be used (generatedContent) --->
<cfparam name="attributes.class" default="" /><!--- The css class to be assigned to the tooltip div --->
<cfparam name="attributes.position" default="" /><!--- The css class to be assigned to the tooltip div --->


<cfif thistag.executionMode eq "Start">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "End">

	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="jquery-tooltip" />
	<skin:loadCSS id="jquery-tooltip" />

	<cfif not len(attributes.message)>
		<cfset attributes.message = thisTag.generatedContent />
	</cfif>
	<cfset thisTag.generatedContent = "" />
		
	<cfif not len(attributes.id)>
		<cfset attributes.id = hash(attributes.selector) /><!--- Replace non alphanumeric --->
	</cfif>
	
	
	<!--- 
		This crazy code checking is because of a bug in the tooltip when rendering tips with multiple nodes matching the selector when rendered via ajax.
		We are basically checking to see if a tooltip has already been rendered and if so, do not initialize it again.
	--->
	<skin:onReady id="tooltipster-#attributes.id#">
	<cfoutput>
		$j('#attributes.selector#').tooltipster({ 
			theme: ".tooltipster-light",
			<cfif len(attributes.position)>
			position: "#attributes.position#",
			</cfif>
			<cfif len(attributes.message)>
			content: '#jsStringFormat(attributes.message)#',
			</cfif>
			delay: 0, 
			speed: 200			
		});
	</cfoutput>
	</skin:onReady>
</cfif>


<cfsetting enablecfoutputonly="false">