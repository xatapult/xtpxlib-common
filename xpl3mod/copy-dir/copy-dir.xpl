<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.gpk_zmk_sxb" version="3.0" exclude-inline-prefixes="#all" type="xtlc:copy-dir" name="copy-dir">

  <p:documentation>
    This step copies a directory and all its contents from one location to the other. 
    * If $clear-target is true (default), before copying the target directory is cleared/emptied. 
    * If the source directory is empty, it simply creates an empty target directory.
    * It can do include/exclude filtering, like `p:directory-list`
    
    The step itself acts as an identity step.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../recursive-directory-list/recursive-directory-list.xpl"/>
  <p:import href="../create-clear-directory/create-clear-directory.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="true" content-types="any">
    <p:empty/>
  </p:input>

  <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@copy-dir"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-source" as="xs:string" required="true">
    <p:documentation>The full path/URI of the source directory. If the directory does not exist, nothing will happen.</p:documentation>
  </p:option>

  <p:option name="href-target" as="xs:string" required="true">
    <p:documentation>The full path/URI of the target directory. Any non-existing parent directories leading up to this 
      directory will be automatically created.</p:documentation>
  </p:option>

  <p:option name="include-filter" as="xs:string*" required="false" select="()">
    <p:documentation>Regular expression(s) files to be included in the copy.</p:documentation>
  </p:option>

  <p:option name="exclude-filter" as="xs:string*" required="false" select="'\.git/'">
    <p:documentation>Regular expression(s) for files to be excluded from the copy. By default, git directories are excluded</p:documentation>
  </p:option>

  <p:option name="clear-target" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to clear the target before copying.</p:documentation>
  </p:option>

  <p:option name="depth" as="xs:integer" required="false" select="-1">
    <p:documentation>The sub-directory depth to go. When lt `0`, all sub-directories are processed.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Clear the target if requested: -->
  <xtlc:create-clear-directory href-dir="{$href-target}" clear="{$clear-target}"/>

  <!-- Get a list -->
  <xtlc:recursive-directory-list flatten="true" depth="{$depth}" path="{$href-source}">
    <p:with-option name="include-filter" select="$include-filter"/>
    <p:with-option name="exclude-filter" select="$exclude-filter"/>
  </xtlc:recursive-directory-list>

  <!-- File by file copy: -->
  <p:for-each>
    <p:with-input select="/*/c:file"/>
    <p:variable name="href-source-file" as="xs:string" select="/*/@href-abs"/>
    <p:variable name="href-target-file" as="xs:string" select="string-join(($href-target, /*/@href-rel), '/')"/>
    <p:file-copy href="{$href-source-file}" target="{$href-target-file}"/>
  </p:for-each>

</p:declare-step>
