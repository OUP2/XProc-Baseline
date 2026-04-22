<?xml version="1.0" encoding="UTF-8"?>
<p:library
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:bc="http://ns.oup.com/xproc/baseline_canon"
  version="3.0">
  
  <p:declare-step type="bc:timestamps">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:xslt>
      <p:with-input port="stylesheet" href="../XSLT/canon-dates.xsl"/>
    </p:xslt>
    
  </p:declare-step>
  
  <p:declare-step type="bc:UUIDs">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:xslt>
      <p:with-input port="stylesheet" href="../XSLT/canon-UUID.xsl"/>
    </p:xslt>
  </p:declare-step>
  
</p:library>