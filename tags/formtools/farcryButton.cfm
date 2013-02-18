<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.value" /><!--- @@hint: The event submitted and captured by an ft:processForm tag. @@required: true --->
<cfparam name="attributes.type" default="" /><!--- button or submit. Default is 'submit' if inside an ft:form and 'button' if not. --->
<cfparam name="attributes.text" default="#attributes.value#" /><!--- The text that will appear on the button. Default is the value. --->
<cfparam name="attributes.id" default="f-btn-#application.fapi.getUUID()#"><!--- The unique id of the button --->
<cfparam name="attributes.validate" default=""><!--- Should the form be validated before the onClick event is fired. Default is 'true' for type submit and 'false' for buttons. --->
<cfparam name="attributes.SelectedObjectID" default=""><!--- A value that will be placed in the hidden form field form.selectedObjectID on submission. --->
<cfparam name="attributes.onClick" default=""><!--- javascript that will be run when the user clicks this button --->
<cfparam name="attributes.Class" default=""><!--- Any css classes that are to be added to the button --->
<cfparam name="attributes.Style" default=""><!--- Any css styles that are to be added to the button. --->
<cfparam name="attributes.ConfirmText" default=""><!--- A confirmation message that will appear before submission --->
<cfparam name="attributes.url" default=""><!--- A URL that you would like the button to redirect the page too. --->
<cfparam name="attributes.target" default="_self"><!--- The target for the url page to be redirected too. --->
<cfparam name="attributes.bSpamProtect" default="false"><!--- Instantiates cfformprotection to ensure the button is not clicked by spam. --->
<cfparam name="attributes.stSpamProtectConfig" default="#structNew()#" /><!--- config data that will override the config set in the webtop. --->
<cfparam name="attributes.rbkey" default="forms.buttons.#rereplacenocase(attributes.value,'[^\w\d]','','ALL')#"><!--- The resource path for this button. Default is forms.buttons.value. --->
<cfparam name="attributes.disabled" default="false"><!--- Should the button be disabled --->
<cfparam name="attributes.r_stButton" default=""><!--- the name of the calling scope variable name to return the details of the farcry button --->
<cfparam name="attributes.renderType" default="farcryButton"><!--- How should the button be rendered (button, link) --->
<cfparam name="attributes.primaryAction" default="" /><!--- Is this button a primary action on the form --->
<cfparam name="attributes.bDefaultAction" default="false" /><!--- Default action when someone presses enter on a form. --->
<cfparam name="attributes.icon" default="" /><!--- The jquery-ui icon to use --->

<cfif not thistag.HasEndTag>
	<cfabort showerror="FarCry Buttons must have an end tag...">
