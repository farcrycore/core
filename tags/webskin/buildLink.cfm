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

	<cfparam name="attributes.href" default=""><!--- the actual href to link to --->
	<cfparam name="attributes.objectid" default=""><!--- Added to url parameters; navigation obj id --->
	<cfparam name="attributes.type" default=""><!--- Added to url parameters: Typename used with type webskin views --->
	<cfparam name="attributes.view" default=""><!--- Added to url parameters: Webskin name used to render the page layout --->
	<cfparam name="attributes.bodyView" default=""><!--- Added to url parameters: Webskin name used to render the body content --->
	<cfparam name="attributes.linktext" default=""><!--- Text used for the link --->
	<cfparam name="attributes.target" default="_self"><!--- target window for link --->
	<cfparam name="attributes.bShowTarget" default="false"><!--- @@attrhint: Show the target link in the anchor tag  @@options: false,true --->
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.id" default=""><!--- Anchor tag ID --->
	<cfparam name="attributes.class" default=""><!--- Anchor tag classes --->
	<cfparam name="attributes.style" default=""><!--- Anchor tag styles --->
	<cfparam name="attributes.urlOnly" default="false">
	<cfparam name="attributes.r_url" default=""><!--- Define a variable to pass the link back (instead of writting out via the tag). Note setting urlOnly invalidates this setting --->
	<cfparam name="attributes.xCode" default=""><!--- eXtra code to be placed inside the anchor tag --->
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.Domain" default="#cgi.http_host#">
	<cfparam name="attributes.stParameters" default="#StructNew()#">
	<cfparam name="attributes.urlParameters" default="">
	<cfparam name="attributes.JSWindow" default="0"><!--- Default to not using a Javascript Window popup --->
	<cfparam name="attributes.stJSParameters" default="#StructNew()#">
	<cfparam name="attributes.anchor" default=""><!--- Anchor to place at the end of the URL string. --->
	

	<!--- Setup URL Parameters --->
	<cfif listLen(attributes.urlParameters, "&")>
		<cfloop list="#attributes.urlParameters#" delimiters="&" index="i">
			<cfset attributes.stParameters[listFirst(i, "=")] = listLast(i, "=")>
		</cfloop>
	</cfif>
	
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
	

	<cfif len(attributes.href)>
		<cfset href = attributes.href>

		<cfif NOT FindNoCase("?", attributes.href)>
			<cfset href = "#href#?">
		</cfif>
	<cfelse>
		<cfif attributes.includeDomain>
	        <cfset href = "http://#attributes.Domain#">
	    <cfelse>
	        <cfset href = "">
	    </cfif>
	    
	    <cfset linkID = "" />
	    
	    <cfif len(attributes.externallink)>
			<cfset linkID = attributes.externallink />
		<cfelseif len(attributes.objectid)>
			<cfset linkID = attributes.objectid />
		</cfif>


		<cfset href = href & application.fc.factory.farFU.getFU(objectid="#linkID#", type="#attributes.type#", view="#attributes.view#", bodyView="#attributes.bodyView#")>

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

	
		<cfif ListFind("&,?",Right(href,1))><!--- check to see if the last character is a ? or & and don't append one between the params and the href --->
			<cfset href=href&stLocal.parameters>
		<cfelseif Find("?",href)> <!--- If there is already a ? in the href, just concat the params with & --->
			<cfset href=href&"&"&stLocal.parameters>
		<cfelse> <!--- No query string on the href, so add a new one using ? and the params --->
			<cfset href=href&"?"&stLocal.parameters>		
		</cfif>
	</cfif>
	
	<!--- Append the anchor to the end of the URL. --->
	<cfif len(attributes.anchor)>
		<cfif left(attributes.anchor,1) NEQ "##">
			<cfset attributes.anchor = "###attributes.anchor#">
		</cfif>
		<cfset href = "#href##attributes.anchor#" />		
	</cfif>
	
	<!--- Are we meant to use the Javascript Popup Window? --->
	<cfif attributes.JSWindow>
	
		<cfset attributes.bShowTarget = 0><!--- No need to add the target to the <a href> as it is handled in the javascript --->
		
		<cfset jsParameters = "">
		<cfloop list="#structKeyList(Attributes.stJSParameters)#" index="i">
			<cfset jsParameters = ListAppend(jsParameters, "#i#=#attributes.stJSParameters[i]#")>
		</cfloop>
		<cfset href = "javascript:win=window.open('#href#', '#attributes.Target#', '#jsParameters#'); win.focus();">
		
	</cfif>
	
	
	<!--- Are we mean to display an a tag or the URL only? --->
	<cfif attributes.urlOnly EQ true>
		<!--- display the URL only --->
		<cfset tagoutput=href>
	<cfelseif len(attributes.r_url)>
		<cfset caller[attributes.r_url] = href />	
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
	<cfif not len(attributes.r_url)>
	

		<!--- Was only the URL requested? If so, we don't need to close any tags --->
		<cfif attributes.urlOnly EQ false>
			
			<!--- USE THE LINKTEXT AS GENERATED CONTENT IF AVAILABLE --->
			<cfif len(attributes.linktext)>
				<cfset thistag.GeneratedContent = attributes.linktext />
			</cfif>
			
			<!--- IF WE DONT HAVE ANY GENERATED CONTENT, GO FIND THE LABEL OF THE OBJECT --->
			<cfif not len(thistag.GeneratedContent) and len(attributes.objectid)>
				<cfset stLinkObject = application.coapi.coapiUtilities.getContentObject(objectid="#attributes.objectid#", typename="#attributes.type#") />
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