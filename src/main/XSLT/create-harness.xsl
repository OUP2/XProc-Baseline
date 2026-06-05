<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="copy" on-no-match="shallow-copy"/>
  <xsl:mode name="b:canon" on-no-match="shallow-skip"/>
  <xsl:mode name="namespaces" on-no-match="shallow-skip"/>
  <xsl:mode name="btop" on-no-match="shallow-copy"/>
  
  <xsl:param name="baseline-xproc-uri" as="xs:anyURI"/>
  <xsl:param name="config-uri" select="document-uri(/)"/>
  <xsl:param name="harness-uri" select="resolve-uri((/b:regression-tests/b:config/b:test-harness/@href)[1], $config-uri)"/>
  <xsl:variable name="config-root" select="/"/>
      
  <!-- We need to ensure that namespace declarations are added for any pipelines referred to by their QName -->
  <xsl:variable name="namespaces" as="map(xs:anyURI, xs:string*)?">
    <xsl:variable name="ns-maps" as="map(xs:anyURI, xs:string*)*">
      <xsl:map-entry key="xs:anyURI('http://ns.oup.com/xproc/baseline')" select="'b'"/>
      <xsl:map-entry key="xs:anyURI('http://www.w3.org/2001/XMLSchema')" select="'xs'"/>
      <xsl:map-entry key="xs:anyURI('http://www.w3.org/ns/xproc-step')" select="'c'"/>
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
      
      <!-- Add b:report at the top so it's the default step -->
      <xsl:apply-templates select="doc($baseline-xproc-uri)/*/p:declare-step[@type eq 'b:report']" mode="copy"/>
      
      <xsl:apply-templates select="doc($baseline-xproc-uri)/*/p:declare-step[@type ne 'b:report']" mode="copy"/>
      
    </p:library>
  </xsl:template>
  
  <xsl:template match="b:test[@xml:id]">
    <p:when test="$test-id = '{@xml:id}'">
      <xsl:variable name="QName" select="resolve-QName(@pipeline, .)" as="xs:QName"/>
      <p:output pipe="result@test-output"/>
      <!-- Always clear the default input ports -->
      <p:identity>
        <p:with-input>
          <p:empty/>
        </p:with-input>
      </p:identity>
      <xsl:element name="{xs:string($QName)}" namespace="{namespace-uri-from-QName($QName)}">
        <xsl:apply-templates select="b:input" mode="btop"/>
        <xsl:apply-templates select="b:options"/>
      </xsl:element>
      <p:identity name="test-output">
        <p:with-input pipe="result@original"/>
      </p:identity> 
    </p:when>
  </xsl:template>
  
  <xsl:template match="b:options">
    <xsl:apply-templates select="node()" mode="btop"/>
  </xsl:template>
  
  <xsl:template match="b:import">
    <p:import>
      <xsl:apply-templates select="@*" mode="copy"/>
    </p:import>
  </xsl:template>
  
  <xsl:template match="b:import[b:relativeUri(@href) eq b:relativeUri($baseline-xproc-uri)]" priority="2"/>
  
  <xsl:template match="b:import/@href" mode="copy">
    <xsl:attribute name="href" select="b:changeRelativeBase(., $config-uri, $harness-uri)"/>
  </xsl:template>
  
  <xsl:template match="p:declare-step[@type='b:run-test']" mode="copy">
    <p:declare-step type="b:run-test">
      <p:input port="source" primary="true" sequence="true">
        <p:empty/>
      </p:input>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="test-id" required="true"/>
      <p:identity name="original"/>
      <p:choose>
        <xsl:apply-templates select="$config-root//b:test"/>
      </p:choose>
    </p:declare-step>
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
  
  <xsl:template match="p:xslt/p:with-input/@href" mode="copy">
    <xsl:attribute name="href" select="b:changeRelativeBase(., $baseline-xproc-uri, $harness-uri)"/>
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
  
  <xsl:template match="b:input" mode="btop">
    <p:with-input>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </p:with-input>
  </xsl:template>
  
  <xsl:template match="b:option" mode="btop">
    <p:with-option>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </p:with-option>
  </xsl:template>
  
  <xsl:template match="b:*" mode="btop">
    <xsl:element name="p:{local-name(.)}">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*|*|node()" mode="copy btop">
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
    <xsl:variable name="basePath" select="replace($baseNorm, '^(file:*)?(//)?([^?#]*/).*$', '$3')"/>
    <xsl:variable name="targetPath" select="replace($targetNorm,'^(file:*)?(//)?(.+)$', '$3')"/>
    
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
  
  <xsl:function name="b:changeRelativeBase" as="xs:string" visibility="public">
    <xsl:param name="relativeURI" as="xs:string"/>
    <xsl:param name="oldBase" as="xs:string"/>
    <xsl:param name="newBase" as="xs:string"/>
<!--    <xsl:sequence select="$newBase"/>-->
    <xsl:sequence select="resolve-uri($relativeURI, $oldBase) => b:relativeUri($newBase)"/>
  </xsl:function>
  
</xsl:stylesheet>