</cfif>
	
	
<cfif thistag.executionMode eq "End">

	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-jquery-ui" />
	<skin:loadJS id="farcry-form" />
	
	<skin:loadCSS id="jquery-ui" />

	<!--- I18 conversion of label --->
	<cfset attributes.text = application.rb.getResource('#attributes.rbkey#@label',attributes.text) />
	
	<!--- If not in a farcry form, default the type as a button. --->
	<cfif NOT isDefined("Request.farcryForm.Name")>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "button" />
		</cfif>
	
	<!--- Otherwise default to submit --->
	<cfelse>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "submit" />
		</cfif>
	</cfif>


	<!--- Default validate to true if submitting and false if just a button --->
	<cfif not len(attributes.validate)>
		<cfif attributes.type EQ "submit">
			<cfset attributes.validate = true />
		<cfelse>
			<cfset attributes.validate = false />
		</cfif>
	</cfif>
	
	<!--- run the button click event if in a form --->
	<cfif isDefined("Request.farcryForm.Name")>
		<cfset attributes.onClick = listAppend(attributes.onClick, "btnClick('#Request.farcryForm.Name#','#jsStringFormat(attributes.value)#')", ";")  />
	</cfif>
	
	<!--- ONLY ADD JS VALIDATION IF VALIDATION LOADED IN THE ft:form --->
	<cfif isDefined("Request.farcryForm.Name") AND Request.farcryForm.Validation>
		<cfif attributes.validate>
			<cfset attributes.onClick = listAppend(attributes.onClick, "btnTurnOnServerSideValidation()", ";") />
		<cfelse>
			<cfset attributes.onClick = listAppend(attributes.onClick, "btnTurnOffServerSideValidation()", ";") />
			<cfset attributes.class = listAppend(attributes.class, "cancel", " ") />
		</cfif>		
	</cfif>
	
	<!--- A value that will be placed in the hidden form field form.selectedObjectID on submission. --->
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = listAppend(attributes.onClick, "selectedObjectID('#attributes.SelectedObjectID#')", ";") />
	</cfif>

	<!--- A URL that you would like the button to redirect the page too. --->
	<cfif len(attributes.url)>
		<cfset attributes.Type = "button" />
		<cfset attributes.url = jsStringFormat(attributes.url) />
		<cfset attributes.onClick = listAppend(attributes.onClick, "btnURL('#attributes.url#','#attributes.target#')", ";") />
	</cfif>

	<!--- If we are not validating, we need to update the attribute on the form --->
	<cfif isDefined("Request.farcryForm.Name") AND NOT attributes.validate>
		<cfset attributes.onClick = listPrepend(attributes.onClick, "$j('###Request.farcryForm.Name#').attr('fc:validate',false)", ";") />
	</cfif>
	
	<!--- Make sure that confirmation is run first for a button --->
	<cfif len(Attributes.ConfirmText)>
		<!--- I18 conversion of label --->
		<cfset attributes.confirmText = application.rb.getResource('#attributes.rbkey#@confirmtext',attributes.confirmText) />
		<cfset attributes.confirmText = jsStringFormat(attributes.confirmText) />
		<cfset attributes.onClick = listPrepend(attributes.onClick, "if(!confirm('#Attributes.ConfirmText#')){return false}", ";") />
	</cfif>
	
	
	
	<cfif attributes.type EQ "submit">
		<cfset attributes.onClick = "#attributes.onClick#;#request.farcryForm.onSubmit#;btnSubmit('#Request.farcryForm.Name#','#jsStringFormat(attributes.value)#');" />	
	</cfif>
	
	
	<!--- Set the default action if requested --->
	<cfif isDefined("Request.farcryForm.defaultAction")>
		<cfif attributes.bDefaultAction OR (attributes.Type EQ "submit" AND not len(Request.farcryForm.defaultAction))>
			<cfset Request.farcryForm.defaultAction = attributes.value />
		</cfif>
	</cfif>
	
	<!--- Output the button if not just returning the info --->
	<cfif not len(attributes.r_stButton)>
		<cfswitch expression="#attributes.renderType#">
		<cfcase value="link">
			<cfoutput><a id="#attributes.id#" name="#attributes.id#" class="#attributes.class#" style="#attributes.style#" href="##">#attributes.text#</a></cfoutput>
		</cfcase>
		<cfdefaultcase>
			<cfset buttonSettings = "" />
			 
			<cfif len(attributes.icon)>
				<cfset buttonSettings = listAppend(buttonSettings, "icons: {primary: '#attributes.icon#'}") />
			</cfif>
			
			<cfif not len(attributes.text)>
				<cfset buttonSettings = listAppend(buttonSettings, "text: false") />
				<cfset attributes.text = "&nbsp;" />
			</cfif>		
			
			<cfoutput><button id="#attributes.id#" name="FarcryForm#attributes.Type#Button=#attributes.value#" type="#attributes.type#" value="#attributes.value#" class="#attributes.class#" style="#attributes.style#;" <cfif attributes.disabled>disabled</cfif>>#attributes.text#</button></cfoutput>
				

			<skin:onReady>
			<cfoutput>	
			$j("###attributes.id#").button({#buttonSettings#});
			</cfoutput>
			</skin:onReady>
				
		</cfdefaultcase>
		</cfswitch>

		
		<cfif len(attributes.onClick)>
			<skin:onReady>
			<cfoutput>
			$j("###attributes.id#").click(function() {
				#attributes.OnClick#
				return false;
			});
			</cfoutput>
			</skin:onReady>
		</cfif>
		

		<cfif attributes.bSpamProtect AND isDefined("Request.farcryForm.Name")>
		
			<cfif not structKeyExists(request, "bRenderFormSpamProtection")>
				<cfinclude template="#application.url.webtop#/cffp/cfformprotect/cffp.cfm" /> 
				<cfset request.bRenderFormSpamProtection = "rendered" />
			</cfif>
			
			<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#'] = structNew() />
			<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#'].bSpamProtect = true />
			<cfloop list="#structKeyList(attributes)#" index="protectionAttribute">
				<cfif findNoCase("protection_", protectionAttribute)>
					<cfset protectionAttributeName = mid(protectionAttribute,12,len(protectionAttribute)) />
					<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#']['#protectionAttributeName#'] = attributes["#protectionAttribute#"] />
				</cfif>
			</cfloop>
			<cfloop collection="#attributes.stSpamProtectConfig#" item="protectionAttributeName">
				<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#']['#protectionAttributeName#'] = attributes.stSpamProtectConfig["#protectionAttribute#"] />
			</cfloop>
		</cfif>		
	<cfelse>
		<cfset caller[attributes.r_stButton] = duplicate(attributes) />
		<cfset caller[attributes.r_stButton].name = "FarcryForm#attributes.Type#Button=#attributes.value#">
	</cfif>
</cfif>