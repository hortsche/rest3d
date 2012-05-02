declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $title := 'Search Specific Hash'
 
return
<html>
    <head>
         <title>{$title}</title>
     </head>
     <body>
     <h1>{$title}</h1>
     <form method="GET" action="download.xql">
        <p>
            <strong>Hash Search:</strong>
            <input name="q" type="text"/>
        </p>
        <p>
            <input type="submit" value="Search"/>
        </p>
    </form>
    </body>
</html>