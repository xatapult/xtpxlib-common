<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mgg_kmb_xkb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" type="xtlc:write-log" name="write-log">

  <p:documentation>
    Writes an entry to a log file. 
    
    With regards to documents flowing through, acts like a `p:identity` step.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="true" content-types="any">
    <p:documentation>Documents will be passed unchanged to the `result` port.</p:documentation>
  </p:input>

  <p:option name="href-log" as="xs:string" required="true">
    <p:documentation>URI of the file to write the log entries to.</p:documentation>
  </p:option>

  <p:option name="log-comments" as="xs:string*" required="false" select="()">
    <p:documentation>Any comments to write as file header when creating a new log file. Ignored on an existing log file.</p:documentation>
  </p:option>

  <p:option name="enable" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether the logging will be done at all.</p:documentation>
  </p:option>

  <p:option name="enable-debug-messages" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether messages with debug status will be written as well.</p:documentation>
  </p:option>

  <p:option name="status" as="xs:string" required="false" select="'info'" values="('info', 'warning', 'error', 'debug')">
    <p:documentation>Status of the entry. Must be `info`, `warning`, `error` or `debug`.</p:documentation>
  </p:option>

  <p:option name="messages" as="xs:string+" required="true">
    <p:documentation>The actual texts/lines of the log entry to write. All will become a separate `message` element.</p:documentation>
  </p:option>

  <p:option name="additional-attributes" as="map(xs:QName, xs:string)?" required="false" select="()">
    <p:documentation>A map with additional attributes to add to the log entry's `entry` element.</p:documentation>
  </p:option>

  <p:option name="additional-elements" as="element()*" required="false" select="()">
    <p:documentation>Elements with additional information to add to this log entry.</p:documentation>
  </p:option>

  <p:option name="keep-entries" as="xs:integer" required="false" select="0">
    <p:documentation>The number of entries to keep in the logfile. If le `0`, all messages are kept.</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@write-log">
    <p:documentation>Documents coming from the `source` port, unchanged.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->

  <p:if test="(normalize-space($href-log) ne '') and $enable and (($status ne 'debug') or $enable-debug-messages)">

    <p:xslt>
      <p:with-input port="source">
        <null/>
      </p:with-input>
      <p:with-input port="stylesheet" href="xsl/write-to-log.xsl"/>
      <p:with-option name="parameters"
        select="map{
          'href-log': $href-log,
          'log-comments': $log-comments,
          'status': $status,
          'messages': $messages,
          'keep-entries': $keep-entries,
          'additional-attributes': $additional-attributes,
          'additional-elements': $additional-elements
        }"
      />
    </p:xslt>

    <p:store href="{$href-log}" serialization="map{ 'method': 'xml', 'indent': true() }"/>

  </p:if>

</p:declare-step>
