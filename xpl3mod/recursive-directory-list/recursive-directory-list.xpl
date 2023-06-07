<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.cxw_yt1_xkb" version="3.0" exclude-inline-prefixes="#all" type="xtlc:recursive-directory-list">

  <p:documentation>
    Extension of standard the `p:directory` list step.
    Returns the contents of a directory, going into sub-directories recursively. 
    Adds the possibility to "flatten" the list.
    
    This step will also *not* throw an error when the directory does not exist. 
    Instead it will simply return an empty result (with an `error="true` attribute).
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

  <p:option name="add-decoded" as="xs:boolean" required="false" select="false()">
    <p:documentation>
        When `true` and `$flatten` is `true`, attributes `@href-rel-decoded` and `@href-abs-decoded` are added in which any percent 
        encoded characters are decoded.
     </p:documentation>
  </p:option>


  <p:option name="detailed" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to add detailed information.</p:documentation>
  </p:option>

  <p:option name="override-content-types" as="array(array(xs:string))?" required="false" select="()">
    <p:documentation>Override content types specification (see description of `p:directory-list`).</p:documentation>
  </p:option>

  <p:output port="result" primary="true" content-types="xml" sequence="false" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting directory structure in XML format. See the standard `p:directory-list` step for a more detailed description.
    </p:documentation>
  </p:output>

  <!-- ================================================================== -->

  <p:try>
    <p:directory-list path="{$path}" max-depth="{if ($depth lt 0) then 'unbounded' else $depth}" detailed="{$detailed}">
      <p:with-option name="include-filter" select="$include-filter"/>
      <p:with-option name="exclude-filter" select="$exclude-filter"/>
      <p:with-option name="override-content-types" select="$override-content-types"/>
    </p:directory-list>
    <p:catch>
      <p:identity>
        <p:with-input>
          <c:directory xml:base="{$path}" name="{(tokenize($path, '/')[.])[last()]}" error="true"/>
        </p:with-input>
      </p:identity>
    </p:catch>
  </p:try>

  <p:if test="$flatten">
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl/flatten-directory-list.xsl"/>
      <p:with-option name="parameters" select="map{'add-decoded': $add-decoded}"/>
    </p:xslt>
  </p:if>

</p:declare-step>
