<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.cxw_yt1_xkb" version="3.0" exclude-inline-prefixes="#all" type="xtlc:recursive-directory-list">

  <p:documentation>
    
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="path" as="xs:string" required="true">
    <p:documentation>The path to get the directory listing from.</p:documentation>
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

  <p:option name="flatten" as="xs:boolean" required="false" select="false()">
    <p:documentation>
        When `true`, the list will be "flattened": 
        All `c:file` children will be direct children of the root's `c:directory` element. 
        These `c:file` elements get a `@name`, `@href-abs` (absolute filename) and `@href-rel` (relative filename) attribute.
     </p:documentation>
  </p:option>

  <p:option name="detailed" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to add detailed information.</p:documentation>
  </p:option>

  <p:output port="result" primary="true" content-types="xml" sequence="false" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation> </p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:try>
    <p:directory-list path="{$path}" max-depth="{if ($depth lt 0) then 'unbounded' else $depth}" detailed="{$detailed}">
      <p:with-option name="include-filter" select="$include-filter"/>
      <p:with-option name="exclude-filter" select="$exclude-filter"/>
    </p:directory-list>
    <p:catch>
      <p:identity>
        <p:with-input port="source">
          <c:directory error="true" xml:base="{$path}"/>
        </p:with-input>
      </p:identity>
    </p:catch>
  </p:try>

  <p:if test="$flatten">
    <p:xslt>
      <p:with-input port="stylesheet">
        <p:document href="xsl/flatten-directory-list.xsl"/>
      </p:with-input>
    </p:xslt>
  </p:if>

</p:declare-step>
