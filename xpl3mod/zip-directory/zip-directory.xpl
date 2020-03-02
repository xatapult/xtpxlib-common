<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mgg_kmb_xkb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" type="xtlc:zip-directory">

  <p:documentation>
    
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:documentation>
      Zips a directory and its sub-directories into a single zip file.
    </p:documentation>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <p:import href="../recursive-directory-list/recursive-directory-list.xpl"/>

  <p:option name="href-target-zip" as="xs:string" required="true">
    <p:documentation>URI for the zip file to produce.</p:documentation>
  </p:option>

  <p:option name="include-base" as="xs:boolean" required="false" select="true()">
    <p:documentation>When true, the last part of `$base-path` (e.g. `a/b/c` ==> `c`) is used as the root directory in the zip file.</p:documentation>
  </p:option>

  <p:option name="base-path" as="xs:string" required="true">
    <p:documentation>URI of the directory which contents will be stored in the zip.</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"
    pipe="report@step-create-archive">
    <p:documentation>The manifest of the created zip file</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <xtlc:recursive-directory-list path="{$base-path}" flatten="false"/>

  <p:xslt parameters="map{'include-base': $include-base}">
    <p:with-input port="stylesheet">
      <p:document href="xsl/zip-directory-create-manifest.xsl"/>
    </p:with-input>
  </p:xslt>

  <p:archive name="step-create-archive">
    <p:with-input port="source">
      <p:empty/>
    </p:with-input>
    <p:with-input port="manifest" pipe="result"/>
  </p:archive>
  <p:store href="{$href-target-zip}"/>

</p:declare-step>
