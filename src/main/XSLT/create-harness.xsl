<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xsl xs math map"
  version="3.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="copy" on-no-match="shallow-copy"/>
  <xsl:mode name="b:canon" on-no-match="shallow-skip"/>
  <xsl:mode name="namespaces" on-no-match="shallow-skip"/>
  
  <xsl:param name="baseline-xproc-uri" as="xs:anyURI"/>
  <xsl:variable name="harness-uri" select="resolve-uri((/b:regression-tests/b:config/b:test-harness/@href)[1], document-uri(/))"/>
  <xsl:variable name="config-root" select="/"/>
      
  <!-- We need to ensure that namespace declarations are added for any pipelines referred to by their QName -->
  <xsl:variable name="namespaces" as="map(xs:anyURI, xs:string*)?">
    <xsl:variable name="ns-maps" as="map(xs:anyURI, xs:string*)*">
      <xsl:map-entry key="xs:anyURI('http://ns.oup.com/xproc/baseline')" select="'b'"/>
      <xsl:apply-templates select="$config-root" mode="namespaces"/>
    </xsl:variable>
    <xsl:sequence select="map:merge($ns-maps, map {'duplicates': 'combine'})"/>
  </xsl:variable>
  
  <xsl:template match=".[. instance of xs:anyURI]" mode="namespaces">
    <xsl:namespace name="{$namespaces?(.)[1]}" select="."/>
  </xsl:template>
  
  <xsl:template match="*[@pipeline]" mode="namespaces" as="map(xs:anyURI, xs:string*)*">
    <xsl:variable name="QName" select="resolve-QName(@pipeline, .)"/>
    <xsl:sequence select="map{namespace-uri-from-QName($QName): prefix-from-QName($QName)}"/>
  </xsl:template>
  
  <xsl:template match="b:regression-tests">
    <p:library
      exclude-inline-prefixes="#all"
      version="3.0">
      <xsl:apply-templates mode="namespaces" select="map:keys($namespaces)"/>
      
      <xsl:apply-templates select="b:imports"/>
      <xsl:apply-templates select="doc($baseline-xproc-uri)/*/(node() except p:declare-step)" mode="copy"/>
      
      <p:declare-step type="b:run-tests"/>
      
      <xsl:apply-templates select="doc($baseline-xproc-uri)/*/p:declare-step" mode="copy"/>
      
    </p:library>
  </xsl:template>
  
  <xsl:template match="b:import">
    <p:import>
      <xsl:apply-templates select="@*" mode="copy"/>
    </p:import>
  </xsl:template>
  
  <xsl:template match="b:import[resolve-uri(@href) eq resolve-uri($baseline-xproc-uri)]" priority="2"/>
  
  <xsl:template match="b:import/@href" mode="copy">
    <xsl:attribute name="href" select="b:relativeUri(.)"/>
  </xsl:template>
  
  <xsl:template match="p:declare-step[@type='b:canon']" mode="copy">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*" mode="#current"/>
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="test-id" required="false" as="xs:string"/>
      <p:choose>
        <xsl:apply-templates select="$config-root/b:regression-tests/b:test[b:config/b:canonicalization]" mode="b:canon"/>
        <p:otherwise>
          <xsl:apply-templates select="$config-root/b:regression-tests/b:config/b:canonicalization" mode="b:canon"/>
          <xsl:on-empty>
            <p:identity/>
          </xsl:on-empty>
        </p:otherwise>
      </p:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="b:test[@xml:id]" mode="b:canon">
    <p:when test="$test-id eq '{@xml:id}'">
      <xsl:apply-templates mode="#current"/>
    </p:when>
  </xsl:template>
  
  <xsl:template match="b:canonicalization[@pipeline]" mode="b:canon">
    <xsl:variable name="QName" select="resolve-QName(@pipeline, .)"/>
    <xsl:element name="{$QName}" namespace="{namespace-uri-from-QName($QName)}"/>
  </xsl:template>
  
  <xsl:template match="node()" mode="copy">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
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