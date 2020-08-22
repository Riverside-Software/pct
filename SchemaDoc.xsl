<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xsltc="http://xml.apache.org/xalan/xsltc"
   xmlns:redirect="http://xml.apache.org/xalan/redirect"
   extension-element-prefixes="xsltc redirect">


<!--
    Copyright  2002-2004 The Apache Software Foundation
   
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
   
         http://www.apache.org/licenses/LICENSE-2.0
   
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
   
-->

  <xsl:key name="tables" match="table" use="substring(@name, 1, 1)" />

  <xsl:output method="html" indent="yes" encoding="utf-8"/>
  <xsl:decimal-format decimal-separator="." grouping-separator="," />
  
  <xsl:param name="outputdir" select="'.'" />
  <xsl:param name="dbname" select="default" />

  <xsl:template match="database">
    <!-- create the index.html -->
    <redirect:write file="{$outputdir}/{$dbname}.html">
      <xsl:call-template name="index.html"/>
    </redirect:write>
    <!-- create the stylesheet.css -->
    <redirect:write file="{$outputdir}/{$dbname}-stylesheet.css">
      <xsl:call-template name="stylesheet.css"/>
    </redirect:write>
    <!-- create the all-classes.html at the root -->
    <redirect:write file="{$outputdir}/{$dbname}-tables.html">
      <xsl:apply-templates select="." mode="all.tables"/>
    </redirect:write>
    <redirect:write file="{$outputdir}/{$dbname}-database.html">
      <xsl:apply-templates select="." mode="overview"/>
    </redirect:write>
    <redirect:write file="{$outputdir}/{$dbname}-areas.html">
      <xsl:apply-templates select="." mode="all.areas"/>
    </redirect:write>
    <redirect:write file="{$outputdir}/{$dbname}-sequences.html">
      <xsl:apply-templates select="." mode="all.sequences"/>
    </redirect:write>
    <!-- process all tables -->
    <xsl:apply-templates select="area"/>
    <!-- process all tables -->
    <xsl:apply-templates select="table"/>
  </xsl:template>

  <!-- Main file -->
  <xsl:template name="index.html">
    <html>
      <head>
        <title>Database schema doc</title>
      </head>
      <frameset cols="15%,80%">
        <frame src="{$dbname}-tables.html" name="fileListFrame"/>
        <frame src="{$dbname}-database.html" name="fileFrame"/>
      </frameset>
      <noframes>
        <h2>Frame Alert</h2>
        <p> This document is designed to be viewed using the frames feature. If 
          you see this message, you are using a non-frame-capable web client. 
          </p>
      </noframes>
    </html>
  </xsl:template>
  
  <!-- Stylesheet -->
  <xsl:template name="stylesheet.css"> .bannercell { border: 0px; padding: 0px; 
    } body { margin-left: 10; margin-right: 10; font:normal 80% 
    arial,helvetica,sanserif; background-color:#FFFFFF; color:#000000; } 
    .oddrow td { background: #efefef; } .evenrow td { background: #fff; } th, 
    td { text-align: left; vertical-align: top; } th { font-weight:bold; 
    background: #ccc; color: black; } table, th, td { font-size:100%; border: 
    none } table.log tr td, tr th { } h2 { font-weight:bold; font-size:140%; 
    margin-bottom: 5; } h3 { font-size:100%; font-weight:bold; background: 
    #525D76; color: white; text-decoration: none; padding: 5px; margin-right: 
    2px; margin-left: 2px; margin-bottom: 0; } </xsl:template>

  <!-- Database overview -->
  <xsl:template match="database" mode="overview">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="{$dbname}-stylesheet.css"/>
      </head>
      <body>
        <h1>Database</h1>
        <h2>Creation date : <xsl:value-of select="@creation"/></h2>
        <h2>Blocksize : <xsl:value-of select="@blockSize"/> bytes</h2>
        <h2>Version : <xsl:value-of select="@version"/></h2>
        <h2>Codepage : <xsl:value-of select="@codepage"/></h2>
        <h2>Collation : <xsl:value-of select="@collation"/></h2>
      </body>
    </html>
  </xsl:template>

  <!-- Sequences overview -->
  <xsl:template match="database" mode="all.sequences">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="{$dbname}-stylesheet.css"/>
      </head>
      <body>
        <h1>Sequences</h1>
        <table width="100%">
          <tr>
            <th>Sequence name</th>
            <th>Initial</th>
            <th>Increment</th>
            <th>Minimum</th>
            <th>Maximum</th>
            <th>Cycle</th>
          </tr>
          <!-- For each file create its part -->
          <xsl:apply-templates select="sequence" mode="all.sequences"/>
        </table>
      </body>
    </html>
  </xsl:template>
  
  <!-- Areas (right frame) -->
  <xsl:template match="sequence" mode="all.sequences">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@init"/></td>
      <td><xsl:value-of select="@incr"/></td>
      <td><xsl:value-of select="@min"/></td>
      <td><xsl:value-of select="@max"/></td>
      <td><xsl:value-of select="@cycle"/></td>
    </tr>
  </xsl:template>

  <!-- Areas overview -->
  <xsl:template match="database" mode="all.areas">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="{$dbname}-stylesheet.css"/>
      </head>
      <body>
        <h1>Areas</h1>
        <table width="100%">
          <tr>
            <th>Area name</th>
            <th>Tables</th>
            <th>Indexes</th>
          </tr>
          <!-- For each file create its part -->
          <xsl:apply-templates select="area" mode="all.areas"/>
        </table>
      </body>
    </html>
  </xsl:template>
  
  <!-- Areas (right frame) -->
  <xsl:template match="area" mode="all.areas">
    <tr>
      <td nowrap="nowrap">
	    <xsl:value-of select="@num"/> - <xsl:value-of select="@name"/>
        <!-- <a target="fileFrame">
          <xsl:attribute name="href">
            <xsl:text>files/Area</xsl:text>
            <xsl:value-of select="@num"/>
            <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <xsl:value-of select="@num"/> - <xsl:value-of select="@name"/>
        </a> -->
      </td>
      <td>
        <xsl:apply-templates select="../table[@areaNum = current()/@num]" mode="all.areas" />
      </td>
      <td>
        <xsl:apply-templates select="../table/index[@areaNum = current()/@num]" mode="all.areas" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="table" mode="all.areas">
    <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$dbname" />
			<xsl:text>-</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <xsl:value-of select="@name"/>
    </a><br />
  </xsl:template>

  <xsl:template match="index" mode="all.areas">
    <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$dbname" />
			<xsl:text>-</xsl:text>
            <xsl:value-of select="../@name"/>
            <xsl:text>.html#</xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:attribute>
          <xsl:value-of select="@name"/>
    </a><br />
  </xsl:template>
  
  <!-- Table list : left frame -->
  <xsl:template match="database" mode="all.tables">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="{$dbname}-stylesheet.css"/>
      </head>
      <body>
        <h2><a target="fileFrame" href="{$dbname}-sequences.html">S</a> ::
        <a target="fileFrame" href="{$dbname}-database.html">DB</a> ::
        <a target="fileFrame" href="{$dbname}-areas.html">A</a></h2>
        <h1>Tables</h1>
          <xsl:for-each select="table[generate-id(.) = generate-id(key('tables', substring(@name, 1, 1))[1])]">
            <xsl:sort select="@name" />
            <xsl:variable name="firstletter" select="substring(@name, 1, 1)" />
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$firstletter" />
              </xsl:attribute>
              <xsl:value-of select="$firstletter" />
            </a>
          </xsl:for-each>
		  
		  <table width="100%">
          <xsl:for-each select="table[generate-id(.) = generate-id(key('tables', substring(@name, 1, 1))[1])]">
            <xsl:sort select="@name" />
            <xsl:variable name="firstletter" select="substring(@name, 1, 1)" />
              <tr><td><h3><a>
                <xsl:attribute name="name">
                  <xsl:value-of select="$firstletter" />
                </xsl:attribute>
                <xsl:value-of select="$firstletter" />
              </a></h3></td></tr>
            
            <xsl:for-each select="key('tables', $firstletter)">
              <tr><td><a target="fileFrame">
                <xsl:attribute name="href">
            <xsl:value-of select="$dbname" />
			<xsl:text>-</xsl:text>
                  <xsl:value-of select="@name"/>
                  <xsl:text>.html</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@name"/>
              </a></td></tr>
            </xsl:for-each>
          </xsl:for-each>
          </table>
          
        <!--<table width="100%">
          <xsl:apply-templates select="table" mode="all.tables"/>
        </table>-->
        
      </body>
    </html>
  </xsl:template>
  
  <!-- Table (left frame) -->
  <xsl:template match="table" mode="all.tables">
    <tr>
      <td nowrap="nowrap">
        <a target="fileFrame">
          <xsl:attribute name="href">
            <xsl:value-of select="$dbname" />
			<xsl:text>-</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <xsl:value-of select="@name"/>
        </a>
      </td>
    </tr>
  </xsl:template>
  
  <!-- One file for each table -->
  <xsl:template match="table">
    <!-- create the all-classes.html at the root -->
    <redirect:write file="{$outputdir}/{$dbname}-{@name}.html">
      <html>
        <head>
          <link rel="stylesheet" type="text/css" href="{$dbname}-stylesheet.css">
          </link>
        </head>
        <body>
          <h1>Table <xsl:value-of select="@name"/></h1>
          <h3>
            <xsl:value-of select="text()"/>
          </h3>
          <h2>Area <xsl:value-of select = "..//area[@num = current()/@areaNum]/@name" />  </h2>
          <h2>Field list</h2>
          <table>
            <tr>
              <th>Name</th>
              <th>Order</th>
              <th>Data type</th>
              <th>Mandatory</th>
              <th>Format</th>
              <th>Extent</th>
              <th>Initial value</th>
              <th>Label</th>
              <th>Description</th>
            </tr>
            <xsl:apply-templates select="field"/>
          </table>
          <h2>Index list</h2>
          <table>
            <tr>
              <th>Name</th>
              <th>Active</th>
              <th>Primary</th>
              <th>Unique</th>
              <th>Fields</th>
              <th>Description</th>
            </tr>
            <xsl:apply-templates select="index"/>
          </table>
          <h2>Trigger list</h2>
          <table>
            <tr>
              <th>Event</th>
              <th>Procedure</th>
              <th>Overridable ?</th>
            </tr>
            <xsl:apply-templates select="trigger"/>
          </table>
        </body>
      </html>
    </redirect:write>
  </xsl:template>
  
  <xsl:template match="field">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@order"/>
      </td>
      <td>
        <xsl:value-of select="@dataType"/>
      </td>
      <td>
        <xsl:value-of select="@mandatory"/>
      </td>
      <td>
        <xsl:value-of select="@format"/>
      </td>
      <td>
        <xsl:value-of select="@extent"/>
      </td>
      <td>
        <xsl:value-of select="@initialValue"/>
      </td>
      <td>
        <xsl:value-of select="@label"/>
      </td>
      <td>
         <xsl:value-of select="text()"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="index">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@active"/>
      </td>
      <td>
        <xsl:value-of select="@primary"/>
      </td>
      <td>
        <xsl:value-of select="@unique"/>
      </td>
      <td>
        <xsl:apply-templates select="indexField"></xsl:apply-templates>
      </td>
      <td>
         <xsl:value-of select="text()"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="indexField">
    <xsl:value-of select="@name"/>
    <br/>
  </xsl:template>
  
  <xsl:template match="trigger">
    <tr>
      <td>
        <xsl:value-of select="@event"/>
      </td>
      <td>
        <xsl:value-of select="@procedure"/>
      </td>
      <td>
        <xsl:value-of select="@overridable" />
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>