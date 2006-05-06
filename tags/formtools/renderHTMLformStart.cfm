<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfparam name="attributes.onsubmit" default="">
<cfparam name="attributes.css" default="">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.heading" default="">
<cfif thistag.ExecutionMode EQ "Start">
	
	<cfoutput  >
		<form action="#Request.farcryForm.Action#" method="post" id="#Request.farcryForm.Name#" name="#Request.farcryForm.Name#" target="#Request.farcryForm.Target#" enctype="multipart/form-data" onsubmit="#attributes.onSubmit#" class="#attributes.class#" style="#attributes.style#">

		<cfif len(attributes.heading)><h3>#attributes.Heading#</h3></cfif>
		 
		<cfif len(attributes.css)>
			<cfloop list="#attributes.css#" index="i">
				<link rel="stylesheet" href="#application.url.webroot#/css/#i#" type="text/css" media="all" />
			</cfloop>
		</cfif>
		
	</cfoutput>
	
</cfif>




