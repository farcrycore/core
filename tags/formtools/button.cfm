<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.value" /><!--- @@hint: The event submitted and captured by an ft:processForm tag. @@required: true --->
<cfparam name="attributes.type" default="submit" /><!--- button or submit. Default is 'submit'. --->
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
<cfparam name="attributes.rbkey" default="forms.buttons.#rereplacenocase(attributes.text,'[^\w\d]','','ALL')#"><!--- The resource path for this button. Default is forms.buttons.value. --->
<cfparam name="attributes.disabled" default="false"><!--- Should the button be disabled --->
<cfparam name="attributes.r_stButton" default=""><!--- the name of the calling scope variable name to return the details of the farcry button --->
<cfparam name="attributes.renderType" default="farcryButton"><!--- How should the button be rendered (button, link, farcryButton(default)) --->
<cfparam name="attributes.primaryAction" default="" /><!--- Is this button a primary action on the form --->
<cfparam name="attributes.bDefaultAction" default="false" /><!--- Default action when someone presses enter on a form. --->
<cfparam name="attributes.icon" default="" /><!--- The jquery-ui icon to use --->
<cfparam name="attributes.title" default="" /><!--- The title of the button --->
<cfparam name="attributes.priority" default="" /><!--- the level of button (primary,secondary,tertiary) --->
<cfparam name="attributes.textOnClick" default="" /><!--- what should the text change to when the button is clicked.  --->
<cfparam name="attributes.textOnSubmit" default="" /><!--- what should the text change to when the button is submitted.  --->
<cfparam name="attributes.disableOnSubmit" default="true" /><!--- should the button be disabled when the form is submitted --->

<cfif not thistag.HasEndTag>
	<cfabort showerror="FarCry Buttons must have an end tag...">
