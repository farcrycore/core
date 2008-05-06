<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.value" />
<cfparam name="attributes.type" default="" />
<cfparam name="attributes.text" default="#attributes.value#" />
<cfparam name="attributes.size" default="medium" />
<cfparam name="attributes.color" default="blue" />
<cfparam name="attributes.icon" default="" />
<cfparam name="attributes.overIcon" default="" />
<cfparam name="attributes.iconPos" default="left" /><!--- left,right,top,bottom --->
<cfparam name="attributes.sprite" default="" />
<cfparam name="attributes.id" default="f-btn-#createUUID()#">
<cfparam name="attributes.width" default="auto">
<cfparam name="attributes.validate" default="">
<cfparam name="attributes.SelectedObjectID" default="">
<cfparam name="attributes.onClick" default="">
<cfparam name="attributes.Class" default="">
<cfparam name="attributes.Style" default="">
<cfparam name="attributes.ConfirmText" default="">
<cfparam name="attributes.src" default="">
<cfparam name="attributes.url" default="">
<cfparam name="attributes.target" default="_self">
<cfparam name="attributes.bSpamProtect" default="false"><!--- Instantiates cfformprotection to ensure the button is not clicked by spam. --->
<cfparam name="attributes.stSpamProtectConfig" default="#structNew()#" /><!--- config data that will override the config set in the webtop. --->
<cfparam name="attributes.rbkey" default="forms.buttons.#rereplacenocase(attributes.value,'[^\w\d]','','ALL')#">
<cfparam name="attributes.disabled" default="false"><!--- Should the button be disabled --->


<cfif thistag.executionMode eq "End">

	<!--- Include Prototype light in the head --->
	<skin:htmlHead library="extCorejs" />
	<skin:htmlHead library="farcryForm" />

	<!--- I18 conversion of label --->
	<cfset attributes.value = application.rb.getResource('#attributes.rbkey#@label',attributes.value) />
	
	<!--- If not in a farcry form, make it a button. --->
	<cfif NOT isDefined("Request.farcryForm.Name")>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "button" />
		</cfif>
	<cfelse>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "submit" />
		</cfif>
	</cfif>
	
	<cfif attributes.disabled>
		<cfset attributes.onClick = "#attributes.onClick#;return false;" />
	</cfif>

	<!--- Default validate to true if submitting and false if just a button --->
	<cfif not len(attributes.validate)>
		<cfif attributes.type EQ "submit">
			<cfset attributes.validate = true />
		<cfelse>
			<cfset attributes.validate = false />
		</cfif>
	</cfif>
	
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = "#attributes.OnClick#;selectedObjectID('#attributes.SelectedObjectID#');" />
	</cfif>
	
	<cfif len(Attributes.ConfirmText)>
			<!--- I18 conversion of label --->
	<cfset Attributes.ConfirmText = application.rb.getResource('#attributes.rbkey#@confirmtext',Attributes.ConfirmText) />
	
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "if(confirm('#Attributes.ConfirmText#')) {dummyconfirmvalue=1} else {return false};#attributes.OnClick#;">
	</cfif>	

	
	<cfif isDefined("Request.farcryForm.Name") AND Request.farcryForm.Validation AND Attributes.validate>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;if(realeasyvalidation#Request.farcryForm.Name#.validate()) {dummyconfirmvalue=1} else {return false};">

	</cfif>	

	<cfif len(attributes.url)>
		<cfset attributes.OnClick = "#attributes.OnClick#;return fBtnURL('#attributes.id#','#attributes.url#','#attributes.target#');">
	</cfif>

<!--- 	<cfif isDefined("Request.farcryForm.Name") AND attributes.type EQ "submit">
		<cfset attributes.OnClick = "#attributes.OnClick#;document.#Request.farcryForm.Name#.submit();">
	</cfif> --->
	
	
	
	<!--- This is used to submit the form using JS if the user clicks on the table. --->
	<cfif isDefined("Request.farcryForm.Name")>
		<cfset farcryFormName = Request.farcryForm.Name />
	<cfelse>
		<cfset farcryFormName = "" />
	</cfif>
	
	<cfswitch expression="#attributes.color#">
	<cfcase value="red">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-red.gif" />
	</cfcase>
	<cfcase value="green">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-green.gif" />
	</cfcase>
	<cfcase value="orange">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-orange.gif" />
	</cfcase>
	<cfdefaultcase>
		<!--- EVERYTHING ELSE IS BLUE --->
	</cfdefaultcase>
	</cfswitch>

	<cfoutput>
	<span id="#attributes.id#-wrap" class="#attributes.class#" style="#attributes.Style#">
		<button id="#attributes.id#" name="FarcryForm#attributes.Type#Button=#attributes.value#" type="#attributes.type#" value="#attributes.value#" class="f-btn-text">#attributes.text#</button>
	</span>
	</cfoutput>
		
	<extjs:onReady>
		<cfoutput>newFarcryButton('#attributes.id#', '#lcase(attributes.type)#', '#lcase(attributes.size)#','#attributes.value#','#attributes.text#','#attributes.icon#','#attributes.overIcon#','#attributes.iconPos#', '#attributes.sprite#', '#attributes.width#','#farcryFormName#', '#jsStringFormat(attributes.OnClick)#', '#lcase(yesNoFormat(attributes.disabled))#');</cfoutput>
	</extjs:onReady>

</cfif>