<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output method="xml"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="c:directory">
    <b:folder>
      <xsl:apply-templates select="@*, node()"/>
    </b:folder>
  </xsl:template>
  
  <xsl:template match="c:file[@content-type eq 'application/zip']">
    <b:archive>
      <xsl:apply-templates select="@* except @size, node()"/>
    </b:archive>
  </xsl:template>
  
  <xsl:template match="c:file[not(@content-type eq 'application/zip')]">
    <b:file>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="hash" select="."/>
    </b:file>
  </xsl:template>
  
  <xsl:template match="c:entry" name="entry" priority="2">
    <xsl:param name="path" select="tokenize(@name, '/')"/>
    <xsl:choose>
      <xsl:when test="count($path) gt 1">
        <b:folder name="{$path[1]}">
          <xsl:call-template name="entry">
            <xsl:with-param name="path" select="tail($path)"/>
          </xsl:call-template>
        </b:folder>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match>
          <xsl:with-param name="name" select="$path"/>
        </xsl:next-match>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="c:entry[@content-type eq 'application/zip']">
    <xsl:param name="name" select="@name"/>
    <b:archive name="{$name}">
      <xsl:apply-templates select="@* except (@size|@name)"/>
      <xsl:apply-templates/>
    </b:archive>
  </xsl:template>
  
  <xsl:template match="c:entry">
    <xsl:param name="name" select="@name"/>
    <b:file name="{$name}">
      <xsl:apply-templates select="@* except @name"/>
      <xsl:attribute name="hash" select="."/>
    </b:file>
  </xsl:template>
  
  <xsl:template match="@*"/>
  
  <xsl:template match="@name|@content-type|c:file/@size|c:entry/@size">
    <xsl:copy copy-namespaces="no"/>
  </xsl:template>
  
  <xsl:template match="c:entry/@method">
    <xsl:attribute name="compression-method" select="."/>
  </xsl:template>
  
</xsl:stylesheet>