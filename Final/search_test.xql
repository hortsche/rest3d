xquery version "1.0";
declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $title := "Search Form"

let $contains_supported := ('name', 'uploader', 'description', 'texture')
(: These are typically numbers, for each on there is both a min_ and max_ parameter :)
(: e.g. to search by effects, either use min_effects, max_effects or both :)
let $range_supported := ('effects', 'vertices', 'texture_coors', 'textures', 'triangles', 'normals')

return
<form enctype="multipart/form-data" method="get" action="search.xql">
    <fieldset>
        <legend>Search:</legend>
		<br />
        <legend>Name: </legend>
		<input type="text" name="name"/>
		<br />
        <legend>Uploader: </legend>
		<input type="text" name="uploader"/>
		<br />
        <legend>Description: </legend>
		<input type="text" name="description"/>
		<br />
        <legend>Texture: </legend>
		<input type="text" name="texture"/>
		<br />
        <legend>Minimum Effects: </legend>
		<input type="text" name="min_effects"/>
		<br />
        <legend>Maximum Effects: </legend>
		<input type="text" name="max_effects"/>
		<br />
        <legend>Minimum Vertices: </legend>
		<input type="text" name="min_vertices"/>
		<br />
        <legend>Maximum Vertices: </legend>
		<input type="text" name="max_vertices"/>
		<br />
        <legend>Minimum Texture Coordinates: </legend>
		<input type="text" name="min_texture_coors"/>
		<br />
        <legend>Maximum Texture Coordinates: </legend>
		<input type="text" name="max_texture_coors"/>
		<br />
        <legend>Minimum Textures: </legend>
		<input type="text" name="min_textures"/>
		<br />
        <legend>Maximum Textures: </legend>
		<input type="text" name="max_textures"/>
		<br />
        <legend>Minimum Triangles: </legend>
		<input type="text" name="min_triangles"/>
		<br />
        <legend>Maximum Triangles: </legend>
		<input type="text" name="max_triangles"/>
		<br />
        <legend>Minimum Normals: </legend>
		<input type="text" name="min_normals"/>
		<br />
        <legend>Maximum Normals: </legend>
		<input type="text" name="max_normals"/>
		<br />
		<legend>Order by: </legend>
		<select>
		<option value="order">name</option>
		<option value="order">uploader</option>
		<option value="order">description</option>
		<option value="order">textures</option>
		<option value="order">effects</option>
		<option value="order">vertices</option>
		<option value="order">texture_coors</option>
		<option value="order">trianges</option>
		<option value="order">normals</option>
		</select>
		<br />
		<legend>Direction: </legend>
		<input type="radio" name="direction" value="ascending" /> ascending
		<br />
		<input type="radio" name="direction" value="descending" /> descending
		<br />
        <input type="submit" value="Search"/>
	</fieldset>
</form>