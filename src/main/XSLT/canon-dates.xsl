<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:param name="replacement_date" as="xs:string" select="'2001-01-01T01:01:01.000001Z'"/>
  
  <xsl:variable name="ts_rx" select="'(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))'"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="text()[matches(., $ts_rx)]" name="replace_text">
    <xsl:param name="value" select="."/>
    <xsl:analyze-string select="$value" regex="{$ts_rx}">
      <xsl:matching-substring>
        <xsl:value-of select="$replacement_date"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="@*[matches(., $ts_rx)]">
    <xsl:variable name="attribute_value">
      <xsl:call-template name="replace_text">
        <xsl:with-param name="value" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="{name(.)}" select="$attribute_value"/>
  </xsl:template>
  
</xsl:stylesheet>