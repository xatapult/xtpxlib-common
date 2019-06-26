<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the library zip directory step. Zips the xtpxlib tree.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:option name="debug" required="false" select="string(false())"/>
  
  <p:option name="href-source-dir" required="false" select="resolve-uri('../test', static-base-uri())"/>
  <p:option name="href-target-dir" required="false" select="resolve-uri('../../../tmp/testcopy', static-base-uri())"/>
    
  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true"/>
  
  <p:import href="../common.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <p:identity>
    <p:input port="source">
      <p:inline>
        <UNCHANGED-AFTER-DIR-COPY/>
      </p:inline>
    </p:input>
  </p:identity>
  <p:add-attribute attribute-name="timestamp" match="/*">
    <p:with-option name="attribute-value" select="current-dateTime()"/>
  </p:add-attribute>
  
  <xtlc:copy-directory>
    <p:with-option name="href-source-dir" select="$href-source-dir"/> 
    <p:with-option name="href-target-dir" select="$href-target-dir"/>
  </xtlc:copy-directory>
  
</p:declare-step>
