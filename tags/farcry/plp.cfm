
<!--- 
///////////////////////////////////////////////////////////////
<cf_PLP> 
	This tag mimicks the behavior of Spectra PLPs. It is not 100% 
	backward compatable. But all the good stuff is still there.
	
	Also this tag has added functionality of allowing you to change 
	the temp. storage location of active PLPs
	Storage Locations:
		Spectra - maybe?
		DB
		FILE
		
ATTRIBUTES:
	owner="" required.
	stepDir="" required. a CF mapping to the dir. where the steps for this plp are.
	stInput="" - optional. any struct passed in here will be accessable in both the input and output scope.
	iTimeout="" - optional (defaults to 15 min). Number of minutes before 
	redirection="SERVER|CLIENT" - option (Default: SERVER). This will allow you to set this to Client if you need to set any cookies or are having redirection problems.
	bDebug="" - optional (true/false). Shows useful debug info after the PLP step is displayed.
	bForceNewInstance="" - optional (true/false). Deletes any existing instances and starts the PLP over again.
	r_bPLPIsComplete="" - optional.
	r_stOutput="" - optional.
	
		storage="file"
		dir="" - required with file storage. Location to read/write file to. PLP tag will handle the naming conventions.
	
		storage="Spectra"
		PLPID="" - optional, if a PLP has been defined in the webtop. You can also use the child tags
		datasource="" - required with spectra storage and a defined PLPID. The COAPI datasource of the spectra
		
		storage="db"
		datasource="" - required with DB storage. a valid CF datasource.
		table="" - required with DB storage. Table containing a CLOB or Large Text Area (SQL=text, ACCESS=memo)
		Column="" - required with DB storage. Column that can support a large wddx packet.
		IDColumn="" - required with DB storage. varchar/char Column. Must be large enough to store the owner attribute.
		dateColumn="" - required with DB storage. Date/Time data type column. This is needed so we can timeout the tag.

		
ADDING A STORAGE LOCATION:
	to extend this tag and add a new storage location, to store the stPLP struct. 
	Usually as a wddx packet. But it's your call. Just add the logic to one CFIF and 
	Three CFSWITCH statements. All of them have the comments before the logic
	starting with the keyword "STORAGE:"
	
TEST CASES:
	1) basic walk through
	2) user registration
	3) todo: shopping cart
	4) todo: conditional login or register
	5) todo: conditional login? then continue
		
@author: Mike Nimer


TODO:
	1) add date check on files
	2) add db logic
	3) add Spectra support logic
	
	
	
///////////////////////////////////////////////////////////////
--->

<!--- ///	verify attributes	/// --->
<cfparam name="attributes.owner">
<cfparam name="attributes.storage">
<cfparam name="attributes.stepDir">
<cfparam name="attributes.iTimeout" default="15" type="numeric">
<cfparam name="attributes.redirection" default="server">
<cfparam name="attributes.bDebug" default="0" type="boolean">
<cfparam name="attributes.bForceNewInstance" default="0" type="boolean">
<cfparam name="attributes.r_bPLPIsComplete" default="bComplete">
<cfparam name="attributes.r_stOutput" default="stOutput">

<cfparam name="bNewPLP" default="0">
<cfscript>
	if( attributes.bForceNewInstance eq true )
	{
		bNewPLP = 1;		
	}
</cfscript>



<!--- 
///////////////////////////////////////////////////////////////
	Storage:
	error validation of the attributes. throw errors as needed
///////////////////////////////////////////////////////////////
--->
<cfif attributes.storage neq "file" and attributes.storage neq "db"  and attributes.storage neq "spectra">
	<cfthrow type="attributes" message="#attributes.storage# is an invalid storage type. The valid options are FILE, DB, or SPECTRA.">
</cfif>


<cfswitch expression="#thistag.executionmode#">
	<cfcase value="start">
<!--- 
///////////////////////////////////////////////////////////////
	Storage:
	check for exsisting PLP instance
