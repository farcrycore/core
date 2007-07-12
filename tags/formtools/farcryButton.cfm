<cfsetting enablecfoutputonly="yes">

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




<cfif thistag.ExecutionMode EQ "Start">

	<skin:htmlhead id="farcrybuttoncss">
	<cfoutput>
		<style type="text/css">
		
		.x-btn {
			width: 75px;
			float:left;
			margin-right:15px;
		}
		
		input.x-btn-text{
			width:auto !important;
			cursor:pointer;
			white-space: nowrap;
		    padding:0;
		    border-width:0px;
		    background:transparent;	   
		}
		
		.x-btn-left, .x-btn-right{
			font-size:1px;
		    line-height:1px;
		}
		.x-btn-left{
			width:3px;
			height:21px;
			background:url(/farcry/js/ext/resources/images/default/basic-dialog/btn-sprite.gif) no-repeat 0 0;
		}
		.x-btn-right{
			width:3px;
			height:21px;
			background:url(/farcry/js/ext/resources/images/default/basic-dialog/btn-sprite.gif) no-repeat 0 -21px;
		}
		.x-btn-left i, .x-btn-right i{
			display:block;
		    width:3px;
		    overflow:hidden;
		    font-size:1px;
		    line-height:1px;
		}
		.x-btn-center{
			background:url(/farcry/js/ext/resources/images/default/basic-dialog/btn-sprite.gif) repeat-x 0 -42px;
			vertical-align: middle;
			text-align:center;
			padding:0 5px;
			cursor:pointer;
			white-space:nowrap;
		}
		.x-btn-over .x-btn-left{
			background-position:0 -63px;
		}
		.x-btn-over .x-btn-right{
			background-position:0 -84px;
		}
		.x-btn-over .x-btn-center{
			background-position:0 -105px;
		}
		.x-btn-click .x-btn-center, .x-btn-menu-active .x-btn-center{
			background-position:0 -126px;
		}
		.x-btn-disabled *{
			color:gray !important;
			cursor:default !important;
		}	
		</style>
	</cfoutput>
	</skin:html>

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = "#attributes.OnClick#;$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.SelectedObjectID#';">
	</cfif>
	
	<cfif len(Attributes.ConfirmText)>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;if(confirm('#Attributes.ConfirmText#')) {dummyconfirmvalue=1} else {return false};">
	</cfif>	
	 
	
	<cfset attributes.onClick = "#attributes.onClick#;$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value = '#attributes.Value#';">


	
	<cfif Request.farcryForm.Validation AND Attributes.validate>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;return realeasyvalidation#Request.farcryForm.Name#.validate();">
		
		
		
	</cfif>	
	<cfoutput>
	<table class="x-btn-wrap x-btn" border="0" cellpadding="0" cellspacing="0" onmouseover="$(this.addClassName('x-btn-over'));" onmouseout="$(this.removeClassName('x-btn-over'));" style="border-width:0px;height:21px;width:0px;padding:0px;margin:0px;">
		<tbody>
			<tr>
				<td class="x-btn-left" style="border-width:0px;height:21px;width:0px;padding:0px;margin:0px;"><i>&nbsp;</i></td>
				<td class="x-btn-center" style="border-width:0px;height:21px;width:0px;padding:0px;margin:0px;"><input name="FarcryFormSubmitButton" value="#attributes.Value#" type="#attributes.Type#" onclick="#attributes.Onclick#" class="x-btn-text #attributes.Class#" style="#attributes.Style#" /></td>
				<td class="x-btn-right" style="border-width:0px;height:21px;width:0px;padding:0px;margin:0px;"><i>&nbsp;</i></td>
			</tr>
		</tbody>
	</table>
	</cfoutput>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">