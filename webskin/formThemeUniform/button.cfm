
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


<cfif thistag.executionMode eq "End">

	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-jquery-ui" />
	<skin:loadJS id="farcry-form" />
	
	<skin:loadCSS id="jquery-ui" />
	<skin:loadCSS id="fc-uniform" />

	<cfset stSettings = structNew()>
	<cfif not len(attributes.text)>
		<cfset stSettings.text = false>
		
		<cfset attributes.text = "&nbsp;" />
	</cfif>
	
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
		<cfset attributes.text = "" />
	</cfif>		
	
	
	
	
	<cfif len(attributes.priority)>	
		
		<cfif listFindNoCase(GetBaseTagList(),"cf_splitButton") AND attributes.renderType EQ "link">
			<!--- NO PRIORITY IN SPLIT BUTTON LINKS --->
		<cfelse>
			<cfset attributes.class = listAppend(attributes.class, "ui-priority-#attributes.priority#", " ")>
		</cfif>
	</cfif>
	
	
	<cfoutput>
		<button id="#attributes.id#" 
				name="FarcryForm#attributes.Type#Button=#attributes.value#" 
				type="#attributes.type#" value="#attributes.value#" 
				<cfif len(attributes.title)> title="#attributes.title#"</cfif> 
				class="fc-btn jquery-ui-btn #attributes.class#" 
				style="#attributes.style#" <cfif attributes.disabled>disabled</cfif> 
				<cfif len(attributes.textOnClick)>fc:textOnClick="#attributes.textOnClick#"</cfif> 
				<cfif len(attributes.textOnSubmit)>fc:textOnSubmit="#attributes.textOnSubmit#"</cfif> 
				<cfif attributes.disableOnSubmit>fc:disableOnSubmit="1"</cfif>>
					#attributes.text#
				</button>
	</cfoutput>
	
	<cfset buttonsettings = lcase( SerializeJSON( stSettings ) )>
	
	<skin:onReady>
		<cfoutput>
		$j('###attributes.id#').button( #buttonsettings# );</cfoutput>
	</skin:onReady>
</cfif>