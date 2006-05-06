<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/farcry_core/tags/formtools/formfieldtypes" prefix="fft" >

<cfif thistag.ExecutionMode EQ "Start">
	
			
	<cfoutput><input type="hidden" name="FarcryFormPrefixes" value="#StructKeyList(request.farcryForm.stObjects)#"></cfoutput>
		
	<cfloop list="#ListSort(StructKeyList(Request.farcryForm.stObjects),'text')#" index="Prefixes">


		<cfoutput  >
			<!--- <h1>#request.farcryForm.stObjects[Prefixes].FARCRYFORMOBJECTINFO.ObjectLabel#</h1> --->
<!--- 			<cfif StructKeyExists(Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo,"ObjectID")>
				<input type="hidden" name="#Prefixes#ObjectID" value="#Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo.ObjectID#">
			</cfif>
			<cfif StructKeyExists(Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo,"Typename")>
				<input type="hidden" name="#Prefixes#Typename" value="#Request.farcryForm.stObjects[Prefixes].farcryformobjectinfo.Typename#">
			</cfif> --->
		</cfoutput>

		
		<!--- <cfloop collection="#request.farcryForm.stObjects[Prefixes].MetaData#" item="Field" >

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
						<!--- <widgets:richTextEditor value="#RenderField.Value#" textareaname="#Prefixes##RenderField.Name#"> --->
						<fft:tinymce name="#Prefixes##RenderField.Name#" value="#RenderField.Value#" style="width:300px;"> 
					</cfoutput>


				</cfcase>

				<cfcase value="array" >

					<cfdump var="#RenderField.Value#">


				</cfcase>


				<cfdefaultcase  >

					<cfoutput  >
						
						<input type="Text" name="#Prefixes##RenderField.Name#" id="#Prefixes##RenderField.Name#" value="#RenderField.Value#">

					</cfoutput>


				</cfdefaultcase>


			</cfswitch>

			<cfoutput><br /></cfoutput>

		</cfloop> --->

	</cfloop>
	

	<cfoutput  >
		
<!--- 		<input type="Submit" name="FarcryFormSubmitButton" value="Save Now">
		<input type="Submit" name="FarcryFormSubmitButton" value="Cancel"> --->
		
		</form>

	</cfoutput>
	
</cfif>