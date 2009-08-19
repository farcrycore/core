<cfsetting enablecfoutputonly="Yes">
<cfsilent>
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
<!--- @@hint: Builds a link to farcry content; works out whether the link is a symlink or normal farcry link and checks for friendly url. --->

<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.href" default=""><!--- @@attrhint: a hard coded href to link to (Note using href will cause other params to be ignored) --->
	<cfparam name="attributes.objectid" default=""><!--- @@attrhint: Adds the given objectid to url parameters --->
	<cfparam name="attributes.alias" default=""><!--- @@attrhint: Navigation alias to use to find the objectid. The objectid is then added to the URL --->
	<cfparam name="attributes.type" default=""><!--- @@attrhint: Added to url parameters: Typename used with type webskin views, dmProfile for example. --->
	<cfparam name="attributes.view" default=""><!--- @@attrhint: Added to url parameters: Webskin name used to render the page layout, for example displayPage3Col. Note if you use "displayPageStandard" for this value it will not be added to the link --->
	<cfparam name="attributes.bodyView" default=""><!--- @@attrhint: Added to url parameters: Webskin name used to render the body content, for example displayBody. Note if you use "displayBody" for this value it will not be added to the link --->
	<!---  --->
	<cfparam name="attributes.linktext" default=""><!--- @@attrhint: Text used for the link --->
	<cfparam name="attributes.target" default="_self"><!--- @@attrhint: target window for link --->
	<cfparam name="attributes.bShowTarget" default="false"><!--- @@attrhint: Show the target link in the anchor tag @@options: false,true @@type: boolean --->
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.id" default=""><!--- @@attrhint: Anchor tag ID --->
	<cfparam name="attributes.class" default=""><!--- @@attrhint: Anchor tag classes --->
	<cfparam name="attributes.style" default=""><!--- @@attrhint: Anchor tag styles --->
	<cfparam name="attributes.title" default=""><!--- @@attrhint: Anchor tag title text --->
	<cfparam name="attributes.urlOnly" default="false">
	<cfparam name="attributes.r_url" default=""><!--- @@attrhint: Define a variable to pass the link back (instead of writting out via the tag). Note setting urlOnly invalidates this setting --->
	<cfparam name="attributes.xCode" default=""><!--- @@attrhint: eXtra code to be placed inside the anchor tag --->
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.Domain" default="#cgi.http_host#">
	<cfparam name="attributes.stParameters" default="#StructNew()#">
	<cfparam name="attributes.urlParameters" default="">
	<cfparam name="attributes.JSWindow" default="0"><!--- @@attrhint: Default to not using a Javascript Window popup --->
	<cfparam name="attributes.stJSParameters" default="#StructNew()#">
	<cfparam name="attributes.anchor" default=""><!--- @@attrhint: Anchor to place at the end of the URL string. --->
	<cfparam name="attributes.onclick" default=""><!--- @@attrhint: the js code to place in onclick --->
	<cfparam name="attributes.ampDelim" default="&amp;"><!--- @@attrhint: the default ampersand delimiter as used by getLink --->

	<cfset href = application.fapi.getLink(argumentCollection="#attributes#") />


	<!--- Are we mean to display an a tag or the URL only? --->
	<cfif attributes.urlOnly EQ true>
		<!--- display the URL only --->
		<cfset tagoutput=href>
	<cfelseif len(attributes.r_url)>
		<cfset "caller.#attributes.r_url#" = href />
	<cfelse>
		<!--- display link --->
		<cfset tagoutput='<a href="#href#"'>
		<cfif len(attributes.id)>
			<cfset tagoutput=tagoutput & ' id="#attributes.id#"'>
		</cfif>
		<cfif len(attributes.class)>
			<cfset tagoutput=tagoutput & ' class="#attributes.class#"'>
		</cfif>
		<cfif len(attributes.style)>
			<cfset tagoutput=tagoutput & ' style="#attributes.style#"'>
		</cfif>
		<cfif len(attributes.title)>
			<cfset tagoutput=tagoutput & ' title="#attributes.title#"'>
		</cfif>
		<cfif len(attributes.xCode)>
			<cfset tagoutput=tagoutput & ' #attributes.xCode#'>
		</cfif>
		<cfif attributes.bShowTarget eq true>
			<cfset tagoutput=tagoutput & ' target="#attributes.target#"'>
		</cfif>
		<cfif len(attributes.onclick)>
			<cfset tagoutput=tagoutput & ' onclick="#attributes.onclick#"'>
		</cfif>
		<cfset tagoutput=tagoutput & '>'>
	</cfif>

<!--- thistag.ExecutionMode is END --->
<cfelse>
	<cfif not len(attributes.r_url)>
	

		<!--- Was only the URL requested? If so, we don't need to close any tags --->
		<cfif attributes.urlOnly EQ false>
			
			<!--- USE THE LINKTEXT AS GENERATED CONTENT IF AVAILABLE --->
			<cfif len(attributes.linktext)>
				<cfset thistag.GeneratedContent = attributes.linktext />
			</cfif>
			
			<!--- IF WE DONT HAVE ANY GENERATED CONTENT, GO FIND THE LABEL OF THE OBJECT --->
			<cfif not len(thistag.GeneratedContent) and len(attributes.objectid)>
				<cfset stLinkObject = application.fapi.getContentObject(objectid="#attributes.objectid#", typename="#attributes.type#") />
				<cfset thistag.GeneratedContent=stLinkObject.label />
			</cfif>		
		
			<cfset tagoutput = tagoutput & trim(thistag.generatedcontent) & '</a>'>
		</cfif>
		
		
		<!--- clean up whitespace --->
		<cfset thistag.GeneratedContent=tagoutput>
	</cfif>
</cfif>
</cfsilent>

<cfsetting enablecfoutputonly="No">