///////////////////////////////////////////////////////////////
--->
		<cfswitch expression="#attributes.storage#">
			<cfcase value="file">
				<!--- 
				///////////////////////////////////////////////////////////////
					using the owner as the file name. Check to see if this PLP already exists.
				///////////////////////////////////////////////////////////////
				--->
				<cftry>
					<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
						<cffile action="READ" 
							file="#attributes.storagedir#/#attributes.owner#.plp" 
							variable="wddxplp"
							charset="utf-8"> 
							
					</cflock>
						<!--- ///	convert it to our plp structure.	/// --->
						<cfwddx action="WDDX2CFML" input="#wddxplp#" output="stPLP">
					<cfcatch type="Any">
						<!--- ///	<cfdump var="#cfcatch#">	/// --->
						<cfset bNewPLP = true>
					</cfcatch>
				</cftry>
				
				
				<!--- 
				///////////////////////////////////////////////////////////////
					if attributes.bForceNewInstance is true. Delete the existing file, if one exists. and reset the stPLP structure
				///////////////////////////////////////////////////////////////
				--->
				<cfif bNewPLP>	
					<cftry>
						<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
							<cffile 
								action="DELETE" 
								file="#attributes.storagedir#/#attributes.owner#.plp">
						</cflock>
						<cfcatch type="Any">
							<cfset bNewPLP = true>
						</cfcatch>
					</cftry>
				</cfif>
			</cfcase>
			
			<cfcase value="db">
				<!--- ///	todo:	/// --->
			</cfcase>
			<cfcase value="spectra">
				<!--- ///	todo:	/// --->
			</cfcase>
		</cfswitch>
			
	</cfcase>
	

	
	
	<cfcase value="end">
		<!--- 
		///////////////////////////////////////////////////////////////
			New PLP:
			if bNewPLP eq true. Then this is the first instance of the PLP, 
			or it's timed out. This flag is determined in the start tag.
			or if attributes.bForceNewInstance is true
		///////////////////////////////////////////////////////////////////
		--->
		<cfscript>
			//create a new stPLP structure.
			if( (isDefined("bNewPLP") and bNewPLP) or not isDefined("stPLP") or not isStruct(stPLP)  )
			{
				stPLP = structNew();
				stPLP.plp = structNew();
				stPLP.plp.input = structNew();
				stPLP.plp.output = structNew();
					//take the passed in struct, and put it in the stPLP.PLP.input struct. 
					//and put a copy in the output scope as well.
					if( isDefined("attributes.stInput") and isStruct(attributes.stInput) )
					{
						stPLP.plp.input = attributes.stInput;
						stPLP.plp.output = attributes.stInput;
					}
					
				stPLP.steps = ArrayNew(1);
				stPLP.plp.steps = structNew();
				//loop over the child tags and define the steps of the PLP.
				for( i = 1; i lte #arrayLen(thistag.assocAttribs)#; i = i + 1 )
				{
					stPLP.steps[i] = structNew();				
					stPLP.steps[i] = thistag.assocAttribs[i];
					stPLP.plp.steps[thistag.assocAttribs[i].name] = structNew();
					stPLP.plp.steps[thistag.assocAttribs[i].name] = thistag.assocAttribs[i];
					//if the PLP should finish after this step.
						if( structKeyExists(thistag.assocAttribs[i] , "bFinishPLP" ) )
						{
							stPLP.plp.steps[thistag.assocAttribs[i].name].bFinishPLP = yesNoFormat(thistag.assocAttribs[i].bFinishPLP);						
						}else{
							if( arrayLen(thistag.assocAttribs) eq i )
							{
								stPLP.plp.steps[thistag.assocAttribs[i].name].bFinishPLP = true;
							}else{
								stPLP.plp.steps[thistag.assocAttribs[i].name].bFinishPLP = false;
							}
						}
						
					//define next step. and if it's the last step have the PLP delete itself.
					thischildtag = thistag.assocAttribs[i];
					if( structKeyExists(thistag.assocAttribs[i], "nextStep") )
					{
						stPLP.plp.steps[thistag.assocAttribs[i].name].nextStep = thistag.assocAttribs[i].nextStep;
					}else{
						if( arrayLen(thistag.assocAttribs) gt i )
						{
							stPLP.plp.steps[thistag.assocAttribs[i].name].nextStep = thistag.assocAttribs[i+1].name;
						}else{
							stPLP.plp.steps[thistag.assocAttribs[i].name].nextStep = stPLP.currentStep;
							//stPLP.plp.steps[thistag.assocAttribs[i].name].bFinishPLP = true;
						}
					}
					
					//set the current step.
					if( i eq "1" )
					{
						stPLP.currentStep = thistag.assocAttribs[1].name;
					}
				}
				
			}		
		</cfscript>
		
		
<!--- 
///////////////////////////////////////////////////////////////
	Include the Proper steps code.
///////////////////////////////////////////////////////////////
--->
<cftry>

<cfset output = duplicate(stPLP.plp.output)>
	<cfinclude template="#attributes.stepDir#/#stPLP.plp.steps[stPLP.currentStep].template#">	
<cfset stPLP.plp.output = duplicate(output)>

	<cfcatch type="Any">
<cfoutput>
<fieldset style="">
	<legend>PLP ERROR!</legend>
	an error has occured with this plp.<br>
	PLP Step: #stPLP.currentStep#<br>
	PLP template: #attributes.stepDir#/#stPLP.plp.steps[stPLP.currentStep].template#
	<br>
	ColdFusion Error Data<hr>
	<cfdump var="#cfcatch#">
</fieldset>
</cfoutput>
	
	</cfcatch>
</cftry>

	
	
	
<!--- 
///////////////////////////////////////////////////////////////
	output debug output.
	we are doing this before the end of the tag. because we are 
	going to start. rewritting the stPLP structure. so the next 
	step will know what to do.	
///////////////////////////////////////////////////////////////
--->
<cfif attributes.bDebug>
	<div class="plpDebug">
		<fieldset>
			<legend><font face="verdanda,Arial,geneva,helvetica"><b>PLP Debug Information</b></font></legend>
			<cfdump var="#stPLP#">
		</fieldset>
	</div>
</cfif>
	
<!--- 
///////////////////////////////////////////////////////////////
	now the step has been completed, modify the stPLP
///////////////////////////////////////////////////////////////
--->
	<cfscript>
		if( stPLP.plp.steps[stPLP.currentStep].bFinishPLP )
		{
			killPLP = true;
			"caller.#attributes.r_bPLPIsComplete#" = true;
			"caller.#attributes.r_stOutput#" = stPLP.plp.output;
		}else{
			killPLP = false;
			"caller.#attributes.r_bPLPIsComplete#" = false;
			"caller.#attributes.r_stOutput#" = stPLP.plp.output;
		}
		
		if( isDefined("thisStep.isComplete") )
		{
			writeoutput("");
			//	todo
		}
		
		if ( isDefined("thisStep.nextStep") and structKeyExists(stPLP.plp.steps, thisStep.nextStep) )
		{
			stPLP.currentStep = thisStep.nextStep;
		}
		
		if( (isDefined("thisStep.advance") and thisStep.advance) and not (isDefined("thisStep.nextStep") and structKeyExists(stPLP.plp.steps, thisStep.nextStep)))
		{
			stPLP.currentStep = stPLP.plp.steps[stPLP.currentStep].nextStep;
		}

	</cfscript>

<!--- 
///////////////////////////////////////////////////////////////
	Storage/Cleanup:
	Delete the PLP instance
///////////////////////////////////////////////////////////////
--->
<cfif killPLP>
	<cfswitch expression="#attributes.storage#">
		<cfcase value="file">
			<cftry>
				<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
					<cffile 
						action="DELETE" 
						file="#attributes.storagedir#/#attributes.owner#.plp">
				</cflock>
				<cfcatch type="Any">
					<cfset bNewPLP = true>
				</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="db">
			<!--- ///	todo:	/// --->
		</cfcase>
		<cfcase value="spectra">
			<!--- ///	todo:	/// --->
		</cfcase>
	</cfswitch>
</cfif>

<!--- 
///////////////////////////////////////////////////////////////
	Storage:
	save the PLP to the proper location. 
///////////////////////////////////////////////////////////////
--->
<!--- ///	searialize the PLP structure to a wddx packet	/// --->
<cfwddx action="CFML2WDDX" input="#stPLP#" output="wddxPLP">

<cfif not killPLP>
	<cfswitch expression="#attributes.storage#">
		<cfcase value="file">
			<cftry>
				<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
					<cffile 
						action="WRITE"
						file="#attributes.storagedir#/#attributes.owner#.plp"
						output="#wddxPLP#"
						addnewline="No"
						charset="utf-8">
				</cflock>
				<cfcatch type="Any">
					<cfdump var="#cfcatch#">
				</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="db">
			<!--- ///	todo:	/// --->
		</cfcase>
		<cfcase value="spectra">
			<!--- ///	todo:	/// --->
		</cfcase>
	</cfswitch>
</cfif>
<!--- 
///////////////////////////////////////////////////////////////
	And reload the page using a cflocation or Javascript.
///////////////////////////////////////////////////////////////
--->
<cfif isDefined("thisStep.advance")
	and thisStep.advance
		and isDefined("thisStep.isComplete")
			and thisStep.isComplete>
			
	<cfif attributes.redirection eq "server">
		<cflocation url="#cgi.script_name#?#cgi.query_string#" addtoken="No">
	<cfelse>
		<cfoutput>
		<META HTTP-EQUIV="Refresh" CONTENT="0;URL=#cgi.script_name#?#cgi.query_string#">
		</cfoutput>
	</cfif>
</cfif>
	
	

	</cfcase>
</cfswitch>


