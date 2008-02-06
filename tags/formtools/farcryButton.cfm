<cfsetting enablecfoutputonly="yes">

<cfsilent>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." >
</cfif>

<cfparam  name="attributes.id" default="#createUUID()#">
<cfparam  name="attributes.Type" default="submit">
<cfparam  name="attributes.Value" default="#Attributes.Type#">
<cfparam  name="attributes.rbkey" default="forms.buttons.#rereplacenocase(attributes.value,'[^\w\d]','','ALL')#">
<cfparam  name="attributes.Onclick" default="">
<cfparam  name="attributes.Class" default="">
<cfparam  name="attributes.Style" default="">
<cfparam name="attributes.SelectedObjectID" default="">
<cfparam name="attributes.ConfirmText" default="">
<cfparam name="attributes.validate" default="">
<cfparam name="attributes.bInPanel" default="true">
<cfparam name="attributes.src" default="">
<cfparam name="attributes.url" default="">
<cfparam name="attributes.target" default="_self">

</cfsilent>

<cfif thistag.ExecutionMode EQ "Start">
	<!--- I18 conversion of label --->
	<cfset attributes.value = application.rb.getResource('#attributes.rbkey#@label',attributes.value) />

	<cfsilent>

	<!--- Include Prototype light in the head --->
	<skin:htmlHead library="prototypelite" />

	<!--- If not in a farcry form, make it a button. --->
	<cfif NOT isDefined("Request.farcryForm.Name")>
		<cfset attributes.Type = "button" />
	</cfif>

	<!--- Default validate to true if submitting and false if just a button --->
	<cfif not len(attributes.validate)>
		<cfif attributes.type EQ "submit">
			<cfset attributes.validate = true />
		<cfelse>
			<cfset attributes.validate = false />
		</cfif>
	</cfif>
	
	<cfif len(attributes.SelectedObjectID) AND isDefined("Request.farcryForm.Name")>		
		<cfset attributes.Onclick = "#attributes.OnClick#;$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.SelectedObjectID#';">
	</cfif>
	
	<cfif len(Attributes.ConfirmText)>
			<!--- I18 conversion of label --->
	<cfset Attributes.ConfirmText = application.rb.getResource('#attributes.rbkey#@confirmtext',Attributes.ConfirmText) />
	
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "if(confirm('#Attributes.ConfirmText#')) {dummyconfirmvalue=1} else {return false};#attributes.OnClick#;">
	</cfif>	
	 
	<cfif isDefined("Request.farcryForm.Name")>
		<cfset attributes.onClick = "#attributes.onClick#;$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value = '#attributes.Value#';">
	</cfif>

	
	<cfif isDefined("Request.farcryForm.Name") AND Request.farcryForm.Validation AND Attributes.validate>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;if(realeasyvalidation#Request.farcryForm.Name#.validate()) {dummyconfirmvalue=1} else {return false};">

	</cfif>	

	<cfif len(attributes.url)>
		<cfset attributes.OnClick = "#attributes.OnClick#;return farcryButtonURL('#attributes.id#','#attributes.url#','#attributes.target#');">
	</cfif>

	<cfif not len(attributes.bInPanel)>
		<cfset ParentTag = GetBaseTagList()>
		<cfif ListFindNoCase(ParentTag, "cf_farcryButtonPanel")>
			<cfset attributes.bInPanel = true>
		<cfelse>
			<cfset attributes.bInPanel = false>
		</cfif>
	</cfif>
	
	
	<cfsavecontent variable="buttonHTML">
	
	<cfif attributes.bInPanel>
		<cfif attributes.type eq "image" and len(attributes.src)>
			<cfoutput><input name="FarcryFormSubmitButton" value="#attributes.Value#" type="#attributes.Type#" onclick="#attributes.Onclick#" class="#attributes.Class#" style="#attributes.Style#" src="#attributes.src#" /></cfoutput>
		<cfelse>
		
			<skin:htmlHead library="farcryForm" />
			<skin:htmlHead library="extjs" />
			
									
			<cfoutput>
				<div id="#attributes.id#-outer" class="farcryButtonWrap-outer" onmouseover="farcryButtonOnMouseOver('#attributes.id#');" onmouseout="farcryButtonOnMouseOut('#attributes.id#');" onclick="farcryButtonOnClick('#attributes.id#');"><div id="#attributes.id#-inner" class="farcryButtonWrap-inner"><button id="#attributes.id#" type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="farcryButton #attributes.Class#" style="#attributes.Style#" value="#attributes.value#">#attributes.Value#</button></div></div>
			</cfoutput>
			
		</cfif>
	<cfelse>
		<cfoutput><button type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="formButton #attributes.Class#" style="#attributes.Style#" value="#attributes.value#">#attributes.Value#</button></cfoutput>
	</cfif>
	</cfsavecontent>

	</cfsilent>
	
	<cfoutput>#Trim(buttonHTML)#</cfoutput>
</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">