<cfsetting enablecfoutputonly="true">

<cfscript>
	//help tooltips
	help = structNew();
	help.parentDirName = "Please enter the name of the directory which contains core, plugins and fourq";
</cfscript>

<cfoutput>
	<div id="content">
		<h2>Farcry Pre-Installation Settings</h2>
		
		<form name="preInstallForm" id="preInstallForm" action="#cgi.script_name#" method="post" class="content">
			<input type="hidden" name="preInstallSubmit" id="preInstallSubmit" value="1" />
		
			<div class="item">
				<label for="parentDirName">Parent Directory Name <em>*</em></label>
				<input type="text" name="parentDirName" id="parentDirName" size="30" maxlength="100" value="" class="highlighted" />
				<a href="##" onclick="return false;" class="help"><img src="help.gif" alt="Help" /><span class="outer"><span class="inner"><p class="content">#help.parentDirName#</p></span></span></a>
			</div>
		
			
			<div class="itemButtons">
				<input type="submit" name="proceed" value="INSTALL" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
		        <input type="reset" name="reset" value="RESET" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
			</div>
		</form>
				
	</div>	
</cfoutput>

<cfsetting enablecfoutputonly="false">