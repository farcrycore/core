===================================================
 Plugin Name: spellchecker (for ColdFusion)
 Author: Richard Davies (richard@richarddavies.us)
 Version: 2.0.3
===================================================

-------------
 DESCRIPTION
-------------

This is a ColdFusion port of the TinyMCE PHP spellchecker plugin. It supports both the
Google spellchecker engine and the Pspell/Aspell spellchecker.

This plugin is compatible with TinyMCE 3.0. If using TinyMCE 2.x, use the "SpellChecker CFM" 
plugin available at:
http://sourceforge.net/tracker/index.php?func=detail&aid=1526516&group_id=103281&atid=738747

Thanks to Jehiah Czebotar and Thomas Messier for their excellent json.cfc component.


--------------
 INSTALLATION
--------------

1. Copy the spellchecker folder to your tinyMCE plugins directory.
2. Add the "spellchecker" plugin and button to your tinyMCE init code:
		<script type="text/javascript">
			tinyMCE.init({
				mode : "textareas",
				theme : "advanced",
				plugins : "spellchecker",
				theme_advanced_buttons1 : "spellchecker"
			});
		</script>
3. Edit config.cfm as follows:
	* Choose which spellchecker to use in config['general.engine']
	* If using PSpellShell, then uncomment the appropriate section depending on your OS.
	* Adjust other config settings as necessary.
4. If using PSpellShell, you must have Aspell installed on your web server, along with 
	whatever language dictionaries you want to use.
	*nix: http://aspell.net/
	Windows: http://aspell.net/win32/


-----------------
 VERSION HISTORY
-----------------

2.0.3
	* Fixed potential security hole in PSpellShell.cfc.

2.0.2
	* Updated editor_plugin*.js to updated version in TinyMCE 3.0.6.

2.0.1
	* Bug fix: Fixed minor issue with PSpellShell suggestions containing a leading space.

2.0
	* New: Added support for Pspell/Aspell spellchecker. (I've only tested it on a Windows 
	  server, but it *should* work on Linux/Unix too.)
	* Updated: <cfhttp> used by GoogleSpell now supports proxy servers. 

1.0.1
	* Bug fix: rpc.cfm - Removed content-encoding HTTP header interfering with gzipped output.

1.0
	* Initial version ported from TinyMCE PHP plugin to ColdFusion.