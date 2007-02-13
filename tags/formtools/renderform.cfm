<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfoutput  >
		<form action="#Request.farcryForm.Action#" method="post" name="#Request.farcryForm.Name#" id="#Request.farcryForm.Name#" target="#Request.farcryForm.Target#" enctype="application/x-www-form-urlencoded">
		
		<input type="hidden" name="FarcryFormPrefixes" value="#StructKeyList(request.farcryForm.stObjects)#">
		
		<style  type="text/css">
		label,input {
		float: left;
		margin-bottom: 10px;
		padding:0;
	}
	
	label {
		text-align: right;
		width: 75px;
		padding-right: 20px;
	}
	
	br {
		clear: left;
	}
		</style>
	</cfoutput>
	


	
	<cfloop list="#ListSort(StructKeyList(Request.farcryForm.stObjects),'text')#" index="Prefixes">


		<cfoutput  >
			<h1>#request.farcryForm.stObjects[Prefixes].FARCRYFORMOBJECTINFO.ObjectLabel#</h1>
			<cfif StructKeyExists(Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo,"ObjectID")>
				<input type="hidden" name="#Prefixes#ObjectID" value="#Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo.ObjectID#">
			</cfif>
			<cfif StructKeyExists(Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo,"Typename")>
				<input type="hidden" name="#Prefixes#Typename" value="#Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo.Typename#">
			</cfif>
		</cfoutput>

		
		<cfloop collection="#request.farcryForm.stObjects[Prefixes].MetaData#" item="Field" >

			<cfset RenderField = request.farcryForm.stObjects[Prefixes].MetaData[Field]>
			
			<!--- SETUP REQUIRED PARAMETERS --->
			<cfif not isDefined("RenderField.RenderType")>

				<cfset RenderField.RenderType = RenderField.Type>

			</cfif>


			<cfif not isDefined("RenderField.RenderLabel")>

				<cfset RenderField.RenderLabel = RenderField.Name>

			</cfif>

			<cfoutput><label for="#Prefixes##RenderField.Name#">#RenderField.RenderLabel# </label></cfoutput>
			<cfswitch expression="#RenderField.RenderType#" >
				
				<cfcase value="longchar" >

					<cfoutput  >
						<!--- <textarea name="#Prefixes##RenderField.Name#" id="#Prefixes##RenderField.Name#" style="width:600px;height:400px;">#RenderField.Value#</textarea> --->
						<widgets:richTextEditor value="#RenderField.Value#" textareaname="#Prefixes##RenderField.Name#">
					</cfoutput>


				</cfcase>


				<cfdefaultcase  >

					<cfoutput  >
						
						<input type="Text" name="#Prefixes##RenderField.Name#" id="#Prefixes##RenderField.Name#" value="#RenderField.Value#">

					</cfoutput>


				</cfdefaultcase>


			</cfswitch>

			<cfoutput><br /></cfoutput>

		</cfloop>

		<cfoutput></fieldset></cfoutput>
	</cfloop>


	<cfoutput  >
		
		<input type="Submit" name="FarcryFormSubmitButton" value="Save Now">
		<input type="Submit" name="FarcryFormSubmitButton" value="Cancel">
		
		</form>

	</cfoutput>


<cfelse>

</cfif>


<!--- FLASH OPTION --->

<!---
	<cfform format="flash" name="#Request.farcryForm.Name#" width="400" height="400">
	
	
	<cfformgroup type="tabnavigator" height="220">
	<cfloop collection="#Request.farcryForm.stObjects#" item="Prefixes">
	<cfformgroup type="Page" Label="#request.farcryForm.stObjects[Prefixes].FARCRYFORMOBJECTINFO.ObjectLabel#">
	<cfloop collection="#request.farcryForm.stObjects[Prefixes].MetaData#" item="Field">
	
	<cfinput label="#Request.farcryForm.stObjects[Prefixes][Field].name#" name="#Prefixes##Request.farcryForm.stObjects[Prefixes][Field].name#"  value="#Request.farcryForm.stObjects[Prefixes][Field].value#" toolTip="this is a pretty cool hint">
	
	</cfloop>
	</cfformgroup>
	</cfloop>
	</cfformgroup>
	
	</cfform>
--->
