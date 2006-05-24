
<!--- 
///////////////////////////////////////////////////////////////
<cf_PLP> 
	This tag mimicks the behavior of Spectra PLPs. It is not 100% 
	backward compatable. But all the good stuff is still there.
	
	Also this tag has added functionality of allowing you to change 
	the temp. storage location of active PLPs
	Storage Locations:
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
	
@author: Mike Nimer

TODO:
	1) add date check on files
	2) add db logic
	
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
<cfparam name="attributes.r_stOutputObjects" default="stOutputObjects">




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
				stPLP.plp.inputObjects = structNew();
				stPLP.plp.outputObjects = structNew();
					//take the passed in struct, and put it in the stPLP.PLP.input struct. 
					//and put a copy in the output scope as well.
					if( isDefined("attributes.stInput") and isStruct(attributes.stInput) )
					{
						stPLP.plp.input = duplicate(attributes.stInput);
						stPLP.plp.output = duplicate(attributes.stInput);
						stPLP.plp.inputObjects[attributes.stInput.objectid] = duplicate(attributes.stInput);
						stPLP.plp.outputObjects[attributes.stInput.objectid] = duplicate(attributes.stInput);
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
	<!--- Check if plpstep has a different stepDir --->
	<cfif structKeyExists(stPLP.plp.steps[stPLP.currentStep],"stepDir")>
		<cfset plpfilepath = "#stPLP.plp.steps[stPLP.currentStep].stepDir#/#stPLP.plp.steps[stPLP.currentStep].template#">
	<cfelse>
		<cfset plpfilepath = "#attributes.stepDir#/#stPLP.plp.steps[stPLP.currentStep].template#">
	</cfif>
	
<!--- 	<cfsavecontent variable="Variables.PLPFormCSS">

<cfoutput>
	<style type="text/css">
	
		table {border-collapse:collapse;border:none;background:none;margin: .none;font-size:86%;border-bottom: none;border-left: none;}
		form.f-wrap-1 table {font-size:92%}
		table table {font-size:100%}
		caption {text-align:left;font: bold 145% arial;padding: 5px 10px;background:none}
		th {vertical-align:top;color: ##48618A;border-top: none;border-right: none;text-align: left;padding: 5px;background: none;font-size: 110%}
		th.order-asc {background-position: 100% -100px;padding-right:25px}
		th.order-desc {background-position: 100% -200px;padding-right:25px}
		th a:link, th a:visited, th a:hover, th a:active {color:##fff}
		th.alt a:link, th.alt a:visited {color:##E17000}
		th.alt a:hover, th.alt a:active {color:##fff}
		th img {display:block;float:right;margin:0;padding: 10px;}
		td {vertical-align:top;border:none;padding: 50px;margin:10px;}
		th.nobg {border:none;background:none}
		tr.alt {background: none} 
		tr.ruled {background: none} 
		tr {background:none}
		

/* =FORMS */
form.f-wrap-1 {margin: 0 0 1.5em}
input {font-family: arial,tahoma,verdana,sans-serif;margin: 2px 0}
fieldset {border: none}
label {display:block;padding: 5px 0;width:150px;}
label br {clear:left}
input.f-submit {padding: 1px 3px;background:##666;color:##fff;font-weight:bold;font-size:96%}

	/* f-wrap-1 - simple form, headings on left, form.f-wrap-1 elements on right */
	form.f-wrap-1 {width:100%;padding: .5em 0;background: ##f6f6f6 url("images/featurebox_bg.gif") no-repeat 100% 100%;border-top: 1px solid ##d7d7d7;position:relative}
		form.f-wrap-1 fieldset {width:auto;margin: 0 1em}
		form.f-wrap-1 h3 {margin:0 0 .6em;font: bold 155% arial;color:##c00}
		form.f-wrap-1 label {clear:left;float:left;width:auto;border:0px;}
		
		/* hide from IE mac \*/
		form.f-wrap-1 label {float:none}
		/* end hiding from IE5 mac */
	
		form.f-wrap-1 label input, form.f-wrap-1 label textarea, form.f-wrap-1 label select {width:15em;float:left;margin-left:10px}
		
		form.f-wrap-1 label b {float:left;width:8em;line-height: 1.7;display:block;position:relative}
		form.f-wrap-1 label b .req {color:##c00;font-size:150%;font-weight:normal;position:absolute;top:-.1em;line-height:1;left:-.4em;width:.3em;height:.3em}
		form.f-wrap-1 div.req {color:##666;font-size:96%;font-weight:normal;position:absolute;top:.4em;right:.4em;left:auto;width:13em;text-align:right}
		form.f-wrap-1 div.req b {color:##c00;font-size:140%}
		form.f-wrap-1 label select {width: 15.5em}
		form.f-wrap-1 label textarea.f-comments {width: 20em}
		form.f-wrap-1 div.f-submit-wrap {padding: 5px 0 5px 8em}
		form.f-wrap-1 input.f-submit {margin: 0 0 0 10px}
		
		form.f-wrap-1 fieldset.f-checkbox-wrap, form.f-wrap-1 fieldset.f-radio-wrap {float:left;width:32em;border:none;margin:0;padding-bottom:.7em}
		form.f-wrap-1 fieldset.f-checkbox-wrap b, form.f-wrap-1 fieldset.f-radio-wrap b {float:left;width:8em;line-height: 1.7;display:block;position:relative;padding-top:.3em}
		form.f-wrap-1 fieldset.f-checkbox-wrap fieldset, form.f-wrap-1 fieldset.f-radio-wrap fieldset {float:left;width:13em;margin: 3px 0 0 10px}
		form.f-wrap-1 fieldset.f-checkbox-wrap label, form.f-wrap-1 fieldset.f-radio-wrap label {float:left;width:13em;border:none;margin:0;padding:2px 0;margin-right:-3px}
		form.f-wrap-1 label input.f-checkbox, form.f-wrap-1 label input.f-radio {width:auto;float:none;margin:0;padding:0}
		
		form.f-wrap-1 label span.errormsg {position:absolute;top:0;right:-10em;left:auto;display:block;width:16em;background: transparent url(images/errormsg_bg.gif) no-repeat 0 0}
		
	</style>
	
	
	
</cfoutput>
	</cfsavecontent>
	

<cfhtmlhead text="#Variables.PLPFormCSS#"> --->

	
	
	
	<cfif structKeyExists(stPLP.plp.steps[stPLP.currentStep],"lFields")>
		<cfset lFields = duplicate(stPLP.plp.steps[stPLP.currentStep].lFields)>
		<cfinclude template="/farcry/farcry_core/tags/widgets/plpGenericStep.cfm">
	<cfelse>
		<cfinclude template="#plpfilepath#">
	</cfif>
	<!--- 
	<cfdump var="#stPLP#"> --->
	
	<cfset stPLP.plp.output = duplicate(output)>
	<cfset request.stPLP = duplicate(stPLP)>

	 <cfcatch type="Any">
		<cfoutput>
		<fieldset style="">
		    <legend>PLP ERROR!</legend>
		    an error has occured with this plp.<br>
		    PLP Step: #stPLP.currentStep#<br>
		    PLP template: #plpfilepath#	
			<br>
			ColdFusion Error Data<hr>
			<cfset request.cfdumpinited = false>
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
			if(isDefined("stPLP.plp.outputObjects"))
				{
				"caller.#attributes.r_stOutputObjects#" = stPLP.plp.outputObjects;
				}
		}else{
			killPLP = false;
			"caller.#attributes.r_bPLPIsComplete#" = false;
			"caller.#attributes.r_stOutput#" = stPLP.plp.output;
			if(isDefined("stPLP.plp.outputObjects"))
			{
				"caller.#attributes.r_stOutputObjects#" = stPLP.plp.outputObjects;
			}
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
					<cftrace inline="no" text="delete plp wddx instance from storage.">
				</cflock>
				<cfcatch type="Any">
					<cftrace inline="no" text="error: in killplp file delete.">
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
					<cfset request.cfdumpinited = false>
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

<cfif isDefined("thisStep.advance") AND thisStep.advance AND isDefined("thisStep.isComplete") AND thisStep.isComplete>
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


