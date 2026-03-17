<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.wxl_4td_f2c"
  exclude-result-prefixes="#all" expand-text="true">

  <xsl:mode on-no-match="fail"/>

  <xsl:template match="/">
    <_GENERATED>
      <GENERATED-CONTENTS1 generator="{static-base-uri()}" timestamp="{current-dateTime()}">
        <xsl:value-of select="//message"/>
        <!--<xsl:value-of select="error((), 'wrong')"/>-->
      </GENERATED-CONTENTS1>
      <GENERATED-CONTENTS2 generator="{static-base-uri()}" timestamp="{current-dateTime()}">
        <xsl:value-of select="//message"/>
        <!--<xsl:value-of select="error((), 'wrong')"/>-->
      </GENERATED-CONTENTS2>
    </_GENERATED>
  </xsl:template>

</xsl:stylesheet>
