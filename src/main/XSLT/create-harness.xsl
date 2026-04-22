<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:bt="http://ns.oup.com/xproc/baseline_test-harness"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="copy" on-no-match="shallow-copy"/>
  
  <xsl:param name="baseline-xproc-href" as="xs:anyURI"/>
  <xsl:variable name="harness-uri" select="resolve-uri((/b:regression-tests/b:config/b:test-harness/@href)[1], document-uri(/))"/>
  
  <xsl:template match="b:regression-tests">
    <p:library
      exclude-inline-prefixes="#all"
      version="3.0">
      <xsl:apply-templates select="b:imports"/>
      
    </p:library>
  </xsl:template>
  
  <xsl:template match="b:import">
    <p:import>
      <xsl:apply-templates select="@*" mode="copy"/>
    </p:import>
  </xsl:template>
  
  <xsl:template match="b:import/@href" mode="copy">
    <xsl:attribute name="href" select="b:relativeUri(.)"/>
  </xsl:template>
  
  
  <xsl:function name="b:relativeUri" as="xs:string" visibility="public">
    <xsl:param name="target"/>
    <xsl:sequence select="b:relativeUri($target, $harness-uri)"/>
  </xsl:function>
  
  <xsl:function name="b:relativeUri" as="xs:string" visibility="public">
    <xsl:param name="target"/>
    <xsl:param name="base"/>
    
    <!-- Use resolve-uri to normalize both URIs -->
    <xsl:variable name="baseNorm" select="resolve-uri($base, static-base-uri())"/>
    <xsl:variable name="targetNorm" select="resolve-uri($target, static-base-uri())"/>
    
    <!-- Extract path components using regex -->
    <xsl:variable name="basePath" select="replace($baseNorm, '^([^?#]*/).*$', '$1')"/>
    <xsl:variable name="targetPath" select="substring-before(concat($targetNorm, '?'), '?')"/>
    
    <!-- Check if same scheme/authority -->
    <xsl:choose>
      <xsl:when test="substring-before($baseNorm, '/') ne substring-before($targetNorm, '/')">
        <xsl:sequence select="$targetNorm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="b:makeRelative($basePath, $targetPath)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="b:makeRelative" as="xs:string">
    <xsl:param name="basePath" as="xs:string"/>
    <xsl:param name="targetPath" as="xs:string"/>
    
    <xsl:variable name="baseSegments" as="xs:string*" select="tokenize($basePath, '/')[position() ne last() or . ne '']"/>
    <xsl:variable name="targetSegments" as="xs:string*" select="tokenize($targetPath, '/')"/>
    
    <xsl:variable name="commonLen" as="xs:integer" select="sum(
      for $i in 1 to min((count($baseSegments), count($targetSegments)))
      return if ($baseSegments[$i] = $targetSegments[$i]) then 1 else 0
      )"/>
    
    <xsl:variable name="upSteps" as="xs:integer" select="count($baseSegments) - $commonLen"/>
    <xsl:variable name="upPath" as="xs:string" select="string-join((for $i in 1 to $upSteps return '..'), '/')"/>
    <xsl:variable name="downPath" as="xs:string" select="string-join($targetSegments[position() > $commonLen], '/')"/>
    
    <!--<xsl:text expand-text="true">
      base segments:   {string-join($baseSegments, ' / ')}
      target segments: {string-join($targetSegments, ' / ')}
      commonLen:       {$commonLen}
    </xsl:text>-->
    
    <xsl:sequence select="
      if ($upSteps = 0 and $downPath = '') then './'
      else if ($upSteps = 0) then concat('./', $downPath)
      else if ($downPath = '') then $upPath
      else concat($upPath, '/', $downPath)
      "/>
  </xsl:function>
  
</xsl:stylesheet>