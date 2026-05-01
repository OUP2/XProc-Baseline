<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:bc="http://ns.oup.com/xproc/baseline_canon"
  exclude-result-prefixes="xs math"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="config-uri" select="base-uri(/)"/>
  
  <xsl:template match="b:baseline[@manifest-href and b:manifest]">
    <xsl:variable name="manifest" select="resolve-uri(@manifest-href, $config-uri)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:result-document href="{$manifest}" indent="true">
        <xsl:apply-templates select="b:manifest"/>
      </xsl:result-document>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>