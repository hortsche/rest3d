xquery version "1.0";

import module namespace rest3d = "http://rest3d.org" at "rest3d.xqm";
import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace response="http://exist-db.org/xquery/response";
import module namespace compression="http://exist-db.org/xquery/compression";
declare option exist:serialize "media-type=text/xml"; 

	let $collection := '/db/rest3d'
	let $collection-model := fn:concat($collection,'/models')
	let $collection-texture := fn:concat($collection,'/textures')
	let $collection-xml := fn:concat($collection,'/xml')

	(: get the search query string from the URL parameter :)
	let $q := request:get-parameter('q', '')
	(: prevent injection attacks :)
	let $filtered-q := replace($q, "[&amp;&quot;-*;-`~!@#$%^*()_+-=\[\]\{\}\|';:/.,?(:]", "") 
	let $xmlfilename := concat($collection-xml,'/', $q, '.xml')
	let $login := xmldb:login($collection, 'admin', 'rest3d')
	 
	let $result :=
	if(not($q))
	then
	( 
		<p>Please enter a hash to download</p>
	)
	else
	(
		if (doc-available($xmlfilename))
		then
		(
			let $xmlfile := doc($xmlfilename)
			let $filepath := concat($collection-model,'/', $q, '.dae')
			let $xmlfinal := concat('/exist/rest/',$xmlfilename)
			let $final := fn:doc($filepath)
			(: GET TEXTURES IN XML, ZIP FILES :)
			let $textures := $xmlfile//model/texture
			(: loop here for textures into entries :)
			let $texturefiles :=
				for $x in $textures
					let $jpgname := $x/filename/text()
					let $file := $x/file/text()
					return
						<entry name="{concat('textures/',$jpgname)}" type="uri">{concat($collection-texture, '/', $file)}</entry>
			let $entries := ($texturefiles, <entry name="{$xmlfile//model/filename/text()}" type="xml">{$final}</entry>)
			let $zip := compression:zip($entries, true())
			return
				response:stream-binary($zip, 'zip', 'model.zip')
			(: need to return xml doc with info:)
		)
		else
		( 
			(: could not find file :)
			<p>File {$xmlfilename}  not found, check hash for correctness</p>
		)
	)
	return $result
