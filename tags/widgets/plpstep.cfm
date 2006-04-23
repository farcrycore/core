<!--- 
///////////////////////////////////////////////////////////////
<cf_plpstep>
	Child tag of the cf_plp tag. This tag allows you to define 
	a PLP step on the fly. So no database is needed. 
	
ATTRIBUTES:
	name="" - 	step name. this var. will be used to redirect the 
				PLP between steps.
	template="" - name of the .cfm to be included for this step
	nextstep="" - in case you want to override the default nextstep
	type="run|conditional" - default (RUN). 
	condition="" - 	required is type=conditional. A CF expression that if
					evaluates to true the step will be executed. If not it 
					will be skipped.
///////////////////////////////////////////////////////////////
--->
<cfassociate basetag="cf_plp">