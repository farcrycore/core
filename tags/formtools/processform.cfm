<!---
	@@description: 
	<p>
		This tag is used to process form submissions.  It is, in general,
		used at the top of a display page that is displaying a form.
	</p>
	<p>
		This tag is used with the ft:form, ft:object and ft:button tags, and is
		the "action page" portion of form processing.  The <i>action</i>
		attribute is a string that needs to match the ft:button's <i>value</i>
		attribute.  So, for example, if you ft:button value="Submit" you'll want
		to have a ft:processform action="Submit" to handle the form.
	</p>
	
	@@examples: 
	<code>
		&lt;ft:processform action="Submit"&gt;
			&lt;skin:bubble title="Blarg!" message="Das Blarg Ya!" /&gt;
			&lt;cfdump var="#stobj#" /&gt;
		&lt;/ft:processform&gt;
	</code>
--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.action" default="*" ><!--- @@hint: the ft:button value action this processform handles --->
	<cfparam name="attributes.rbkey" default="" >
	<cfparam name="attributes.excludeAction" default="" >
	<cfparam name="attributes.bHideForms" default="false" /><!--- Setting this to true will allow the processing of the webskin to continue but ignore any subsequent <ft:form /> tags. --->
	<cfparam name="attributes.Exit" default="false"><!--- @@hint: If set to true the ft:form on the page will not show it's contents after this process runs. Note this doesn't stop page execution, just does not render ft:form contents. @@default: false --->
	<cfparam name="attributes.bSpamProtect" default="false"><!--- Instantiates cfformprotection to ensure the button is not clicked by spam. --->
	<cfparam name="attributes.stSpamProtectConfig" default="#structNew()#" /><!--- config data that will override the config set in the webtop. --->
	
	
	<cfset variables.EnterFormProcess = false>

	<cfif structKeyExists(form, "FarcryFormSubmitted")>
	
		<!--- I18 conversion of action and exludeAction lists --->
		<cfloop from="1" to="#listlen(attributes.action)#" index="i">
			<cfif listlen(attributes.rbkey) lt i>
				<cfset listsetat(attributes.action,i,application.rb.getResource('forms.buttons.#rereplacenocase(listgetat(attributes.action,i),"[^\w\d]","","ALL")#@label',listgetat(attributes.action,i))) />
			<cfelse>
				<cfset listsetat(attributes.action,i,application.rb.getResource('#listgetat(arguments.rbkey,i)#@label',listgetat(attributes.action,i))) />
			</cfif>
		</cfloop>
		<cfloop from="1" to="#listlen(attributes.excludeAction)#" index="i">
			<cfif listlen(attributes.rbkey) lt listlen(attributes.action) + i>
				<cfset listsetat(attributes.excludeAction,i,application.rb.getResource('forms.buttons.#rereplacenocase(listgetat(attributes.excludeAction,i),"[^\w\d]","","ALL")#@label',listgetat(attributes.excludeAction,i))) />
			<cfelse>
				<cfset listsetat(attributes.excludeAction,i,application.rb.getResource('#listgetat(arguments.rbkey,listlen(attributes.action) + i)#@label',listgetat(attributes.excludeAction,i))) />
			</cfif>
		</cfloop>

		<cfparam name="form.FarcryFormSubmitButton" default="" />	
		
		<cfif structKeyExists(form, "FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#") AND len(form["FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#"])>
			<cfset FORM.FarcryFormSubmitButton = form["FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#"] />
		</cfif>
		
		<cfif NOT len(form.FarcryFormSubmitButton)>
			<cfloop collection="#form#" item="fieldname">
				<cfif left(fieldname,23) EQ "FarcryFormSubmitButton=">
					<cfset form.FarcryFormSubmitButton = listAppend(form.FarcryFormSubmitButton,mid(fieldname,24,len(fieldname)-23)) />
				</cfif>
			</cfloop>
			<!--- IE 6 and below submits ALL <button> tags on a form regardless of which one was clicked. --->
			<cfif listLen(form.FarcryFormSubmitButton) GT 1>
				<cfabort showerror="IE 6 and below must have javascript enabled to submit forms correctly." />
			</cfif>
		</cfif>
		
			
		<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton)>
	
			<cfif listFindNoCase(attributes.action,FORM.FarcryFormSubmitButton) OR attributes.action EQ "*">
				<cfif NOT listFindNoCase(attributes.excludeAction,FORM.FarcryFormSubmitButton)>
					<cfset variables.EnterFormProcess = true />
				</cfif>
			</cfif>
	
		</cfif>
	</cfif>
	
	
	<cfif NOT variables.EnterFormProcess>
		<cfexit>
	<cfelse>
		
		<cfif attributes.bSpamProtect>
			<cfif not structkeyexists(session,"stFarCryFormSpamProtection") or not structkeyexists(session.stFarCryFormSpamProtection,form.farcryFormSubmitted) or not structkeyexists(session.stFarCryFormSpamProtection[form.farcryFormSubmitted],FORM.FarcryFormSubmitButton)>
				<!--- User was sessionless until they POST'd (happens behind reverse proxies) - set up as best we can here --->
				<cfparam name="session.stFarCryFormSpamProtection" default="#structNew()#" />
				<cfparam name="session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#']" default="#structNew()#" />
			</cfif>
			
			<cfif not structkeyexists(session.stFarCryFormSpamProtection,form.farcryFormSubmitted) or not structkeyexists(session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#'],FORM.FarcryFormSubmitButton)>
				<cfset session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#']['#FORM.FarcryFormSubmitButton#'] = structNew() />
				<cfset session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#']['#FORM.FarcryFormSubmitButton#'].bSpamProtect = true />
				<cfloop list="#structKeyList(attributes)#" index="protectionAttribute">
					<cfif findNoCase("protection_", protectionAttribute)>
						<cfset protectionAttributeName = mid(protectionAttribute,12,len(protectionAttribute)) />
						<cfset session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#']['#FORM.FarcryFormSubmitButton#']['#protectionAttributeName#'] = attributes["#protectionAttribute#"] />
					</cfif>
				</cfloop>
				<cfloop collection="#attributes.stSpamProtectConfig#" item="protectionAttributeName">
					<cfset session.stFarCryFormSpamProtection['#form.farcryFormSubmitted#']['#FORM.FarcryFormSubmitButton#']['#protectionAttributeName#'] = attributes.stSpamProtectConfig["#protectionAttribute#"] />
				</cfloop>
			</cfif>
			
			<!--- Supposed to enter form process but form protection is on so we need to protect --->
			<cfset cffp = CreateObject("component","farcry.core.webtop.cffp.cfformprotect.cffpVerify").init(ConfigPath="#application.path.core#/webtop/cffp/cfformprotect", stConfig=session.stFarCryFormSpamProtection["#form.farcryFormSubmitted#"]["#FORM.FarcryFormSubmitButton#"]) />

			<!--- now we can test the form submission --->
			<cfif NOT Cffp.testSubmission(form)>
				<!--- The submission has failed the form test. --->
				<cfset variables.EnterFormProcess = false>
				<cfexit>
			</cfif>
		</cfif>	
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">

	<cfif structKeyExists(caller, "onExitProcess")>
		<cfset stLocal.onExitProcess = duplicate(caller.onExitProcess) />
	</cfif>
	
	<!--- Was a simple URL redirect requested? --->
	<cfif structKeyExists(attributes, "URL")>
		<cfset attributes.exit = true />
		<cfset stLocal.onExitProcess = "#attributes.URL#" />
	</cfif>
	
	<!--- If you set bHideForms, you are effectively exiting the webskin but not redirecting anywhere --->
	<cfif structKeyExists(attributes, "bHideForms") AND isBoolean(attributes.bHideForms) AND attributes.bHideForms>
		<cfset attributes.exit = true />
		<cfset stLocal.onExitProcess = "hideforms" />
	</cfif>
	

	
	<!--- have we requested to exit this webskin? --->
	<cfif isDefined("attributes.Exit") AND attributes.Exit>
	
		<cfset Request.FarcryFormOnExitRun = true />

		<!--- 
			the edit view could be called through a function in which case the onExit struct will be in the arguments scope
			We should check for this first
		 --->
		<cfif not structKeyExists(stLocal, "onExitProcess")>
			<cfif structKeyExists(caller, "arguments") AND structKeyExists(caller.arguments, "onExitProcess")>
				<cfset stLocal.onExitProcess = caller.arguments.onExitProcess />		
			</cfif>
		</cfif>

		<cfif not isDefined("stLocal.onExitProcess") OR not isStruct(stLocal.onExitProcess)>
			<cfif not len(stLocal.onExitProcess)>
				<cfif structKeyExists(url, "dialogID")>
										
	
					<cfset stLocal.onExitProcess = structNew()>
					<cfset stLocal.onExitProcess.type = "HTML">
					<cfsavecontent variable="stLocal.onExitProcess.content">
						<cfoutput>
						<script type="text/javascript">
						$fc.closeBootstrapModal();
						</script>
						</cfoutput>
					</cfsavecontent>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- If the onExit doesnt exist, default to Refreshing the page. --->		
		<cfparam name="stLocal.onExitProcess" default="refresh" />
		
		<!--- If the onExit is not a struct we assume it is a URL to redirect to and we convert it too a struct. --->
		<cfif NOT isStruct(stLocal.onExitProcess)>
			<cfset stLocal.stOnExit = structNew() />
			<cfset stLocal.stOnExit.Type = "URL" />
			<cfset stLocal.stOnExit.Content = stLocal.onExitProcess />
		<cfelse>
			<cfset stLocal.stOnExit = stLocal.onExitProcess />
		</cfif>

		<!--- Events can be of type HTML, Function, URL(default) --->
		<cfswitch expression="#stLocal.stOnExit.Type#">
			
			<cfcase value="HTML">
				<cfif structKeyExists(stLocal.stOnExit, "Content")>
					<cfoutput>#stLocal.stOnExit.Content#</cfoutput>
				</cfif>
			</cfcase>
						
			<cfcase value="URL">
				<cfif structKeyExists(stLocal.stOnExit, "Content")>
					<cfif len(stLocal.stOnExit.Content)>
						<cfif stLocal.stOnExit.Content EQ "refresh">
							<skin:location href="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false" />
						<cfelseif stLocal.stOnExit.Content EQ "hideforms">
							<!--- DO NOTHING --->
						<cfelse>
							<skin:location href="#stLocal.stOnExit.Content#" addtoken="false" />
						</cfif>
					<cfelse>
						<!--- DO NOTHING --->
					</cfif>
				</cfif>
			</cfcase>				
		
		</cfswitch>
	
	</cfif>
</cfif>