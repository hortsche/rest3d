(: front-end for google warehouse :)
xquery version "1.0";

module namespace warehouse="http://rest3d.org/warehouse";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";

(: 
http://sketchup.google.com/3dwarehouse
<form action="/3dwarehouse/doadvsearch" method="GET">
<input type="text" name="title" > Find items with all of these words in the title
<input type="text" name="dscr" > Find items with any of these words in the description
<input type="text" name="tags"> Find items with all of these tags
<select name="scoring">
   ** value="d">  Sort by date
    value="r"> Sort by rating
    value="p"> Sort by popularity
<selet name="styp">
    value="c" Find items that are collections
    value="m" Find items that are models
<select name="stars"> Find items with this star rating or better
   value="any_value">any</option>
   value="5"> 5
   value="4"> 4
   value="3"> 3
   value="2"> 2
   value="1"> 1
<input type="text" name="nickname"> Find items by this author
<select name="createtime"> Find items created in this time frame
  value="any_value>any time
  value="hour1">past 1 hour
  value="hour2">past 2 hours
  value="day1">past 24 hours
  value="week1">past week
  value="week2">past 2 weeks
  value="month1">past month
  value="year1">past year
<select name="modtime"> Find items last modified in this time frame
  value="any_value">any time
  value="hour1">past 1 hour
  value="hour2">past 2 hours
  value="day1">past 24 hours
  value="week1">past week
  value="week2">past 2 weeks
  value="month1">past month
  value="year1">past year
<select name="isgeo" id="located">  Find items that have a location on Earth
   value="any_value">located and non-located
   value="true">located only
   value="false">non-located only</option></select>
<input type="text" name="addr""> Find items that are near this address
<input type="text" name="clid"> Find items that are in the collection with this URL or ID
 
 
******* model search options *********
<select name="complexity">
    ** value="any_value" any
    value="high" complex
    value="medium" moderate
    value="low" simple
<select name="file">
    *** value="any_value" any
    value="zip" Collada 
    value="kmz" Google Earth 
    value="skp" SketchUp 
<input  type="checkbox" name="isbestofgeo" value="true">Show only models that are in  Google Earth "3D Buildings" 
<input type="checkbox" name="dwld" value="true"> Show only downloadable models
<input type="checkbox" name="isdyn" value="true"> Show only dynamic models


<input type="submit" name="btnG" value="Search+3D+Warehouse"></span>

:)

(: while next... :)
declare function local:get-more-results($page as xs:integer,$warehouse as xs:string,$next as xs:string*) as element()*
{
  let $get := if ($next) then httpclient:get(xs:anyURI(concat($warehouse,$next)),false(),()) else ()
  let $more := data($get//div[@class eq 'pager_next']/../@href)
  return if ($more and $page ge 0) then ($get, local:get-more-results($page - 1,$warehouse,$more)) else $get
};

declare function warehouse:search($q as xs:string, $max-pages as xs:integer)
{
let $warehouse := 'http://sketchup.google.com'
let $api := '/3dwarehouse/doadvsearch'
let $params := concat('title=',$q,'&amp;styp=m&amp;file=zip&amp;dwld=true')
let $params := rest3d:to-form($params)
let $get := httpclient:get(xs:anyURI(concat($warehouse,$api,'?',$params)),false(),())

(: here we should check if there are any results :)

(: here we check if there are more results to fetch :)
let $next := data($get//div[@class eq 'pager_next']/../@href)
let $results := local:get-more-results($max-pages,$warehouse,$next)

(: now parse the html pages to create response :)
let $response := 
  for $item in $results//div[@class eq 'resulttitle']/.. 
  let $url := data($item//a[@class eq 'dwnld']/@href)
  let $id := replace($url,'.*?mid=(.*?)&amp;.*$','$1')
  let $filename := replace($url,'.*?fn=(.*?)&amp;.*$','$1')
  let $download := concat($warehouse,'/3dwarehouse/download?mid=',$id,'&amp;fn=',$filename,'&amp;rtyp=zip')
  return
      element model {
         element server {$warehouse},
         element title {$item//span[@id eq 'bylinetitle']/a/text()},
         element description {$item/span/text()},
         element icon {attribute type {'img'}, concat($warehouse,data($item/..//img/@src))},
         element badge {data($item//span[@class eq 'model-badge']//@title)},
         element author {$item//a[@class eq 'author']/text()},
         element id {$id},
         element filename {$filename},
         element format {'zip'},
         element download {attribute type {'url'}, $download},
         element info { attribute type {'url'} , concat($warehouse,'/3dwarehouse/details?mid=',$id)},
         element copy {attribute type {'url'}, concat('copy.xml?server=warehouse&amp;id=',$id,'&amp;download=',$download)}
  }
return $response
};

(: copy from warehouse to rest3d server :)
declare function warehouse:copy($id as xs:string, $download as xs:string) {

  (: get zip from server :)
  let $file := httpclient:get(xs:anyURI($download),false(),())
  return element RESULT { element url {$download}, element html {$file}}
};
