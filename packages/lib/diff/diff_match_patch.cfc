<cfscript>

/*
 * Diff Match and Patch
 *
 * Copyright 2006 Google Inc.
 * http://code.google.com/p/google-diff-match-patch/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @author fraser@google.com (Neil Fraser)
 * on Jan 11, 2012
 *
 *
 * ColdFusion wrapper class for Diff, Match and Patch Library
 * Marco Spescha, @maertsch
 * on Mar 07, 2012
 *
 */

component {
	
	public struct function init(javaloader){
		// load java-class with javaloader if not already provided
		if(not isDefined('arguments.javaloader')){
			this.javaloader = createObject("component", "farcry.core.packages.farcry.javaloader.JavaLoader").init([
				expandPath('/farcry/core/packages/lib/diff/diff_match_patch-current.jar')
			]);
		}else{
			this.javaloader = arguments.javaloader;
		}		
		
		// get and save diff-match-patch instance
		this.dmp = getDiffMatchPatchInstance(); 
				
		return this;
	}
	
	
	/* Private */
	
	private any function getDiffMatchPatchInstance(){
		return this.javaloader.create('name.fraser.neil.plaintext.diff_match_patch').init();
	}
	
	
	/* Public */
	
	public array function diff_main(text1,text2){
		return this.dmp.diff_main(arguments.text1,arguments.text2);
	}
	
	public void function diff_cleanupSemantic(diffs){
		return this.dmp.diff_cleanupSemantic(arguments.diffs);
	}
	
	public void function diff_cleanupEfficiency(diffs){
		return this.dmp.diff_cleanupEfficiency(arguments.diffs);
	}
	
	public numeric function diff_levenshtein(diffs){
		return this.dmp.diff_levenshtein(arguments.diffs);
	}
	
	public string function diff_prettyHtml(diffs){
		return this.dmp.diff_prettyHtml(arguments.diffs);
	}
	
	public any function match_main(text,pattern,loc){
		return this.dmp.match_main(arguments.text,arguments.pattern,arguments.loc);
	}
	
	public any function patch_make_text(text1, text2){
		return this.dmp.patch_make(arguments.text1,arguments.text2);
	}
	
	public any function patch_make_diffs(diffs){
		return this.dmp.patch_make(arguments.diffs);
	}
	
	public any function patch_make_text_diffs(text1, diffs){
		return this.dmp.patch_make(arguments.text1, arguments.diffs);
	}
	
	public any function patch_toText(patches){
		return this.dmp.patch_toText(arguments.patches);
	}
	
	public any function patch_fromText(text){
		return this.dmp.patch_fromText(arguments.text);
	}
	
	public any function patch_apply(patches, text1){
		return this.dmp.patch_apply(arguments.patches, arguments.text1);
	}
	
}	
</cfscript>