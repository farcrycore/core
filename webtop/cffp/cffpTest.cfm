
<cfset cffp = CreateObject("component","farcry.core.webtop.cffp.cfformprotect.cffpVerify").init(ConfigPath="#application.path.core#/webtop/cffp/cfformprotect") />
<html>
	<head><title>test</title></head>
<body onload="document.frmAwesome.Submit.focus()">
<cfif StructKeyExists(form,"FieldNames")>
<div style="border:1px solid black;padding:20px;margin:20px;">
Results:
<cfdump var=#cffp.testSubmission(form)# />
</div>
</cfif>
<div style="border:1px solid black;padding:20px;margin:20px;">
	<form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" name="frmAwesome">
		<div>Name:<input type="text" name="FullName" id="FullName" value="<cftry><cfoutput>#form.FullName#</cfoutput><cfcatch/></cftry>"></div>
		<div><textarea name="Comment" style="height:100px;width:400px;"><cftry><cfoutput>#form.Comment#</cfoutput><cfcatch/></cftry></textarea></div>
		<div><input name="Submit" id="Submit" type="submit" value="submit" /></div>
		<cfinclude template="#application.url.webtop#/cffp/cfformprotect/cffp.cfm" />
	</form>
</div>

</body>
</html>
<cfdump var=#form#>