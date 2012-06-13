xquery version "1.0";

import module namespace rest3d = "http://rest3d.org" at "rest3d.xqm";
import module namespace find_attrib = "http://example.com/get_attrib" at "get_attrib.xqm";
import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace response="http://exist-db.org/xquery/response";

let $supported := ('name', 'uploader', 'description') (: list of supported fields :)

let $collection := '/db/rest3d'
let $collection-model := fn:concat($collection,'/models')
let $collection-texture := fn:concat($collection,'/textures')
let $collection-xml := fn:concat($collection,'/xml')

let $hash-alg := 'md5'

let $filename := replace(xs:string(request:get-uploaded-file-name('model')), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")

(: make sure you use the right user permissions that has write access to this collection :)
let $login := xmldb:login($collection, 'admin', 'rest3d')
let $result :=
if (not($login))
then
( 
	(: Error - Could not log into database :)
	<error>
		<message>Internal Error</message>
		<details>Failed to log into database</details>
	</error>
)
else
(
	(: Logged in, check that file exists :)
	if (not($filename))
	then
	(
		(: No Filename means no file or all illegal characters :)
		<error>
			<message>Bad Request</message>
			<details>Bad filename or no file uploaded.  Must be in request as attribute: model</details>
		</error>
	)
	else
	(
		let $file := request:get-uploaded-file-data('model')
		let $hash := util:hash($file,$hash-alg)
		let $uri := concat($collection-model,'/', $hash, '.dae')
		return if (fn:doc-available(fn:concat($collection-xml,'/',$hash,'.xml')))
		then
		(
			<error>
				<message>File Exists</message>
				<details>A file with the same hash was already found in the database</details>
			</error>
		)
		else
		(
			let $store := xmldb:store($collection-model, concat($hash,'.dae'), $file, 'text/xml')
			return if (not($store))
			then
			(
				<error>
					<message>Could Not Store</message>
					<details>Not sure what went wrong</details>
				</error>
			)
			else
			(
				<model>
					<id>{$hash}</id>
					<filename>{$filename}</filename>
					<created>{current-time()}</created>
					{for $item in $supported
					let $filtered := replace(xs:string(request:get-parameter($item,"")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
					return
						util:eval(fn:concat("<",$item,">",$filtered,"</",$item,">","&#10;"))
					}
					{for $item in request:get-parameter-names()
						let $texture-name := replace(xs:string(request:get-uploaded-file-name($item)), "[^0-9a-zA-ZäöüßÄÖÜ\-,._ ]", "")
						where xs:string($item) >= xs:string('texture')
						return
							if ($texture-name)
							then
							(
								let $texture := request:get-uploaded-file-data($item)
								let $hash := util:hash(util:binary-to-string($texture),$hash-alg)
								let $texture-upload := xmldb:store($collection-texture, $hash, $texture, 'image/jpeg')
								return
								<texture>
									<file>{$hash}</file>
									<filename>{$texture-name}</filename>
								</texture>
							)
							else()
					}
					{find_attrib:find-attributes($uri)}
				</model>
			)
		)
	)
)
return if($result//id/text())
then
(
	let $xml := xmldb:store($collection-xml, fn:concat($result//id/text(),'.xml'), $result)
	return if($xml)
		then rest3d:format($result)
		else 
		(
		<error>
			<message>Could not save XML</message>
			<details>Bad Configuration  Out of Room</details>
		</error>
		)
)
else
(
	rest3d:format($result)
)
