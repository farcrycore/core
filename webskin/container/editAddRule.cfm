<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Add a new rule to the container --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset qRules = createObject("component","#application.packagepath#.rules.rules").getRules() />

<ft:processform action="Cancel">
	<cfoutput>
		<script type="text/javascript">
			window.close();
		</script>
	</cfoutput>
</ft:processform>

<ft:processform action="Save">
	<cfparam name="stObj.aRules" default="#arraynew(1)#" />
	
	<cfset oRule = createObject("component", application.stCOAPI[form.newrule].packagepath) />
	
	<cfset stProps = oRule.getDefaultObject(typename=form.newrule) />
	<cfset oRule.createData(stProperties=stProps)>
	
	<cfset arrayappend(stObj.aRules,stProps.objectID)>
			
	<cfset setData(stProperties=stObj)>

	<skin:location href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stProps.objectid#&method=editInPlace&container=#url.container#&iframe=1" addtoken="false" />
</ft:processform>

<ft:processform action="Cancel">
	<cfoutput>
		<script type="text/javascript">
			<cfif structkeyexists(url,"iframe")>
				parent.closeDialog();
			<cfelse>
				window.close();
			</cfif>
		</script>
	</cfoutput>
</ft:processform>

<skin:htmlHead id="newrule"><cfoutput>
	<script type="text/javascript">
		// build rules structure
		oRules = new Object;
		<cfloop query="qRules">
			oRules['#qRules.rulename#'] = new Object;
			<cfif structKeyExists(application.rules['#qRules.rulename#'],'hint')>
				oRules['#qRules.rulename#'].hint = '#JSStringFormat(application.rules[qRules.rulename].hint)#';
			<cfelse>
				oRules['#qRules.rulename#'].hint = 	'';
			</cfif>
		</cfloop>
		 
		function renderHint(rulename)
		{	
			document.getElementById('rulehint').innerHTML = oRules[rulename].hint;
		}	
	</script>
</cfoutput></skin:htmlHead>

<admin:header title="EDIT: #rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />

<ft:form>
	<cfoutput>
		<h1>EDIT: #rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#</h1>
		<fieldset class="formSection">
			<legend class="">Add new rule</legend>
			<div class="fieldSection list">
				<label class="fieldsectionlabel" for="newrule"> Rule : </label>
				<div class="fieldAlign">
					<select name="newrule" id="newrule" onchange="renderHint(this.value);">
						<cfloop query="qRules"><cfif not qRules.rulename eq "container">
							<option value="#qRules.rulename#"><cfif structKeyExists(application.rules[qRules.rulename],'displayname')>#application.rules[qRules.rulename].displayname#<cfelse>#qRules.rulename#</cfif></option>
						</cfif></cfloop>
					</select><br/>
					<p id="rulehint" class="highlight"></p>
				</div>
				<br class="clearer"/>
			</div>
		</fieldset>
		<script type="text/javascript">renderHint('#qRules.rulename[1]#');</script>
	</cfoutput>
	
	<ft:farcryButtonPanel indentForLabel="true">
		<ft:farcryButton value="Save" />
		<ft:farcryButton value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="false" />