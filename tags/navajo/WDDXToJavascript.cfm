<cfprocessingDirective pageencoding="utf-8">
<cfparam name="attributes.toplevelvariable">
<cfparam name="attributes.input">
<cfparam name="attributes.output">
<cfparam name="attributes.bDefineRootObject" default="0">

<cfscript>
output = "";

if( attributes.bDefineRootObject eq 1 )
{
	output = output & "_tl0=new Object();#attributes.topLevelVariable#=_tl0;";
}

function genData( stObject, level )
{
	//		output = output & "_tmp#level#=new Object();
//_tl#level#['#key#']=_tmp#level#;";

	for( key in stObject )
	{
		el = stObject[key];
		
		if( isArray(el) )
		{
			output = output & "_tl#level#['#key#']=new Array(";
			
			for( index=1; index lte arrayLen(el); index=index+1 )
			{
				if( index neq 1 ) output=output&",";
				if( not isStruct( el[index] ) )
				{
					output = output & "'#el[index]#'";
				}
				else
				{
					output = output & "'struct'";
				}
			}
			
			output = output & ");";
		}
		else if( isStruct(el) )
		{
			lp=level+1;
			output = output & "_tl#lp#=new Object();_tl#level#['#key#']=_tl#lp#;";
			genData( el, level+1 );
		}
		else
		{
			// must be a string
			output = output & "_tl#level#['#key#']='#JSStringFormat(el)#';";
		}
	}
}

if( not StructIsEmpty( attributes.input ) ) genData( attributes.input, 0 );
		else output="";
</cfscript>

<cfset "caller.#attributes.output#"=output>