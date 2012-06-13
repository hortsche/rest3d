xquery version "1.0";

module namespace find_attrib= "http://example.com/get_attrib";
declare namespace AWMI="http://www.collada.org/2005/11/COLLADASchema";

declare function find_attrib:find-attributes($uri) {
		
	let $file := doc($uri)

	return if ($file)
	then
	(
	     (: Retrieve the number of vertices. :)

		let $node := $file//AWMI:vertices/AWMI:input/@source
		
		let $source :=
		for $i in $node
		return substring(data($i), 2)
		
		let $node := $file//AWMI:source[contains(@id, $source)]
		let $vcount := sum( data($node//AWMI:accessor/@count) )
	
		(: Retrieve the number of texture coordinates. :)

		let $node := $file//AWMI:input[contains(@semantic, 'TEXCOORD')]/@source
		
		let $source :=
		for $i in $node
		return substring(data($i), 2)
		
		let $node := $file//AWMI:source[contains(@id, $source)]
		let $texcoorcount := sum( data($node//AWMI:accessor/@count) )
		
		(: Retrieve the number of triangles. :)

		let $tricount := sum( data($file//AWMI:triangles/@count) )
		
		(: Retrieve the number of normals. :)
		
		let $node := $file//AWMI:input[contains(@semantic, 'NORMAL')]/@source
		
		let $source :=
		for $i in $node
		return substring(data($i), 2)
		
		let $node := $file//AWMI:source[contains(@id, $source)]
		let $normcount := sum( data($node//AWMI:accessor/@count) )
		
		(: Retrieve the number of textures. :)
		
		let $node := $file//AWMI:library_images/AWMI:image
		let $texcount := count ($node)
		
		(: Retrieve the number of effects. :)
		
		let $node := $file//AWMI:library_materials/AWMI:material
		let $effectcount := count ($node)
		
		return
			  <count> 
				<effects> {data($effectcount)} </effects>
			    <vertices> {data($vcount)} </vertices> 
			    <texture_coors> {data($texcoorcount)} </texture_coors> 
				<textures> {data($texcount)} </textures>
			    <triangles> {data($tricount)} </triangles>
				<normals> {data($normcount)} </normals>
			  </count>
	)
	else
	(
		<error> Could not open document at {$uri} </error>
	)

};