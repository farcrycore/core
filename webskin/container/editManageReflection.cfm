<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Manage container mirroring --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<ft:processform action="Save">
	<cfif Trim(form.reflectionid) EQ ""> <!--- delete the reflection id --->
		<cfset deleteReflection(objectid=stObj.objectid) />
	<cfelse> <!--- set the reflection id --->
		<cfset setReflection(objectid=stObj.objectid,mirrorid=form.reflectionid) />
	</cfif>
	<cfset stObj.mirrorID = Trim(form.reflectionid)>
	<cfset setData(stproperties=stObj)>
	<cfoutput>
		<script type="text/javascript">
			<cfif structkeyexists(url,"iframe")>
				<!--- parent.location.reload(); --->
				parent.reloadContainer('#stObj.objectid#')
			<cfelse>
				<!--- window.opener.location.reload(); --->
				window.opener.reloadContainer('#stObj.objectid#')
			</cfif>
			
			<cfif structkeyexists(url,"iframe")>
				parent.closeDialog();
			<cfelse>
				window.close();
			</cfif>
		</script>
	</cfoutput>
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

<cfset qListReflections = getSharedContainers() />

<admin:header title="EDIT: #rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />

<ft:form>
	<cfoutput>
		<h1>EDIT: #rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#</h1>
		<fieldset class="formSection">
			<legend class="">Manage reflections</legend>
			<div class="fieldSection list">
				<label class="fieldsectionlabel" for="reflectionid"> Reflection : </label>
				<div class="fieldAlign">
					<select name="reflectionid" id="reflectionid">
						<option value=""<cfif stObj.mirrorid EQ ""> selected="selected"</cfif>>Not reflected</option>
						<cfloop query="qListReflections">
							<option value="#qListReflections.objectid#"<cfif stObj.mirrorid EQ qListReflections.objectid> selected="selected"</cfif>>#qListReflections.label#</option>
						</cfloop>
					</select><br/>
				</div>
				<br class="clearer"/>
			</div>
		</fieldset>
	</cfoutput>
	
	<ft:farcryButtonPanel indentForLabel="true">
		<ft:farcryButton value="Save" />
		<ft:farcryButton value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="false" />