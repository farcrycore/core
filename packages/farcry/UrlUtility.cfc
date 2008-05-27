<!--- {{{ jEdit Modes
:mode=coldfusion:
:collapseFolds=1:
:noTabs=true:
:tabSize=4:
:indentSize=4:
}}} --->
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
$Source: D:/cvs/ud/ud5/util/UrlUtility.cfc,v $
$Revision: 1.1.2.8 $

$Author: tylerh $
$Date: 2005/08/17 20:22:00 $

|| DEVELOPER ||
$Developer: Tyler Ham (tylerh@austin.utexas.edu)$
}}} --->


<cfcomponent>

<!--- {{{ PUBLIC functions --->


<!--- {{{ public structToURLParams(urlVars) --->
<cffunction name="structToURLParams" access="public" output="false" returntype="string"
  hint="converts struct into url parameter list, separated with ampersands, including
  leading question mark.">
  
  <cfargument name="urlVars" type="struct" required="true"
    hint="struct to convert to URL parameters.">
  
  <cfset var key = "">
  <cfset var urlString = "">
  
  <cfloop index="key" list="#StructKeyList(urlVars, "&")#" delimiters="&">
    <cfset urlString = urlString & "&" & key & "=" & urlVars[key]>
  </cfloop>
  
  <cfif Left(urlString, 1) is "&">
    <cfset urlString = "?" & Right(urlString, Len(urlString)-1)>
  </cfif>
  
  <cfif Right(urlString, 1) is "&">
    <cfset urlString = Left(urlString, Len(urlString)-1)>
  </cfif>
  
  <cfreturn urlString>
</cffunction>
<!--- }}} public structToURLParams(urlVars) --->

<!--- {{{ public replaceURLParams(address, paramStruct) --->
<cffunction name="replaceURLParams" access="public" output="false" returntype="string"
  hint="takes and address with possible url params and returns the base address
  with the given set of params in the paramStruct.">
  
  <cfargument name="address" type="string" required="true"
    hint="address to replace params on">
  
  <cfargument name="paramStruct" type="struct" required="true"
    hint="structure with params to put in the address">
  
  <cfset arguments.address = GetToken(arguments.address, 1, "?")>
  <cfset arguments.address = appendURLParams(arguments.address, arguments.paramStruct)>
  
  <cfreturn arguments.address>
</cffunction>
<!--- }}} public replaceURLParams(address, paramStruct) --->

<!--- {{{ public appendURLParams(address, paramStruct, [replaceExisting=true]) --->
<cffunction name="appendURLParams" access="public" output="false" returntype="string"
  hint="takes address and appends (and possibly replaces existing, if same param)
  the given params">
  
  <cfargument name="address" type="string" required="true"
    hint="address to append params to">
  
  <cfargument name="paramStruct" type="struct" required="true"
    hint="params to append">
  
  <cfargument name="replaceExisting" type="boolean" required="false" default="true"
    hint="indicates to replace existing keys if they already exist in the address">
  
  <cfset var existingParamStruct = getURLParamStruct(arguments.address)>
  <cfset var param = "">
  
  <cfloop index="param" list="#StructKeyList(arguments.paramStruct)#">
    <cfscript>
      if ( StructKeyExists(existingParamStruct, param) ) {
        if ( arguments.replaceExisting ) {
          existingParamStruct[param] = arguments.paramStruct[param];
        }
      } else {
        existingParamStruct[param] = arguments.paramStruct[param];
      }
    </cfscript>
  </cfloop>
  
  <cfset arguments.address = GetToken(arguments.address, 1, "?") & structToURLParams(existingParamStruct)>
  
  <cfreturn arguments.address>
</cffunction>
<!--- }}} public appendURLParams(address, paramStruct) --->

<!--- {{{ public getURLParamStruct(address) --->
<cffunction name="getURLParamStruct" access="public" output="false" returntype="struct"
  hint="takes an address with possible url params (?param=value&param2=value...) and returns
  a struct with param names as keys and param values as the key values.">
  
  <cfargument name="address" type="string" required="true"
    hint="address to get url struct from (must have the leading ? somewhere)">
  
  <cfset var urlStruct = StructNew()>
  <cfset var params = GetToken(arguments.address, 2, "?")>
  <cfset var paramName = "">
  <cfset var paramValue = "">
  
  <cfif len(arguments.address) and (not len(params)) and Left(arguments.address, 1) is "?">
    <cfif (Len(arguments.address) - 1) gt 0>
      <cfset params = Right(arguments.address, Len(arguments.address) - 1)>
    </cfif>
  </cfif>
  
  <cfif Len(params)>
    <cfloop index="param" list="#params#" delimiters="&">
      <cfscript>
        paramName = GetToken(param, 1, "=");
        paramValue = GetToken(param, 2, "=");
        
        if ( Len(paramName) ) {
          if ( Len(paramValue) ) {
            //urlStruct[paramName] = paramValue;
            // I'm modifying the previous line so that url-encoded values are automatically
            // decoded (seems like that's what would be expected of this component).
            // -Tyler Ham (tylerh@austin.utexas.edu), 2005-08-17
            urlStruct[paramName] = URLDecode(paramValue);
          } else {
            urlStruct[paramName] = "";
          }
        } else {
          urlStruct[param] = "";
        }
      </cfscript>
    </cfloop>
  </cfif>
  
  <cfreturn urlStruct>
</cffunction>
<!--- }}} public getURLParamStruct(address) --->

<!--- }}} PUBLIC functions --->


</cfcomponent>
