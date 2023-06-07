<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.bbk_bmk_sxb" version="3.0" exclude-inline-prefixes="#all" type="xtlc:create-clear-directory" name="create-clear-directory">

  <p:documentation>
    This step does two things:
    * When `$clear` is true, it removes an (optionally) existing directory
    * Then it makes sure the directory always exists
    
    It doesn't matter whether the directory exists beforehand. 
    
    The step itself acts as an identity step. 
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="true" content-types="any">
    <p:empty/>
  </p:input>

  <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@create-clear-directory"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-dir" as="xs:string" required="true">
    <p:documentation>The full path/URI of the directory to delete.</p:documentation>
  </p:option>

  <p:option name="clear" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether or not to empty an existing directory.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:if test="$clear" name="delete-directory">
    <p:file-delete href="{$href-dir}" recursive="true" fail-on-error="false"/>
  </p:if>
  <p:file-mkdir href="{$href-dir}" depends="delete-directory"/>

</p:declare-step>
