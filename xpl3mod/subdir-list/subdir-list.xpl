<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.cxw_yt1_xkb" version="3.0" exclude-inline-prefixes="#all" type="xtlc:subdir-list">

  <p:documentation>
    Returns an XML document with the sub-directories of a given directory.
    
    ```
    &lt;subdir-list href="...">
      &lt;subdir href="..." name="..."/>  
      ...
    &lt;/subdir-list>
    ```
    
    If an error occurs, it will only return the root element with an additional error="true" attribute.
    Will not recurse! 
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="path" as="xs:string" required="true" use-when="not($develop)">
    <p:documentation>The path to get the sub-directories from. Always use an absolute path!</p:documentation>
  </p:option>
  <p:option name="path" as="xs:string" required="false" select="resolve-uri('../..', static-base-uri())" use-when="$develop"/>

  <p:output port="result" primary="true" content-types="xml" sequence="false" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The sub-directory listing (as described above).</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:try>
    <p:directory-list path="{$path}" max-depth="1"/>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl/create-subdir-list.xsl"/>
    </p:xslt>
    <p:catch>
      <p:identity>
        <p:with-input>
          <subdir-list href="{$path}" error="true"/>
        </p:with-input>
      </p:identity>
    </p:catch>
  </p:try>

</p:declare-step>
