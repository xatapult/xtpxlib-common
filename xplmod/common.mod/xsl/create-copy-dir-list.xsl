<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Create a list with file copy commands
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-source-dir" as="xs:string" required="yes"/>
  <xsl:param name="href-target-dir" as="xs:string" required="yes"/>

  <xsl:variable name="href-source-dir-normalized" as="xs:string" select="xtlc:href-canonical($href-source-dir)"/>
  <xsl:variable name="href-target-dir-normalized" as="xs:string" select="xtlc:href-canonical($href-target-dir)"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <dir-copy-file-list timestamp="{current-dateTime()}" href-source-dir="{$href-source-dir-normalized}"
      href-target-dir="{$href-target-dir-normalized}">
      <xsl:for-each select="//c:file">
        <xsl:variable name="directories" as="xs:string*" select="subsequence(ancestor::c:directory/@name/string(), 2)"/>
        <copy-file source="{xtlc:href-add-encoding(xtlc:href-concat(($href-source-dir-normalized, $directories, @name)))}"
          target="{xtlc:href-add-encoding(xtlc:href-concat(($href-target-dir-normalized, $directories, @name)))}"/>
      </xsl:for-each>
    </dir-copy-file-list>
  </xsl:template>

</xsl:stylesheet>
