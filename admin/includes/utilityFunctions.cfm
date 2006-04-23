
	<cffunction name="arrayKeyToList">
		<cfargument name="array" required="true">
		<cfargument name="key" required="true">
		<cfargument name="delimiter" required="false" default=",">

		<cfscript>
			list = '';
			for(i=1;i LTE arrayLen(arguments.array);i=i+1)
			{
				if (len(list))
					list = list & arguments.delimiter;
				arrayEntry = arguments.array[i];
				list = list	& arrayEntry[arguments.key];
			}	
		</cfscript>
		<cfreturn list>
	</cffunction>
	
	<cffunction name="appendURlVar" hint="appends a url parmater to a given URL. Determines if ? or & is required">
		<cfargument name="urlstring" required="Yes" hint="URl to have param appended to">
		<cfargument name="urlvaluepair" required="Yes" hint="URL value pair to be appended to urlstring">
		<cfscript>
			completeURL = arguments.urlstring;
			if(findnocase(".cfm?",URLDecode(completeURL)))
				append = "&";
			else
				append = "?";
			completeURL = completeURL & append & arguments.urlvaluepair;	
		</cfscript>								
		<cfreturn completeURL>	
	</cffunction>
	

	<cfscript>
	function arrayReverse(inArray){
		var outArray = ArrayNew(1);
		var i=0;
			var j = 1;
		for (i=ArrayLen(inArray);i GT 0;i=i-1){
			outArray[j] = inArray[i];
			j = j + 1;
		}
		return outArray;
	}

	</cfscript>
	
	<cffunction name="getPackagePath" hint="Returns full package for a component based on its name - useful for determing whether this component is a core or custom effort ">
		<!--- Now that we're using APPLICATION.TYPES[TYPENAME].TYPEPATH this function is deprecated ~Tom --->
		<cfargument name="name" required="true">
		
		<cfscript>
			packagepath = '';
			//first search types
			for(key IN application.types)
			{
				if (key IS arguments.name)
				{
					packagePath = application.types[key].typePath;
				}	
			}
			//search rules now if not found in application.types scope
			if (not len(packagepath))
			{
				for(key IN application.rules)
				{
					if (key IS arguments.name)
					{
						packagePath = application.rules[key].rulePath;
					}	
				}
			}
			
		
		</cfscript>
		<cfreturn packagepath>
	</cffunction>

	

	<cffunction name="QueryToStructure">
		<cfargument name="query" type="query" required="true">
		<cfscript>
			stStruct = structNew();
			cols = ListtoArray(arguments.query.columnlist);
			for(index=1; index LTE arraylen(cols); index=index+1)
			{
				stStruct[cols[index]] = arguments.query[cols[index]][1];
			}
		</cfscript>
		<cfreturn stStruct>
	</cffunction>
	
	
	
	<cffunction name="QueryToArrayOfStructures" returntype="array" hint="Converts a query object to an array of structures">
		<cfargument name="theQuery" required="true">
		<cfargument name="theArray" required="false" default="#arrayNew(1)#">
		<cfset var cols = ListtoArray(theQuery.columnlist)>
		<cfset var row = 1>
		<cfset var thisRow = "">
		<cfset var col = 1>
		<cfscript>	
			for(row = 1; row LTE theQuery.recordcount; row = row + 1)
		{
			thisRow = structnew();
			for(col = 1; col LTE arraylen(cols); col = col + 1){
				thisRow[cols[col]] = theQuery[cols[col]][row];
			}
			arrayAppend(arguments.theArray,duplicate(thisRow));
		}
	
	</cfscript>
	<cfreturn arguments.theArray>
	</cffunction>
	
	<cffunction name="filterStructure" hint="Removes specified structure elements">
		<cfargument name="st" required="Yes" hint="The structure to parse">
		<cfargument name="lKeys" required="Yes" hint="A list of structure keys to delete">
		
		<cfset var i = 1>
		<cfscript>
			aKeys = listToArray(arguments.lKeys);	
			for(i = 1;i LTE arrayLen(aKeys);i=i+1)
			{
				if(structKeyExists(arguments.st,aKeys[i]))
					structDelete(arguments.st,aKeys[i]);
			}
				
		</cfscript>
		<cfreturn arguments.st>
	</cffunction>
	
	<cffunction name="structToNamePairs" hint="Builds a named pair string from a structure">
		<cfargument name="st">
		<cfset var keyindex = 1>
		<cfscript>
			namepair = '';
			keyCount = structCount(arguments.st);
			for(key in arguments.st)
			{	
				namepair = namepair & "#key#=#arguments.st[key]#";
				if(keyIndex LT keyCount)
					namepair = namepair & "&";
				keyIndex = keyIndex + 1;		
			}
		</cfscript>
		<cfreturn trim(namepair)>
	
	</cffunction>
	
	
	<cffunction name="ParagraphFormat2">
		<cfargument name="str" required="Yes">
		
		<cfscript>
		str = arguments.str;	
		 {
		//first make Windows style into Unix style
		str = replace(str,chr(13)&chr(10),chr(10),"ALL");
		//now make Macintosh style into Unix style
		str = replace(str,chr(13),chr(10),"ALL");
		//now fix tabs
		str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
		//now return the text formatted in HTML
		}
		</cfscript>
		<cfreturn replace(str,chr(10),"<br />","ALL")>
	</cffunction>