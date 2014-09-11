<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Send an email --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfparam name="form.to" default="" />
<cfparam name="form.bcc" default="" />
<cfparam name="form.from" default="#application.fapi.getConfig("general","adminemail")#" />
<cfparam name="form.replyto" default="" />
<cfparam name="form.subject" default="" />
<cfparam name="form.bodyPlain" default="" />
<cfparam name="form.bodyHTML" default="" />

<cfif isdefined("url.search")>
	<cfparam name="url.page" default="1" />
	
	<cfquery datasource="#application.dsn#" name="q">
		select		firstname,lastname,emailaddress
		from		dmProfile
		where		firstname & ' ' & lastname & ' ' & ' ' & emailaddress like '%#url.search#%'
		order by	lastname, firstname, emailaddress
	</cfquery>
	
	<cfset aResult = arraynew(1) />
	<cfloop query="q">
		<cfset stResult = structnew() />
		<cfset stResult.id = q.email />
		<cfset stResult.label = "#q.firstname# #q.lastname# <#q.email#>" />
		<cfset arrayappend(aResult,stResult) />
		
		<cfif q.currentrow gte 15>
			<cfbreak />
		</cfif>
	</cfloop>
	
	<cfcontent type="application/json" variable="#ToBinary( ToBase64( serializeJSON(aResult) ) )#" reset="yes" />
</cfif>

<ft:processform action="Send Email">
	<cfif isdefined("form.attachment") and len(form.attachment)>
		<cffile action="upload" filefield="attachment" destination="#gettempdirectory()#" nameConflict="overwrite" />
		<cfset form.attachment = cffile.ServerDirectory & "/" & cffile.serverfile />
	</cfif>
	
	<cfset result = application.fc.lib.email.send(to=form.to,bcc=form.bcc,from=form.from,subject=form.subject,bodyPlain=form.bodyPlain,bodyHTML=form.bodyHTML,attachment=form.attachment) />
	
	<cfif isdefined("form.attachment") and len(form.attachment)>
		<cffile action="delete" file="#form.attachment#" />
	</cfif>
	
	<cfif result eq "Success">
		<skin:bubble message="Email successfully sent" tags="email,success" />
	<cfelse>
		<skin:bubble message="#result#" tags="email,error" />
	</cfif>
</ft:processform>


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="tinymce" />
<skin:onReady><cfoutput>
	tinymce.init({

		selector: '##bodyHTML',

		script_url : '#application.url.webtop#/thirdparty/tiny_mce/tinymce.min.js',

		plugins : "farcrycontenttemplates,layer,table,hr,image_farcry,link_farcry,insertdatetime,media,searchreplace,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,anchor,charmap,code,textcolor",
		extended_valid_elements: "code,colgroup,col,thead,tfoot,tbody,abbr,blockquote,cite,button,textarea[name|class|cols|rows],script[type],img[style|class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]",
		menubar : false,
		toolbar : "undo redo | cut copy paste pastetext | styleselect | bold italic underline | bullist numlist link image table | code",
		remove_linebreaks : false,
		forced_root_block : 'p',
		relative_urls : false,
		entity_encoding : 'raw',
		
		width : "98%",
		height : "280px"
	});
</cfoutput></skin:onReady>

<admin:header>

<ft:form>
	<cfoutput><h1>Send Email</h1></cfoutput>
	
	<skin:pop tags="error" start="<ul id='errorMsg'>" end="</ul>"><cfoutput><li>#message.message#</li></cfoutput></skin:pop>
	<skin:pop start="<ul id='OKMsg'>" end="</ul>"><cfoutput>#message.message#</li></cfoutput></skin:pop>
	
	<ft:field label="To"><cfoutput><input type="text" class="textInput" name="to" value="#form.to#"></cfoutput></ft:field>
	<ft:field label="BCC"><cfoutput><input type="text" class="textInput" name="bcc" value="#form.bcc#"></cfoutput></ft:field>
	<ft:field label="From"><cfoutput><input type="text" class="textInput" name="from" value="#form.from#"></cfoutput></ft:field>
	<ft:field label="Subject"><cfoutput><input type="text" class="textInput" name="subject" value="#form.subject#"></cfoutput></ft:field>
	<ft:field label="Body (Text)"><cfoutput><textarea name="bodyPlain" class="textareaInput">#form.bodyPlain#</textarea></cfoutput></ft:field>
	<ft:field label="Body (HTML)"><cfoutput><textarea id="bodyHTML" name="bodyHTML">#form.bodyHTML#</textarea></cfoutput></ft:field>
	<ft:field label="Attachment"><cfoutput><input type="file" class="textInput" name="attachment"></cfoutput></ft:field>
	
	<ft:buttonPanel>
		<ft:button value="Send Email" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
