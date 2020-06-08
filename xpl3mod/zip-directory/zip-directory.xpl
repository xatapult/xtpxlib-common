<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mgg_kmb_xkb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" type="xtlc:zip-directory">

  <p:documentation>
    Zips a directory into a single zip file.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:import href="../recursive-directory-list/recursive-directory-list.xpl"/>

  <p:option name="base-path" as="xs:string" required="true">
    <p:documentation>URI of the directory which contents will be stored in the zip.</p:documentation>
  </p:option>

  <p:option name="include-filter" as="xs:string*" required="false">
    <p:documentation>Optional regular expression include filters.</p:documentation>
  </p:option>

  <p:option name="exclude-filter" as="xs:string*" required="false" select="'\.git/'">
    <p:documentation>Optional regular expression exclude filters. By default, git directories are excluded.</p:documentation>
  </p:option>

  <p:option name="depth" as="xs:integer" required="false" select="-1">
    <p:documentation>The sub-directory depth to go. When lt `0`, all sub-directories are processed.</p:documentation>
  </p:option>

  <p:option name="href-target-zip" as="xs:string" required="true">
    <p:documentation>URI for the zip file to produce.</p:documentation>
  </p:option>

  <p:option name="include-base" as="xs:boolean" required="false" select="true()">
    <p:documentation>When true, the last part of `$base-path` (for instance `a/b/c` ==> `c`) is used as root directory for entries in the zip file.
    </p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"
    pipe="report@step-create-archive">
    <p:documentation>The archive manifest of the created zip file.</p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <xtlc:recursive-directory-list path="{$base-path}" depth="{$depth}" flatten="false">
    <p:with-option name="include-filter" select="$include-filter"/>
    <p:with-option name="exclude-filter" select="$exclude-filter"/>
  </xtlc:recursive-directory-list>

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
