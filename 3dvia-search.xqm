(: front-end for google warehouse :)
xquery version "1.0";

module namespace tdvia="http://rest3d.org/tdvia";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";

(: 
http://www.3dvia.com/search/
<form method="get">
<input name="search[query]" type="text" value="dae" /> 
<input name="search[tags_only]" type="checkbox" value="1"  /> Tags only
<input name="search[marketplace]" type="checkbox" value="1"  />   Store only 
<input name="search[results_per_page]" type="hidden" value="12" /> 
<input name="search[sort_order]" type="hidden" value="Rank" /> 
<input name="search[file_types]" type="hidden" value="1" /> 

** file format
<select id="model_file_formats" 
  value="?search%5Bformat%5D=3dxml&amp;search%5Bfile_types%5D=1" 3D XML
  value="?search%5Bformat%5D=3ds&amp;search%5Bfile_types%5D=1">3D Studio 
  value="?search%5Bformat%5D=kmz&amp;search%5Bfile_types%5D=1">Google Sketchup
  value="?search%5Bformat%5D=obj&amp;search%5Bfile_types%5D=1">Wavefront Format 
  value="?search%5Bformat%5D=wrl&amp;search%5Bfile_types%5D=1">Plain Text VRML
  value="?search%5Bformat%5D=ply&amp;search%5Bfile_types%5D=1">Polygon Format
  value="?search%5Bformat%5D=prj&amp;search%5Bfile_types%5D=1">3D Studio Project
  value="?search%5Bformat%5D=off&amp;search%5Bfile_types%5D=1">Object Format
  value="?search%5Bformat%5D=stl&amp;search%5Bfile_types%5D=1">3D Systems CAD 
  value="?search%5Bformat%5D=dae&amp;search%5Bfile_types%5D=1" selected="">COLLADA

** model software
<select id="model_software" 
 value="?search%5Bsoftware%5D=3DS&amp;search%5Bfile_types%5D=1">3DS
 value="?search%5Bsoftware%5D=Printscreen&amp;search%5Bfile_types%5D=1">3DVIA Printscreen
 value="?search%5Bsoftware%5D=3DVIA+Shape&amp;search%5Bfile_types%5D=1">3DVIA Shape
 value="?search%5Bsoftware%5D=Abaqus&amp;search%5Bfile_types%5D=1">Abaqus
 value="?search%5Bsoftware%5D=Blender&amp;search%5Bfile_types%5D=1">Blender
 value="?search%5Bsoftware%5D=CATIA&amp;search%5Bfile_types%5D=1">CATIA
 value="?search%5Bsoftware%5D=Google+Sketchup&amp;search%5Bfile_types%5D=1">Google Sketchup
 value="?search%5Bsoftware%5D=KML&amp;search%5Bfile_types%5D=1">KM
 value="?search%5Bsoftware%5D=Maya&amp;search%5Bfile_types%5D=1">May
 value="?search%5Bsoftware%5D=OBJ+Generator&amp;search%5Bfile_types%5D=1">OBJ Generator
 value="?search%5Bsoftware%5D=SolidWorks&amp;search%5Bfile_types%5D=1">SolidWorks
 value="?search%5Bsoftware%5D=Virtools&amp;search%5Bfile_types%5D=1">Virtool
 value="?search%5Bsoftware%5D=VRML+Generator&amp;search%5Bfile_types%5D=1">VRML Generator

** file category
<input name="search[file_types]"  value="1" /> Models
 href="?search%5Bfile_types%5D=3">Textures
 href="search%5Bfile_types%5D=13">Shaders
 href="?search%5Bfile_types%5D=99">Smart Objects

** 3D Apps
 href="?search%5Bfile_types%5D=4">Experiences 
 href="?search%5Bfile_types%5D=7">Scenes 

** 3D Components
 href="?search%5Bfile_types%5D=9">Templates
 href="search%5Bfile_types%5D=10">Building Blocks
 href="?search%5Bfile_types%5D=11">Behaviors

<input id="search-within-submit" type="submit" value="Search"/> --- button
:)


