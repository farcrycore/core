<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/typeadminbutton.cfm,v 1.4 2005/08/02 04:44:28 geoff Exp $
$Author: geoff $
$Date: 2005/08/02 04:44:28 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Button definitions for generic administration screen for content types, by typeadmin. $

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au)$

|| USAGE ||
<cf_typeadminbutton
	buttontype="method"
	name="name of button"
	value="some value, doubles as label"
	onclick="some javascript for event" 
	url="some url"
	permission="some permission to check" 
	class="some html to passthrough on the input tag" />

Button types:
default button types including add, delete, unlock, dump, requestapproval, approve, sendtodraft
custom; must have accompanying method or url attribute
todo: hidden; input type=hidden

|| ATTRIBUTES ||
-> [buttontype]: type of button (required); 
-> [name]: name of the button (required);
-> [value]: value of the button, doubles as label (required);
-> [onclick]: onClick javascript event for button;
-> [url]: url of action page;
-> [permission]: permission to check for button display;
-> [class]: class to assign to button;
-> [method]: required if buttontype="method"
--->

<cfswitch expression="#ThisTag.ExecutionMode#">
<cfcase value="start">
	<!--- make sure the tag is within cf_typeadmin --->
	<cfset ParentTag = GetBaseTagList()>
	<cfif NOT ListFindNoCase(ParentTag, "cf_typeadmin")>
		<cfabort showerror="<strong>Error in cf_typeadminbutton</strong><br>This tag must be coded within a parent cf_typeadmin tag.">
	</cfif>
	<!--- make sure tag is correctly implemented --->
	<cfif NOT ThisTag.HasEndTag>
		<cfabort showerror="<strong>cf_typeadminbutton requires a closing tag.</strong><br><b>Usage:</b><br>&lt;cf_typeadminbutton&gt;&lt;/cf_typeadminbutton&gt; or &lt;cf_typeadminbutton /&gt;">
	</cfif>

	<!--- required attributes --->
	<cfparam name="attributes.buttontype">
	<cfif NOT listcontains("add, delete, unlock, dump, requestapproval, approve, sendtodraft", attributes.buttontype)>
		<cfparam name="attributes.name" type="string">
		<cfparam name="attributes.value" type="string">
	</cfif>

	<!--- optional attributes --->
	<cfparam name="attributes.onclick" default="">
	<cfparam name="attributes.url" default="">
	<cfparam name="attributes.permission" default="">
	<cfparam name="attributes.method" default="">
	<cfparam name="attributes.class" default="f-submit">
		
	<!--- Get the parent tag instance data from typeadmin--->
	<cfset tagData = GetBaseTagData("cf_typeadmin")>
	
	<!--- prepare the button metadata --->
	<cfswitch expression="#attributes.buttontype#">
	<!--- default button options --->
	<cfcase value="add,delete,unlock,dump,requestapproval,approve,sendtodraft">
		<cfloop from="1" to="#arrayLen(tagdata.aDefaultButtons)#" index="i">
			<cfif tagdata.aDefaultButtons[i].buttontype eq attributes.buttontype>
				<!--- set button structure to default values --->
				<cfset attributes=tagdata.aDefaultButtons[i]>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfcase>
	
	<cfcase value="custom">
		<cfscript>
			// set up customdata variable
			stcustomdata=structnew();
			// todo: escape " for url and method values
			stcustomdata.method=attributes.method;
			stcustomdata.url=attributes.url;
		</cfscript>
		<cfwddx action="cfml2wddx" input="#stcustomdata#" output="wCustomdata">
		<cfscript>
			stBut=structNew();
			stBut.type="submit";
			stBut.name="cb" & attributes.name; // add prefix for detection
			stBut.value=attributes.value;
			stBut.class="f-submit";
			stBut.onClick=attributes.onclick;
			stBut.permission=attributes.permission;
			stBut.customdata=wcustomdata;
			stBut.buttontype="custom";
			// set button structure to pass back
			attributes=stbut;
		</cfscript>
	</cfcase>
	
	<cfdefaultcase>
		<cfabort showerror="<b>#attributes.buttontype#</b> buttontype not recognised.">
	</cfdefaultcase>
	</cfswitch>
	
	<!--- associate attributes with parent typeadmin --->
	<cfassociate basetag="cf_typeadmin" datacollection="aButtons">
	
</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="No">
