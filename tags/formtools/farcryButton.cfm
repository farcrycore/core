<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." >
</cfif>

<cfparam  name="attributes.Type" default="submit">
<cfparam  name="attributes.Value" default="#Attributes.Type#">
<cfparam  name="attributes.Onclick" default="">
<cfparam  name="attributes.Class" default="">
<cfparam  name="attributes.Style" default="">
<cfparam name="attributes.SelectedObjectID" default="">
<cfparam name="attributes.ConfirmText" default="">
<cfparam name="attributes.validate" default="true">
<cfparam name="attributes.bInPanel" default="">
<cfparam name="attributes.src" default="">
<cfparam name="attributes.url" default="">
<cfparam name="attributes.target" default="_self">

<cfif thistag.ExecutionMode EQ "Start">

	<cfset buttonID = createUUID() />

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = "#attributes.OnClick#;$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.SelectedObjectID#';">
	</cfif>
	
	<cfif len(Attributes.ConfirmText)>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "if(confirm('#Attributes.ConfirmText#')) {dummyconfirmvalue=1} else {return false};#attributes.OnClick#;">
	</cfif>	
	 
	
	<cfset attributes.onClick = "#attributes.onClick#;$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value = '#attributes.Value#';">


	
	<cfif Request.farcryForm.Validation AND Attributes.validate>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;if(realeasyvalidation#Request.farcryForm.Name#.validate()) {dummyconfirmvalue=1} else {return false};">

	</cfif>	

	<cfif len(attributes.url)>
		<cfset attributes.OnClick = "#attributes.OnClick#;return farcryButtonURL('#buttonid#','#attributes.url#','#attributes.target#');">
	</cfif>

	<cfif not len(attributes.bInPanel)>
		<cfset ParentTag = GetBaseTagList()>
		<cfif ListFindNoCase(ParentTag, "cf_farcryButtonPanel")>
			<cfset attributes.bInPanel = true>
		<cfelse>
			<cfset attributes.bInPanel = false>
		</cfif>
	</cfif>
	
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
					height:21px;
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
				function farcryButtonOnMouseOver(buttonID) {
					$(buttonID + '-outer').addClassName('farcryButtonWrap-outer-hover');
					$(buttonID + '-inner').addClassName('farcryButtonWrap-inner-hover');
				}
				function farcryButtonOnClick(buttonID) {
					$(buttonID + '-outer').addClassName('farcryButtonWrap-outer-click');
					$(buttonID + '-inner').addClassName('farcryButtonWrap-inner-click');
				}
				function farcryButtonOnMouseOut(buttonID) {
					$(buttonID + '-outer').removeClassName('farcryButtonWrap-outer-hover');
					$(buttonID + '-inner').removeClassName('farcryButtonWrap-inner-hover');
					$(buttonID + '-outer').removeClassName('farcryButtonWrap-outer-click');
					$(buttonID + '-inner').removeClassName('farcryButtonWrap-inner-click');
				}
				function farcryButtonURL(buttonID,url,target) {
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
				<div id="#buttonID#-outer" class="farcryButtonWrap-outer" onmouseover="farcryButtonOnMouseOver('#buttonID#');" onmouseout="farcryButtonOnMouseOut('#buttonID#');" onclick="farcryButtonOnClick('#buttonID#');"><div id="#buttonID#-inner" class="farcryButtonWrap-inner"><button id="#buttonID#" type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="farcryButton #attributes.Class#" style="#attributes.Style#">#attributes.Value#</button></div></div>
			</cfoutput>
	
			
		</cfif>
	<cfelse>
		<cfoutput><button type="#attributes.Type#" name="FarcryForm#attributes.Type#Button" onclick="#attributes.Onclick#" class="formButton #attributes.Class#" style="#attributes.Style#">#attributes.Value#</button></cfoutput>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">