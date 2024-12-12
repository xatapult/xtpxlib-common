<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.message.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
    Message related templates.
    
    A [message](%message.xsd) is a standardized piece of XML used for inserting (error, debug, etc.) messages into XML documents.
	-->
  <!-- ================================================================== -->

  <xsl:template name="xtlc:msg-create" as="element(xtlc:message)">
    <!--~ 
      Generates a standard `xtlc:message` element.
    -->
    <xsl:param name="msg-parts" as="item()+" required="yes">
      <!--~ Message to show (parts will be concatenated by `xtlc:items2str()`). -->
    </xsl:param>
    <xsl:param name="status" as="xs:string" required="yes">
      <!--~ The status of the message. Must be one of the `$xtlc:status-*` constants as defined in [general.mod.xsl](%general.mod.xsl). -->
    </xsl:param>
    <xsl:param name="extra-attributes" as="attribute()*" required="no" select="()">
      <!--~ Any extra attributes to add to the message. -->
    </xsl:param>
    <xsl:param name="extra-contents" as="element()*" required="no" select="()">
      <!--~ Any extra elements to add to the message. -->
    </xsl:param>
    
    <xtlc:message status="{$status}" timestamp="{current-dateTime()}">
      <xsl:copy-of select="$extra-attributes"/>
      <xtlc:text>
        <xsl:value-of select="xtlc:items2str($msg-parts)"/>
      </xtlc:text>
      <xsl:copy-of select="$extra-contents"/>
    </xtlc:message>
    
  </xsl:template>
  
</xsl:stylesheet>
