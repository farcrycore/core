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
	<ft:field label="Body (HTML)">
		<cfset stRichtext = structNew() />
		<!--- richtext.edit() needs a registered host type (it calls getContentType()); dmHTML is a neutral core type. This form has no backing record. --->
		<cfset stRichtext.typename = "dmHTML" />
		<cfset stRichtext.stObject = structNew() />
		<cfset stRichtext.stObject.objectid = createUUID() />
		<cfset stRichtext.stObject.typename = "dmHTML" />
		<cfset stRichtext.stMetadata = structNew() />
		<cfset stRichtext.stMetadata.name = "bodyHTML" />
		<cfset stRichtext.stMetadata.ftType = "richtext" />
		<cfset stRichtext.stMetadata.value = form.bodyHTML />
		<cfset stRichtext.stMetadata.ftImageListFilterTypename = "" />
		<cfset stRichtext.stMetadata.ftImageListFilterProperty = "" />
		<cfset stRichtext.stMetadata.ftLinkListFilterTypenames = "" />
		<cfset stRichtext.stMetadata.ftTemplateTypeList = "" />
		<cfset stRichtext.stMetadata.ftContentCSS = "" />
		<cfset stRichtext.stMetadata.ftWidth = "98%" />
		<cfset stRichtext.stMetadata.ftHeight = "280px" />
		<cfset stRichtext.stMetadata.ftClass = "" />
		<cfset stRichtext.stMetadata.ftStyle = "" />
		<cfset stRichtext.fieldname = "bodyHTML" />
		<cfoutput>#application.formtools.richtext.oFactory.edit(argumentCollection=stRichtext)#</cfoutput>
	</ft:field>
	<ft:field label="Attachment"><cfoutput><input type="file" class="textInput" name="attachment"></cfoutput></ft:field>
	
	<ft:buttonPanel>
		<ft:button value="Send Email" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
