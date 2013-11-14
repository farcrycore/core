<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry CMS Plugin.

    FarCry CMS Plugin is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry CMS Plugin is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with FarCry CMS Plugin.  If not, see <http://www.gnu.org/licenses/>.
--->

<!--- @@displayname: Utility: Plain Text Block --->
<!--- @@Description: Publishing rule for rendering a block of user definable text/markup in the container. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<cfcomponent displayname="Utility: Plain Text Block" extends="farcry.core.packages.rules.rules" 
	hint="Publishing rule for rendering a block of user definable text/markup in the container.">

    <cfproperty name="text" type="longchar" required="yes" default="" 
        ftSeq="1" ftLabel="Text" 
        ftType="longchar"
        ftHint="Text to display. Can be any combination of content and HTML markup.">
	
</cfcomponent>