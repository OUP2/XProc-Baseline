<?xml version="1.0" encoding="UTF-8"?>
<p:library
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:b="http://ns.oup.com/xproc/baseline"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-inline-prefixes="#all"
  version="3.0">
  
  <p:option name="hash-algorithm" select="'crc'" static="true"/>
  
  <p:declare-step name="create-manifest" type="b:create-manifest">
    <p:option name="path" required="true"/>
    <p:output port="result" primary="true" serialization="map{ 'indent': true()}"/>
    
    <p:file-info href="{resolve-uri($path)}"/>
    <b:manifest-process/>
<!--    <p:delete match="//@* except (@xml:base|@name|@content-type)"/>-->
    
  </p:declare-step>
  
  <p:declare-step type="b:manifest-process">
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true"/>
    
    <p:for-each>
      <p:choose>
        <p:when test="/c:directory">
          <!--        <p:message select="Found Directory {/*/@name}"/>-->
          <b:manifest-list-dir/>
        </p:when>
        <p:when test="/c:file[@content-type='application/zip']">
          <b:manifest-list-zip/>
        </p:when>
        <p:when test="/c:file">
          <p:load href="{/*/@xml:base}"/>
          <b:manifest-process/>
        </p:when>
        <p:when test="p:document-property(., 'content-type') = 'application/zip'">
          <b:manifest-zip-entries/>
        </p:when>
        <p:when test="p:document-property(., 'content-type') => matches('^[^/]+/([\+]+\+)?xml$')">
          <b:manifest-xml-file/>
        </p:when>
        <p:otherwise>
          <b:manifest-binary-file/>
        </p:otherwise>
      </p:choose>
    </p:for-each>
  </p:declare-step>
  
  <p:declare-step type="b:manifest-binary-file">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:cast-content-type content-type="application/xml"/>
    <p:hash algorithm="{$hash-algorithm}" match="/" value="{/c:data}"/>
    
  </p:declare-step>
  
  <p:declare-step type="b:manifest-xml-file">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:hash algorithm="{$hash-algorithm}" match="/" value="{serialize(/)}"/>
  
  </p:declare-step>
  
  <p:declare-step type="b:manifest-zip-entries">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:identity name="zip-file"/>
    
    <p:archive-manifest/>
    <p:viewport match="/c:archive/*">
      <p:identity name="zip-entry"/>
      
      <p:unarchive include-filter="{/*/@name}">
        <p:with-input port="source" pipe="@zip-file"/>
      </p:unarchive>
      <b:manifest-process/>
      <p:identity name="zip-entry-processed"/>
      
      <p:insert position="first-child">
        <p:with-input port="source" pipe="@zip-entry"/>
        <p:with-input port="insertion" pipe="@zip-entry-processed"/>
      </p:insert>
    </p:viewport>
    <p:unwrap/>
    
  </p:declare-step>
  
  <p:declare-step type="b:manifest-list-zip">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:identity name="list-zip"/>
    
    <p:load href="{/*/@xml:base}" content-type="{/*/@content-type}"/>
    <b:manifest-process/>
    <p:identity name="zip-contents"/>
    
    <p:insert position="first-child">
      <p:with-input port="source" pipe="@list-zip"/>
      <p:with-input port="insertion" pipe="@zip-contents"/>
    </p:insert>
  
  </p:declare-step>
  
  <p:declare-step type="b:manifest-list-dir">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
<!--    <p:message select="Creating manifest entry for folder {/*/@xml:base}"/>-->
    
    <p:directory-list path="{resolve-uri(/*/@xml:base)}" detailed="true"/>
    <p:make-absolute-uris match="@xml:base"/>
    <p:viewport match="/c:directory/*">
      <b:manifest-process/>
    </p:viewport>
    
  </p:declare-step>
  
</p:library>