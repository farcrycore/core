<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.onsubmit" default="">
<cfparam name="attributes.css" default="">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="attributes.heading" default="">

<cfparam name="Request.farcryForm.bAjaxSubmission" default="true" />
	
<cfif not len(attributes.class)>
	<cfset attributes.class = "formtool" />
</cfif>

<cfif thistag.ExecutionMode EQ "Start">
	
	<cfoutput>
		<cfif Request.farcryForm.bAjaxSubmission>
			<div id="#Request.farcryForm.Name#formwrap" class="ajaxformwrap">
		</cfif>
		
		<form action="#Request.farcryForm.Action#" method="#Request.farcryForm.Method#" id="#Request.farcryForm.Name#" name="#Request.farcryForm.Name#" <cfif len(request.farcryForm.Target)> target="#Request.farcryForm.Target#"</cfif> enctype="multipart/form-data" onsubmit="#attributes.onSubmit#" class="#attributes.class#"  style="#attributes.style#">
		<cfif Request.farcryForm.bAjaxSubmission>
			<div id="#Request.farcryForm.Name#ajaxsubmission" class="ajaxsubmission" style="position:absolute;width:100px;text-align:right;"></div>
		</cfif>
		
		<cfif len(attributes.heading)><h3>#attributes.Heading#</h3></cfif>
	</cfoutput> 
		
	<cfif len(attributes.css)>
		<cfloop list="#attributes.css#" index="i">
			<skin:htmlHead id="FormsCSS_#i#">
				<cfoutput>
					<link rel="stylesheet" href="#application.url.webroot#/css/#i#" type="text/css" media="all" />
				</cfoutput>
			</skin:htmlHead>
		</cfloop>
	<cfelse>
		<skin:htmlHead library="FormsCSS" />
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false" />