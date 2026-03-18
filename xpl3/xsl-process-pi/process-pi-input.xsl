<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.kls_zsz_p3c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
      Processes an input document for process-pi.xpl into a <commands> XML structure,
      suitable for further processing by the pipeline.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:include href="../../xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="trigger-string" as="xs:string" select="'xtpxlib-process'"/>

  <xsl:variable name="key-command" as="xs:integer" select="1"/>
  <xsl:variable name="key-parameters" as="xs:integer" select="2"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <!-- Get the relevant lines to process: -->
    <xsl:variable name="lines-to-process" as="xs:string*">

      <!-- Text nodes: -->
      <xsl:for-each select="/text()[normalize-space(.) ne '']">
        <xsl:variable name="input-lines" as="xs:string*" select="xtlc:text2lines(., false(), false())"/>
        <xsl:iterate select="1 to count($input-lines)">
          <xsl:param name="index" as="xs:integer" select="1"/>
          <xsl:param name="result-lines" as="xs:string*" select="()"/>

          <xsl:on-completion select="$result-lines"/>

          <xsl:variable name="line" as="xs:string" select="$input-lines[$index]"/>
          <xsl:choose>
            <xsl:when test="ends-with(xtlc:str2seq($line)[1], $trigger-string)">
              <xsl:next-iteration>
                <xsl:with-param name="index" as="xs:integer" select="$index + 1"/>
                <xsl:with-param name="result-lines" as="xs:string*" select="($result-lines, substring-after($line, $trigger-string))"/>
              </xsl:next-iteration>
            </xsl:when>
            <xsl:otherwise>
              <!-- This line does not contain the trigger string, so we can stop looking: -->
              <xsl:break select="$result-lines"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:iterate>
      </xsl:for-each>

      <!-- PIs: -->
      <xsl:for-each select="/processing-instruction()[local-name() eq $trigger-string]">
        <xsl:sequence select="string(.)"/>
      </xsl:for-each>

      <!-- Comments: -->
      <xsl:for-each select="/comment()[starts-with(normalize-space(.), $trigger-string || ' ')]">
        <xsl:sequence select="substring-after(., $trigger-string)"/>
      </xsl:for-each>

    </xsl:variable>

    <!-- Turn everything into a commands structure: -->
    <commands href="{base-uri()}">
      <xsl:for-each select="$lines-to-process[normalize-space(.) ne '']">
        <xsl:variable name="line" as="xs:string" select="."/>
        <xsl:variable name="command" as="xs:string" select="xtlc:str2seq($line)[1]"/>
        <command name="{$command}" line="{$line}">
          <!-- Here we analyze the string for parameters. These can be delimited by " or ' characters. -->
          <xsl:analyze-string select="substring-after($line, $command)" regex="(\c+)(=(&quot;.*?&quot;|&apos;.*?&apos;|\S*))?">
            <xsl:matching-substring>
              <par name="{regex-group(1)}" value="{regex-group(3) => replace('^[&quot;&apos;&apos;]', '') => replace('[&quot;&apos;&apos;]$', '')}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring/>
          </xsl:analyze-string>
        </command>

      </xsl:for-each>
    </commands>

  </xsl:template>

</xsl:stylesheet>