(: download requires login !! :)

(:

yopyop , melody works for now


<form name="user_login" action="/login" method="post">														
  <input type="hidden" name="returnUrl" value="http://www.3dvia.com/models/0496283A0C1E3002/ducky">
 <input type="hidden" name="type" value="download">
 <input type="hidden" name="swapmeetuser" value="">
  
<input type="text" name="signin[user_id]" value="" tabindex="1">
<input type="password" maxlength="30" name="signin[user_pwd]" value="" tabindex="2">
<input type="checkbox" name="signin[remember]" id="remember" checked="checked" tabindex="3">
  
<input type="image" class="submit spaced-top right" title="Sign In" src="/0-img/registration/img_btn_signin.gif" tabindex="4">
    	        

Here's a download link after login

http://www.3dvia.com/download.php?media_id=0496283A0C1E3002&amp;ext=zip&amp;file=/3dsearch/Content/0496283A0C1E3002.zip?Downloader=2&amp;Pass=
 
:)

(: while next... :)
declare function local:get-more-results($page as xs:integer,$warehouse as xs:string,$next as xs:string*) as element()*
{
  let $get := if ($next) then httpclient:get(xs:anyURI(concat($warehouse,$next)),false(),()) else ()
  let $more := data($get//div[@class eq 'pager_next']/../@href)
  return if ($more and $page ge 0) then ($get, local:get-more-results($page - 1,$warehouse,$more)) else $get
};

declare function tdvia:search($q as xs:string, $max-pages as xs:integer)
{
let $warehouse := 'http://www.3dvia.com'
let $api := '/search/'

let $results-per-pages := xs:string(12 * $max-pages)
let $params := concat('search[query]=',$q,'&amp;search[results_per_page]=',$results-per-pages,'&amp;search[sort_order]=Rank&amp;search[file_types]=1&amp;search[format]=dae')
let $params := rest3d:to-form($params)
let $results := httpclient:get(xs:anyURI(concat($warehouse,$api,'?',$params)),false(),())

(: here we should check if there are any results :)

(: now parse the html pages to create response :)
let $response := 
  for $item in $results//xhtml:li[contains(@class,'size1of4')] 
  let $price := $item//xhtml:div[contains(@class,'icon-purchase')]/text()
  let $icon := data($item//xhtml:div[@class eq 'thumbnail-photo']//xhtml:img/@src)
  let $url := data($item//xhtml:div[@class eq 'thumbnail-photo']/xhtml:a/@href)
  let $id := replace($url,'/models/(.*?)/.*$','$1')
  let $filename := replace($url,'/models/(.*?)/(.*)$','$2')
  let $author := $item//xhtml:div[@class eq 'tooltip']/xhtml:p[1]/text()
  let $info := data($item//xhtml:div[@class eq 'tooltip']//xhtml:a/@href)
  let $title := $item//xhtml:div[@class eq 'tooltip']//xhtml:h4/text()
  let $description := ''
  let $badge := '' 
  let $toolchain := $item//xhtml:div[@class eq 'tooltip']/xhtml:p[3]/text()
  let $download := concat($warehouse,'/login?returnUrl=http%3A%2F%2Fwww.3dvia.com%2Fmodels%2F',$id,'%2F',$filename,'&amp;type=download')
  let $download := concat($warehouse,'/download.php?media_id=',$id,'&amp;file=%2F3dsearch%2FContent%2F',$id,'.zip&amp;Downloader=2')
  return(
      element model {
         element server {$warehouse},
         element title {$title},
         element description {$description},
         element toolchain {$toolchain},
         element icon {attribute type {'img'}, data($icon)},
         element badge {$badge},
         element author {$author},
         element id {$id},
         element filename {$filename},
         element format {'zip'},
         element download {attribute type {'url'}, $download},
         element info { attribute type {'url'} , concat($warehouse,$info)},
element copy {attribute type {'url'}, concat('copy.xml?server=3dvia&amp;id=',$id,'&amp;download=',$download)}
  })
return $response

};

