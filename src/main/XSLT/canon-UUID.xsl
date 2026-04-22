<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:param name="replacement_UUID" as="xs:string" select="'00000000-0000-0000-0000-000000000000'"/>
  
  <xsl:variable name="id_rx" select="'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="text()[matches(., $id_rx)]" name="replace_text">
    <xsl:param name="value" select="."/>
    <xsl:analyze-string select="$value" regex="{$id_rx}">
      <xsl:matching-substring>
        <xsl:value-of select="$replacement_UUID"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="@*[matches(., $id_rx)]">
    <xsl:variable name="attribute_value">
      <xsl:call-template name="replace_text">
        <xsl:with-param name="value" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="{name(.)}" select="$attribute_value"/>
  </xsl:template>
  
</xsl:stylesheet>