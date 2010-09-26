<!--- @@Copyright: Daemon Pty Limited 2002-2010, http://www.daemon.com.au --->
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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent extends="types" displayname="CSS" hint="CSS objects influence the look and feel of the website" >
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty 
	name="title" type="string" hint="Meaningful reference title for file" required="no" default=""
	ftseq="1" ftfieldset="CSS Stylesheet" ftlabel="Title" ftvalidation="required" />
 
<cfproperty 
	name="description" type="longchar" hint="A description of the file to be uploaded" required="No" default="" 
	ftseq="2" ftfieldset="CSS Stylesheet" ftlabel="Description" />

<cfproperty 
	name="filename" type="string" hint="The name of the CSS file to be used" required="no" default=""
	ftseq="3" ftfieldset="CSS Stylesheet" ftlabel="CSS File" 
	ftType="file" ftDestination="/dmcss" ftSecure="false" />

<cfproperty 
	name="mediaType" type="string" hint="Specifies how a document is to be presented on different media" required="no" default=""
	ftseq="4" ftfieldset="CSS Stylesheet" ftlabel="Media Type" 
	fttype="list" ftlist="aural,braille,embossed,handheld,print,projection,screen,tty,tv" ftdefault="screen" ftSelectMultiple="true" />

<cfproperty 
	name="bThisNodeOnly" type="boolean" hint="Use css on this node only. No child inheritance" required="yes" default="0"
	ftseq="5" ftfieldset="CSS Stylesheet" ftlabel="No inheritance"
	fthint="Use css on this node only. No child inheritance." />

</cfcomponent>