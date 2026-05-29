<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:b="http://ns.oup.com/xproc/baseline"
           xmlns:bc="http://ns.oup.com/xproc/baseline_canon"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:p="http://www.w3.org/ns/xproc"
           exclude-inline-prefixes="#all"
           version="3.0">
   <p:import href="../../main/xproc/Baseline-canon.xpl"/>
   <p:option name="b:hash-algorithm" select="'md'" static="true"/>
   <p:declare-step type="b:run-tests">
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="test-id" required="false" as="xs:string"/>
      <p:choose>
         <p:when test="$test-id eq 'xzr_w35_z3c'">
            <bc:timestamps/>
         </p:when>
         <p:otherwise>
            <bc:UUIDs/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>
   <p:declare-step type="b:create-harness">
      <p:input port="source"
               primary="true"/>
      <p:variable name="harness_uri"
                  select="resolve-uri((/b:regression-tests/b:config/b:test-harness/@href)[1], base-uri())"/>
      <p:xslt parameters="map{'baseline-xproc-uri': static-base-uri()}">
         <p:with-input port="stylesheet" href="../XSLT/create-harness.xsl"/>
      </p:xslt>
      <p:store href="{$harness_uri}"/>
   </p:declare-step>
   <p:declare-step type="b:update-manifest">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:variable name="test_uri" select="base-uri()"/>
      <!-- remove existing embedded manifests -->
      <p:delete match="b:manifest"/>
      <!-- Create new manifests -->
      <p:viewport match="b:test[b:baseline]">
         <p:variable name="test-id" select="/*/@xml:id"/>
         <p:viewport match="b:baseline">
            <p:identity name="element"/>
            <b:create-manifest path="{resolve-uri(/*/@uri, $test_uri)}" test-id="{$test-id}"/>
            <p:identity name="manifest"/>
            <p:insert position="first-child">
               <p:with-input port="source" pipe="@element"/>
               <p:with-input port="insertion" pipe="@manifest"/>
            </p:insert>
         </p:viewport>
      </p:viewport>
      <!-- Extract non-embedded manifests -->
      <p:xslt name="extract_manifests">
         <p:with-input port="stylesheet" href="../XSLT/update-manifest.xsl"/>
      </p:xslt>
      <!-- Update test definitions -->
      <p:if test="exists($test_uri)">
         <p:store href="{$test_uri}"/>
      </p:if>
      <p:for-each>
         <p:with-input pipe="secondary@extract_manifests"/>
         <p:store href="{base-uri(.)}"/>
      </p:for-each>
   </p:declare-step>
   <p:declare-step type="b:create-manifest">
      <p:option name="path" required="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:output port="result" primary="true" serialization="map{ 'indent': true()}"/>
      <p:file-info href="{resolve-uri($path)}"/>
      <b:manifest-process test-id="{$test-id}"/>
      <p:xslt>
         <p:with-input port="stylesheet" href="../XSLT/manifest.xsl"/>
      </p:xslt>
      <p:wrap match="/" wrapper="b:manifest"/>
   </p:declare-step>
   <p:declare-step type="b:manifest-process">
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:for-each>
         <p:choose>
            <p:when test="/c:directory">
               <b:manifest-list-dir test-id="{$test-id}"/>
            </p:when>
            <p:when test="/c:file[@content-type='application/zip']">
               <b:manifest-list-zip test-id="{$test-id}"/>
            </p:when>
            <p:when test="/c:file">
               <b:manifest-list-file test-id="{$test-id}"/>
            </p:when>
            <p:when test="p:document-property(., 'content-type') = 'application/zip'">
               <b:manifest-zip-entries test-id="{$test-id}"/>
            </p:when>
            <p:when test="p:document-property(., 'content-type') =&gt; matches('^[^/]+/([\+]+\+)?xml$')">
               <b:manifest-xml-file test-id="{$test-id}"/>
            </p:when>
            <p:when test="p:document-property(., 'content-type') =&gt; starts-with('text/')">
               <b:manifest-text-file test-id="{$test-id}"/>
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
      <p:hash algorithm="{$b:hash-algorithm}" match="/" value="{/c:data}"/>
   </p:declare-step>
   <p:declare-step type="b:manifest-text-file">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:wrap-sequence wrapper="text"/>
      <b:canon test-id="{$test-id}"/>
      <p:hash algorithm="{$b:hash-algorithm}" match="/" value="{/text}"/>
   </p:declare-step>
   <p:declare-step type="b:manifest-xml-file">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <b:canon test-id="{$test-id}"/>
      <p:hash algorithm="{$b:hash-algorithm}" match="/" value="{serialize(/)}"/>
   </p:declare-step>
   <p:declare-step type="b:manifest-zip-entries">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:identity name="zip-file"/>
      <p:archive-manifest/>
      <p:viewport match="/c:archive/*">
         <p:identity name="zip-entry"/>
         <p:unarchive include-filter="{/*/@name}">
            <p:with-input port="source" pipe="@zip-file"/>
         </p:unarchive>
         <b:manifest-process test-id="{$test-id}"/>
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
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:identity name="list-zip"/>
      <p:load href="{/*/@xml:base}" content-type="{/*/@content-type}"/>
      <b:manifest-process test-id="{$test-id}"/>
      <p:identity name="zip-contents"/>
      <p:insert position="first-child">
         <p:with-input port="source" pipe="@list-zip"/>
         <p:with-input port="insertion" pipe="@zip-contents"/>
      </p:insert>
   </p:declare-step>
   <p:declare-step type="b:manifest-list-dir">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:directory-list path="{/*/@xml:base}" detailed="true"/>
      <p:make-absolute-uris match="@xml:base" base-uri="{/*/@xml:base}"/>
      <p:viewport match="/c:directory/*">
         <b:manifest-process test-id="{$test-id}"/>
      </p:viewport>
   </p:declare-step>
   <p:declare-step type="b:manifest-list-file">
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="test-id" as="xs:string" select="''"/>
      <p:identity name="list-file"/>
      <p:load href="{/*/@xml:base}"/>
      <b:manifest-process test-id="{$test-id}"/>
      <p:identity name="file-processed"/>
      <p:insert position="first-child">
         <p:with-input port="source" pipe="@list-file"/>
         <p:with-input port="insertion" pipe="@file-processed"/>
      </p:insert>
   </p:declare-step>
   <p:declare-step type="b:canon">
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="test-id" required="false" as="xs:string"/>
      <p:choose>
         <p:when test="$test-id eq 'xzr_w35_z3c'">
            <bc:timestamps/>
         </p:when>
         <p:otherwise>
            <bc:UUIDs/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>
</p:library>