</cfif>
	
	
<cfif thistag.executionMode eq "End">

	<skin:loadJS id="jquery" />
	<skin:loadJS id="jquery-ui" />
	<skin:loadJS id="farcry-form" />
	
	<skin:loadCSS id="jquery-ui" />
	
	
	<cfif not len(attributes.priority) AND len(attributes.text)>	
		<cfif listFindNoCase(GetBaseTagList(),"cf_buttonPanel")>
			
			<cfset THISTAG.Parent = GetBaseTagData( "cf_buttonPanel" ) />
				
			<cfif structKeyExists(THISTAG.Parent, "bPrimaryDefined") AND NOT THISTAG.Parent.bPrimaryDefined>
				<cfset attributes.priority = "primary">
				
				<cfset THISTAG.Parent.bPrimaryDefined = true>
			<cfelse>
				<cfset attributes.priority = "secondary">
			</cfif>
		<cfelse>
			<cfset attributes.priority = "secondary">
		</cfif>
	</cfif>
	<cfif len(attributes.priority)>	
	
		
		<cfif listFindNoCase(GetBaseTagList(),"cf_splitButton") AND attributes.renderType EQ "link">
			<!--- NO PRIORITY IN SPLIT BUTTON LINKS --->
		<cfelse>
			<cfset attributes.class = listAppend(attributes.class, "ui-priority-#attributes.priority#", " ")>
		</cfif>
	</cfif>
	
	
	<cfset stButtonAttributes = structNew()>

	<!--- I18 conversion of label --->
	<cfset attributes.text = application.rb.getResource('#attributes.rbkey#@label',attributes.text) />
	
	<cfif not len(attributes.title)>
		<cfif len(attributes.text)>
			<cfset attributes.title = attributes.text>
		<cfelse>
			<cfset attributes.title = attributes.value>
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
		<!--- <cfset attributes.onClick = listAppend(attributes.onClick, "btnClick('#Request.farcryForm.Name#','#jsStringFormat(attributes.value)#')", ";")  /> --->
		
		<cfset stButtonAttributes.click = jsStringFormat(attributes.value)>
	</cfif>
	
	<!--- ONLY ADD JS VALIDATION IF VALIDATION LOADED IN THE ft:form --->
	<cfif isDefined("Request.farcryForm.Name") AND Request.farcryForm.Validation>
		<cfif attributes.validate>
			<!--- <cfset attributes.onClick = listAppend(attributes.onClick, "btnTurnOnServerSideValidation()", ";") /> --->
			<cfset stButtonAttributes.turnonserversidevalidation = 1>
		<cfelse>
			<!--- <cfset attributes.onClick = listAppend(attributes.onClick, "btnTurnOffServerSideValidation()", ";") /> --->
			<cfset attributes.class = listAppend(attributes.class, "cancel", " ") />
			
			<cfset stButtonAttributes.turnoffserversidevalidation = 1>
		</cfif>		
	</cfif>
	
	<!--- A value that will be placed in the hidden form field form.selectedObjectID on submission. --->
	<cfif len(attributes.SelectedObjectID)>		
		<!--- <cfset attributes.Onclick = listAppend(attributes.onClick, "selectedObjectID('#attributes.SelectedObjectID#')", ";") /> --->
		
		<cfset attributes.class = listAppend(attributes.class, "fc-action-selected-object-id", " ") />
		<cfset stButtonAttributes.selectedobjectid = attributes.SelectedObjectID>
	</cfif>

	<!--- A URL that you would like the button to redirect the page too. --->
	<cfif len(attributes.url)>
		<cfset attributes.Type = "button" />
		<cfset attributes.url = jsStringFormat(attributes.url) />
		<!--- <cfset attributes.onClick = listAppend(attributes.onClick, "btnURL('#attributes.url#','#attributes.target#')", ";") /> --->
		
		<cfset stButtonAttributes.url = attributes.url>
		<cfset stButtonAttributes.target = attributes.target>
	</cfif>

	<!--- If we are not validating, we need to update the attribute on the form --->
	<cfif isDefined("Request.farcryForm.Name") AND NOT attributes.validate>
		<!--- <cfset attributes.onClick = listPrepend(attributes.onClick, "$j('###Request.farcryForm.Name#').attr('fc:validate',false)", ";") /> --->
		
		<cfset stButtonAttributes.turnoffclientsidevalidation = 1>
	</cfif>
	
	<!--- Make sure that confirmation is run first for a button --->
	<cfif len(Attributes.ConfirmText)>
		<!--- I18 conversion of label --->
		<cfset attributes.confirmText = application.rb.getResource('#attributes.rbkey#@confirmtext',attributes.confirmText) />
		<cfset attributes.confirmText = jsStringFormat(attributes.confirmText) />
		<!--- <cfset attributes.onClick = listPrepend(attributes.onClick, "if(!confirm('#Attributes.ConfirmText#')){return false}", ";") /> --->
		
		<cfset attributes.class = listAppend(attributes.class, "fc-action-confirm-text", " ") />
		<cfset stButtonAttributes.confirmtext = jsstringformat(Attributes.ConfirmText)>
	</cfif>
	

	<cfif attributes.bDefaultAction>
		<cfset attributes.class = listAppend(attributes.class, "defaultAction", " ") />
	</cfif>		
	
	
	<cfif attributes.type EQ "submit">
		<cfif isDefined("request.farcryForm.onSubmit") AND len(request.farcryForm.onSubmit)>
			<cfset attributes.onClick = listAppend(attributes.onClick,"#request.farcryForm.onSubmit#",";") >
		</cfif>
		<!--- <cfset attributes.onClick = "#attributes.onClick#;#request.farcryForm.onSubmit#;btnSubmit('#Request.farcryForm.Name#','#jsStringFormat(attributes.value)#');" />	 --->
	
		<cfset stButtonAttributes.submit = jsstringformat(attributes.value)>
	
	</cfif>
	
	<!--- Set the default action if requested --->
	<cfif isDefined("Request.farcryForm.defaultAction")>
		<cfif attributes.bDefaultAction OR (attributes.Type EQ "submit" AND not len(Request.farcryForm.defaultAction))>
			<cfset Request.farcryForm.defaultAction = attributes.value />
		</cfif>
	</cfif>
	
	<cfif len(attributes.onClick)>
		<cfset stButtonAttributes.onclick = attributes.onClick>
	</cfif>
	<!--- 
	<cfwddx input="#stButtonAttributes#" output="fcSettings" action="cfml2js" topLevelVariable="fcSettings" /> --->

	

	<!--- Output the button if not just returning the info --->
	<cfif not len(attributes.r_stButton)>
		<cfswitch expression="#attributes.renderType#">
		<cfcase value="link">
			
			<cfif NOT listFindNoCase(GetBaseTagList(),"cf_splitButton")>
				<cfset attributes.class = listPrepend(attributes.class, "fc-btn", " ")>
			</cfif>
			
			<cfoutput><a id="#attributes.id#" name="#attributes.id#" <cfif len(attributes.title)> title="#attributes.title#"</cfif> class="#attributes.class#" style="#attributes.style#" href="##">#attributes.text#</a></cfoutput>
		</cfcase>
		<cfcase value="button">
			<cfoutput><button id="#attributes.id#" name="FarcryForm#attributes.Type#Button=#attributes.value#" type="#attributes.type#" value="#attributes.value#" <cfif len(attributes.title)> title="#attributes.title#"</cfif> class="fc-btn #attributes.class#" style="#attributes.style#;" <cfif attributes.disabled>disabled</cfif>>#attributes.text#</button></cfoutput>
		</cfcase>
		
		<!--- Default FarcryButton --->
		<cfdefaultcase>
			<cfset attributes.class = listAppend(attributes.class, "jquery-ui-btn", " ") />
			<cfset stButtonAttributes.buttonsettings = "">
			<cfset stSettings = structNew()>
			 
			<cfif listLen(attributes.icon)>
				<cfset stSettings.icons = structNew()>
				<cfif len(trim(listFirst(attributes.icon)))>
					<cfset stSettings.icons.primary = trim(listFirst(attributes.icon))>
				</cfif>
				<cfif listLen(attributes.icon) GT 1 AND  len(trim(listLast(attributes.icon)))>
					<cfset stSettings.icons.secondary = trim(listLast(attributes.icon))>
				</cfif>
			</cfif>
			
			<cfif not len(attributes.text)>
				<cfset stSettings.text = false>
				
				<cfset attributes.text = "&nbsp;" />
			</cfif>		
			
			<cfoutput>
				<button id="#attributes.id#" name="FarcryForm#attributes.Type#Button=#attributes.value#" type="#attributes.type#" value="#attributes.value#" <cfif len(attributes.title)> title="#attributes.title#"</cfif> class="fc-btn #attributes.class#" style="#attributes.style#" <cfif attributes.disabled>disabled</cfif> <cfif len(attributes.textOnClick)>fc:textOnClick="#attributes.textOnClick#"</cfif> <cfif len(attributes.textOnSubmit)>fc:textOnSubmit="#attributes.textOnSubmit#"</cfif> <cfif attributes.disableOnSubmit>fc:disableOnSubmit="1"</cfif>>#attributes.text#</button></cfoutput>
				

			
			<cfset buttonsettings = lcase( SerializeJSON( stSettings ) )>
			
			<skin:onReady>
				<cfoutput>
				$j('###attributes.id#').button( #buttonsettings# );</cfoutput>
			</skin:onReady>
			
			
		</cfdefaultcase>
		</cfswitch>
	
	
		<cfset fcSettings = SerializeJSON(stButtonAttributes)>
		<skin:onReady>
			<cfoutput>
			$j('###attributes.id#').data('fcSettings', #fcSettings#);</cfoutput>
		</skin:onReady>
		
		
		
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

