<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*
    Master file for use in oXygen projects.
    
    Chains all XSLT libraries in xtpxlib-common the right order so you won't get validation
    errors due to missing references.
    
    Ad this file as a master file to your oXygen project.
	-->
  <!-- ================================================================== -->
 
  <xsl:include href="../xslmod/general.mod.xsl"/>
  <xsl:include href="../xslmod/dref.mod.xsl"/>
  <xsl:include href="../xslmod/message.mod.xsl"/>
  <xsl:include href="../xslmod/mimetypes.mod.xsl"/>
  <xsl:include href="../xslmod/uuid.mod.xsl"/>    
  <xsl:include href="../xslmod/parameters.mod.xsl"/>
  <xsl:include href="../xslmod/compare.mod.xsl"/>
  <xsl:include href="../xslmod/format-output.mod.xsl"/>
  <xsl:include href="../xslmod/date-time.mod.xsl"/>
  
</xsl:stylesheet>


