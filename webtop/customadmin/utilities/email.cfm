<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Send an email --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfparam name="form.to" default="" />
<cfparam name="form.bcc" default="" />
<cfparam name="form.from" default="#application.config.general.adminemail#" />
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
		<skin:bubble message="Email successfully sent" />
	<cfelse>
		<skin:bubble message="#result#" tags="error" />
	</cfif>
</ft:processform>


<skin:loadJS id="jquery" />
<skin:loadJS id="tinymce" />
<skin:onReady><cfoutput>
	$j('textarea[name=bodyHTML]').tinymce({
		script_url : '/webtop/thirdparty/tiny_mce/tiny_mce.js',
		
		theme : "advanced",
		plugins : "safari,spellchecker,pagebreak,style,layer,table,save,advhr,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
		theme_advanced_buttons2_add : "separator,spellchecker",
		theme_advanced_buttons3_add_before : "tablecontrols,separator",			
		theme_advanced_buttons3_add : "separator,fullscreen,pasteword,pastetext",				
		theme_advanced_toolbar_location : "top",
		theme_advanced_toolbar_align : "left",
		theme_advanced_path_location : "bottom",
		theme_advanced_resize_horizontal : true,
		theme_advanced_resizing : true,
		theme_advanced_resizing_use_cookie : false,
		extended_valid_elements: "code,colgroup,col,thead,tfoot,tbody,abbr,blockquote,cite,button,textarea[name|class|cols|rows],script[type],img[style|class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]",
		remove_linebreaks : false,
		forced_root_block : 'p',
		relative_urls : false,
		
		width : "55%",
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
	<ft:field label="Body (HTML)"><cfoutput><textarea name="bodyHTML">#form.bodyHTML#</textarea></cfoutput></ft:field>
	<ft:field label="Attachment"><cfoutput><input type="file" class="textInput" name="attachment"></cfoutput></ft:field>
	
	<ft:buttonPanel>
		<ft:button value="Send Email" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>

<cfsetting enablecfoutputonly="false" />