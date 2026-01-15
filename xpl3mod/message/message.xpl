<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.j5g_dlx_yhc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all">

  <!-- ======================================================================= -->

  <p:option static="true" name="xtlc:default-message-prompt" as="xs:string" select="'*'">
    <p:documentation>The default prompt string for messages.</p:documentation>
  </p:option>

  <p:option static="true" name="xtlc:default-message-debug-marker" as="xs:string" select="'D'">
    <p:documentation>The default marker for debug messages.</p:documentation>
  </p:option>

  <!-- ======================================================================= -->

  <p:declare-step name="message" type="xtlc:message">

    <p:documentation>
      Writes a message to the console, taking care of indents and a prompt.
      The step itself acts as an identity step.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:input port="source" primary="true" sequence="true" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@message"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:option name="text" as="xs:string*" required="false" select="()">
      <p:documentation>Every member of this sequence gets a line on its own. If empty, an empty line is output.</p:documentation>
    </p:option>

    <p:option name="level" as="xs:integer" required="false" select="0">
      <p:documentation>The indent for the message.</p:documentation>
    </p:option>

    <p:option name="silent" as="xs:boolean" required="false" select="false()">
      <p:documentation>Whether the message should appear.</p:documentation>
    </p:option>

    <p:option name="enabled" as="xs:boolean" required="false" select="true()">
      <p:documentation>Another way to determine whether the message should appear.</p:documentation>
    </p:option>

    <p:option name="debug" as="xs:boolean" required="false" select="false()">
      <p:documentation>Turns the prompt into $debug-marker in-between the prompt characters to signify a debug message.</p:documentation>
    </p:option>

    <p:option name="prompt-string" as="xs:string" required="false" select="$xtlc:default-message-prompt">
      <p:documentation>The prompting character(s) to use (after an indent).</p:documentation>
    </p:option>

    <p:option name="debug-marker" as="xs:string" required="false" select="$xtlc:default-message-debug-marker">
      <p:documentation>The marker for a debug message.</p:documentation>
    </p:option>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:if test="not($silent) and $enabled">
      <p:choose>
        <p:when test="empty($text)">
          <p:identity message=""/>
        </p:when>
        <p:otherwise>
          <p:variable name="prompt-spacing" as="xs:string" select="string-join(for $n in (1 to string-length($prompt-string)) return ' ') || ' '"/>
          <p:variable name="prompt" as="xs:string"
            select="string-join(for $n in (1 to $level) return $prompt-spacing) || $prompt-string || (if ($debug) then ($debug-marker || $prompt-string) else ()) || ' '"/>
          <p:for-each>
            <p:with-input select="$text">
              <dummy/>
            </p:with-input>
            <p:identity message="{$prompt}{string(.)}"/>
          </p:for-each>
        </p:otherwise>
      </p:choose>
    </p:if>

  </p:declare-step>

</p:library>
