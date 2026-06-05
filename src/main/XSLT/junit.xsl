<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:bc="http://ns.oup.com/xproc/baseline_canon"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-skip" use-accumulators="#all"/>
  
  <xsl:accumulator name="failures" as="xs:integer" initial-value="0">
    <xsl:accumulator-rule match="b:test" select="if (b:success(.)) then $value else $value + 1"/>
  </xsl:accumulator>
  
  <xsl:template match="b:regression-tests">
    <testsuites>
      <testsuite name="XProc Baseline" failures="{accumulator-after('failures')}">
        <xsl:apply-templates/>
      </testsuite>
    </testsuites>
  </xsl:template>
  
  <xsl:template match="b:test">
    <xsl:variable name="success" select="b:success(.)"/>
    <testcase>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="not($success)">
        <failure type="AssertionError" message="Manifest comparison failed"/>
      </xsl:if>
    </testcase>
  </xsl:template>
  
  <xsl:template match="b:test/@pipeline">
    <xsl:attribute name="classname" select="."/>
  </xsl:template>
  <xsl:template match="b:test/@xml:id">
    <xsl:attribute name="name" select="."/>
  </xsl:template>
  
  <xsl:function name="b:success" as="xs:boolean">
    <xsl:param name="test" as="element(b:test)"/>
    <xsl:sequence select="deep-equal($test/b:output/b:manifest, (doc($test/b:baseline/@baseline-manifest)/*, $test/b:baseline/b:manifest)[1])"/>
  </xsl:function>
  
</xsl:stylesheet>