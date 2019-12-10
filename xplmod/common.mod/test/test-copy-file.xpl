<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
   Test driver for the library tee step.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../common.mod.xpl"/>

  <!-- ================================================================== -->

  <p:identity>
    <p:input port="source">
      <p:inline>
        <COPYTEST/>
      </p:inline>
    </p:input>
  </p:identity>

  <!-- Straight copy of XML file: -->
  <xtlc:copy-file>
    <p:with-option name="href-source" select="static-base-uri()"/>
    <p:with-option name="href-target" select="resolve-uri('../../../tmp/test-copy-file-result-1.xml', static-base-uri())"/>
  </xtlc:copy-file>

  <!-- Any whitespace or other difficult characters must be % escaped! -->
  
</p:declare-step>
