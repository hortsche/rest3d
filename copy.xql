(: front-end for google warehouse :)
xquery version "1.0";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";
import module namespace warehouse="http://rest3d.org/warehouse" at "warehouse-search.xqm";
import module namespace tdvia="http://rest3d.org/tdvia" at "3dvia-search.xqm";
import module namespace ourbricks="http://rest3d.org/ourbricks" at "ourbricks-search.xqm";

(: this filter the files to be unzipped :)
declare function local:filter($path as xs:string, $type as xs:string, $param as item()*) as xs:boolean
{
 true()
};

(: this function does something with the extrated data :)
declare function local:data($path as xs:string, $type as xs:string, $data as item()?, $param as item()*)
{
 (: create collection as the id :)
 
 (: return the path and type :)
 let $ext := replace($path,'(.*?)\.(.*)','$2')
 let $tmp :=
   if ($ext eq 'kml) then () (: kml contains lat/lon :)
   if ($ext eq 'dae') then () (: here's our collada file :)
   else () (: consider this as binary :)
 return element data {element extension {$ext}, element path {$path}, element type {$type}}
};

let $filter-function := util:function(QName("local","local:filter"),3)
let $server as xs:string := request:get-parameter('server','')
let $id as xs:string := request:get-parameter('id','')
let $download as xs:string := request:get-query-string()
let $url := replace($download,'(.*?)download=(.*)$','$2')

let $response := if ($server eq 'warehouse') then warehouse:copy($id, $url)
                 else element error {concat('unknown server ',$server)}

let $headers := $response//httpclient:headers
let $zip-data := data($response//httpclient:body)

let $metadata := (element author {data($headers/httpclient:header[@name='X-3DWarehouse-AuthorNickname']/@value)},
                  element description {data($headers/httpclient:header[@name='X-3DWarehouse-Description']/@value)},
                  element title {data($headers/httpclient:header[@name='X-3DWarehouse-Title']/@value)},
                  element id {data($headers/httpclient:header[@name='X-3DWarehouse-ModelID']/@value)})

let $data-function := util:function(QName("local","local:data"),4)
let $zip-file := compression:unzip($zip-data, $filter-function, (), $data-function, ()) 

let $response := element response {element url {$url}, $zip-file}

return rest3d:format($response)
