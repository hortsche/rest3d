declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $title := "Upload Test"

return
<form enctype="multipart/form-data" method="post" action="upload.xql">
    <fieldset>
        <legend>Upload Document:</legend>
		<br />
        <legend>Model: </legend>
		<input type="file" name="model"/>
		<br />
		<legend>Textures</legend>
		<br />
		<input type="file" name="texture"/>
		<br />
		<input type="file" name="texture1abc"/>
		<br />
		<input type="file" name="texture2"/>
		<br />
		<input type="file" name="texture1"/>
		<br />
		<input type="file" name="textureagain"/>
		<br />
		<input type="file" name="texturec"/>
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
		<input type="radio" name="api_format" value="xml" /> xml
		<br />
		<input type="radio" name="api_format" value="json" /> json
		<br />
		<input type="radio" name="api_format" value="html" /> html
		<br />
        <input type="submit" value="Upload"/>
    </fieldset>
</form>
