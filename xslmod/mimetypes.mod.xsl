<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.mimetypes.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtl-mimetypes="http://www.xtpxlib.nl/ns/mimetypes" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
    MIME type conversion related functions.
    
    These conversions work with an [external MIME type/extension table](%mimetypes-table.xml).
	-->
  <!-- ================================================================== -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:variable name="local:mime-types-table" as="element(xtl-mimetypes:mimetypes)" select="doc('../data/mimetypes-table.xml')/*"/>

  <!-- ================================================================== -->

  <xsl:function name="xtlc:ext2mimetype" as="xs:string" visibility="public">
    <!--~ 
      Turns an href extension (e.g. `xml')` into the correct MIME type (`'text/xml'`).
      
      When it cannot find an appropriate MIME type it returns the empty string.
    -->
    <xsl:param name="ext" as="xs:string">
      <!--~ The extension to convert. -->
    </xsl:param>

    <xsl:sequence select="string((($local:mime-types-table/xtl-mimetypes:mimetype[@extension eq $ext])[1])/@type)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:mimetype2ext" as="xs:string" visibility="public">
    <!--~ 
      Turns a MIME type (e.g. `'text/xml'`) into a corresponding href extension (`'xml'`).
      
      When it doesn't recognize the MIME type it returns the empty string.
    -->
    <xsl:param name="mimetype" as="xs:string">
      <!--~ The MIME type to convert. -->
    </xsl:param>

    <xsl:sequence select="string((($local:mime-types-table/xtl-mimetypes:mimetype[@type eq $mimetype])[1])/@extension)"/>
  </xsl:function>

</xsl:stylesheet>
