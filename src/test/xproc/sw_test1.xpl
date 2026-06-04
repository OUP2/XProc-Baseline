<?xml version="1.0" encoding="UTF-8"?>
<p:library
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:sw="http://h2o.consulting/ns/star-wars"
    version="3.0">
  
  <p:declare-step type="sw:test1">
    <p:input port="source" primary="true">
      <p:document href="../data/Input/manifest-creation/StarWars/StarWars.zip"/>
    </p:input>
    <p:output port="result" primary="true" sequence="true"/>
    
    <p:option name="outputDir" select="resolve-uri('../data/Output/sw_test1/')"/>
    
    <p:identity name="zip-file"/>
    
    <p:archive-manifest/>
    <p:identity name="outer-manifest"/>
    
    <p:unarchive include-filter="films/films.zip">
      <p:with-input pipe="@zip-file"/>
    </p:unarchive>
    <p:identity name="zip-films"/>
    
    <p:unarchive include-filter=".xml">
      <p:with-input pipe="@zip-films"/>
    </p:unarchive>
    <p:identity name="film-xmls"/>
    
    <p:for-each>
      <p:variable name="filename" select="replace(/*/*:title, '[^a-zA-Z0-9]', '_')"/>
      <p:archive>
        <p:with-input port="manifest">
          <p:inline>
            <c:archive>
              <c:entry name="{$filename}.xml" href="{base-uri()}"/>
            </c:archive>
          </p:inline>
        </p:with-input>
      </p:archive>
      <p:store href="{resolve-uri($filename||'.zip', $outputDir)}"/>
    </p:for-each>
    
  </p:declare-step>

</p:library>