<cfsetting enablecfoutputonly="yes">

<cfsilent>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." >
</cfif>

<cfparam  name="attributes.id" default="#createUUID()#">
<cfparam  name="attributes.Type" default="submit">
<cfparam  name="attributes.Value" default="#Attributes.Type#">
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
		
			<skin:htmlhead id="farcryButtonHTMLHead">
			<cfoutput>
				<style type="text/css">
				
				div.farcryButtonWrap-outer{
					background:transparent url(#application.url.farcry#/css/forms/images/farcryButtonSprite-left.gif) no-repeat top left;
					border:0px;
					padding:0px 15px 0px 0px;
					margin:0px 0px 0px 0px;
					height:21px;
					float:left;
					
				}
				div.farcryButtonWrap-inner{
					background:transparent url(#application.url.farcry#/css/forms/images/farcryButtonSprite-right.gif) no-repeat top right;
					border:0px solid green;
					padding:0px 3px 0px 0px;
					margin:0px 0px 0px 3px;
					float:none;
				}	
				
				button.farcryButton{
					border:0px solid red;
					padding:0px 0px 0px 0px;
					margin:0px 0px 0px 0px;
					vertical-align:middle;					
					background:transparent;
					background-image:none;
					height:21px;
					width:auto;
					text-align:center;
					overflow:hidden;
					font-size:11px;
				}			
				div.farcryButtonWrap-outer-hover{
					background-position: bottom left;					
				}
				div.farcryButtonWrap-inner-hover{
					background-position: center right;
				}
				div.farcryButtonWrap-outer-click{
					background-position: bottom left;					
				}
				div.farcryButtonWrap-inner-click{
					background-position: bottom right;
				}
				</style>
				
				<script type="text/javascript">
				function farcryButtonOnMouseOver(id) {
					$(id + '-outer').addClassName('farcryButtonWrap-outer-hover');
					$(id + '-inner').addClassName('farcryButtonWrap-inner-hover');
				}
				function farcryButtonOnClick(id) {
					$(id + '-outer').addClassName('farcryButtonWrap-outer-click');
					$(id + '-inner').addClassName('farcryButtonWrap-inner-click');
				}
				function farcryButtonOnMouseOut(id) {
					$(id + '-outer').removeClassName('farcryButtonWrap-outer-hover');
					$(id + '-inner').removeClassName('farcryButtonWrap-inner-hover');
					$(id + '-outer').removeClassName('farcryButtonWrap-outer-click');
					$(id + '-inner').removeClassName('farcryButtonWrap-inner-click');
				}
				function farcryButtonURL(id,url,target) {
					if (target == 'undefined' || target == '_self'){
						location.href=url;			
						return false;
					} else {
						win = window.open('',target);	
						win.location=url;	
						win.focus;			
						return false;
					}
				}
				</script>
			</cfoutput>
			</skin:htmlhead>	
						
			<cfoutput>
				<div id="#attributes.id#-outer" class="farcryButtonWrap-outer" onmouseover="farcryButtonOnMouseOver('#attributes.id#');" onmouseout="farcryButtonOnMouseOut('#attributes.id#');" onclick="farcryButtonOnClick('#attributes.id#');"><div id="#attributes.id#-inner" class="farcryButtonWrap-inner"><button id="#attributes.id#" type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="farcryButton #attributes.Class#" style="#attributes.Style#">#attributes.Value#</button></div></div>
			</cfoutput>
	
			
		</cfif>
	<cfelse>
		<cfoutput><button type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="formButton #attributes.Class#" style="#attributes.Style#">#attributes.Value#</button></cfoutput>
	</cfif>
	</cfsavecontent>

	</cfsilent>
	
	<cfoutput>#Trim(buttonHTML)#</cfoutput>
</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">