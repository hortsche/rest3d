xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
import module namespace text = "http://exist-db.org/xquery/text";
    
(: extract api, extensionm version and namespace :)
let $params := subsequence(text:groups($exist:path, '^/?(.*?)/(.*)/([^/]+)(\..*)$'), 2)
let $params := if ($params[3]) then $params else subsequence(text:groups($exist:path, '^/?(.*?)/([^/]+)(\..*)$'), 1)
let $api := $params[3]
let $ext := if (starts-with($params[4],'.')) then substring-after($params[4],'.') else $params[4]
let $version := if (starts-with($params[1],'/')) then () else $params[1]
let $namespace := if (not($version)) then () else $params[2]
let $version := if (not($version)) then $params[2] else $version

return
    if ($exist:path eq '/') then
		<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			<redirect url="index.html"/>
		</dispatch>
    else if ($exist:path eq '/index.html') then
        ()
    else if (contains($exist:path,'wrapper')) then
        ()
    else if ($exist:path eq '') then
        ()
    else
        (: pass uri as parameters to the rest3d.xql :)
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<forward url="{concat($exist:controller,'/',$namespace,'/',$api,'.xql')}">
			<add-parameter name="api_version" value="{$version}"/>
			<add-parameter name="api_call" value="{$api}"/>
			<add-parameter name="api_format" value="{$ext}"/>
		</forward>
	</dispatch>
