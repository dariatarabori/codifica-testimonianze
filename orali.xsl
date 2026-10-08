<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<xsl:template match="/"> <!-- Espressione che fa match con tutto il documento -->
    <html>
        <head>
            <title/>
            <link rel="stylesheet" type="text/css" href="style.css"/> 
                      
        </head>
        <body>
            <header>
                <div class="intervista-container">
                
                    <!--lista dei parlanti-->
                    <div class="lista_parlanti">
                        <p>
                                <b>Interlocutori presenti nella testimonianza: </b> 
                            <xsl:value-of select="//tei:profileDesc//tei:particDesc//tei:listPerson//tei:persName" separator=" - "/>
                            </p>
                    </div>

                    <!--creo il player per ascoltare la testimonianza-->
                    <div id="traccia_audio" style="text-align:center; margin-top:3%;">
                        <audio controls="controls"> <!--class="audio_player" -->
                            <xsl:variable name="nome" select="//tei:person[@role='testimone']/tei:persName/tei:forename"/>
                            <xsl:variable name="cognome" select="//tei:person[@role='testimone']/tei:persName/tei:surname"/>
                        
                        
                            <!-- <xsl:value-of select="concat($nome, '_', $cognome)"/>  -->

                            <source src="{concat('https://48001.omega.ilc.cnr.it/exist/rest/apps/voci_inferno/resources/audio/',$nome, '_', $cognome, '.mp3')}"/>
                        </audio>
                    </div>

                    <div class="trascrizione-legenda-container">
                        
                        <!--trascrizione orale-->
                        <div class="trascrizione">
                            
                                <xsl:for-each select="//tei:body//tei:u"> 
                                    <xsl:variable name="who" select="substring-after(@who, '#')"/>      
                                    <div>
                                        <div id="u">
                                            
                                            <p>
                                                <b>
                                                    <xsl:value-of select="$who"/>
                                                </b>: 
                                                <xsl:for-each select="node()">
                                                    <xsl:apply-templates/>
                                                </xsl:for-each>
                                            </p>
                                            
                                        </div>
                                    </div>                          
                                </xsl:for-each>
                        </div>
                        
                        
                        
                        <!--legenda orale-->
                        <div class="divLegenda">
                            <div class="legenda">
                                <h3>Fenomeni marcati</h3>
                                <li id="gap" onclick="cambiaColoreGap()">Buco nella registrazione: <b>GAP XXX</b>
                                    </li>
                                <li id="unclear" onclick="cambiaColoreUnclear()">Parola non chiara: <b>UNCLEAR</b>
                                    </li>
                                <li id="pause" onclick="cambiaColorePause()">Pausa: <b>PAUSE (...)</b>
                                    </li>
                                <li id="vocal" onclick="cambiaColoreVocal()">Esclamazione: <b>VOCAL</b>
                                    </li>
                                <li id="incident" onclick="cambiaColoreIncident()">Rumore accidentale: <b>INCIDENT</b>
                                    </li>
                                <li id="kinesic" onclick="cambiaColoreKinesic()">Movimento: <b>KINESIC</b>
                                    </li>
                                <li id="del" onclick="cambiaColoreDel()">Frase o parola riformulata/ripetuta: <b>DEL</b>
                                    </li> <!--aggiungere tipologie di del-->
                                <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b>
                                    </li>
                                <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b>
                                    </li>
                                <li id="orig" onclick="cambiaColoreOrig()">Forma dialettale: <b>ORIG</b>
                                    </li>
                                <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b>
                                    </li>
                                <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b>
                                    </li>
                                <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b>
                                    </li>
                                <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b>
                                    </li>
                                <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b>
                                    </li>
                                <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b>
                                    </li>
                                <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b>
                                    </li>
                                <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b>
                                    </li>
                            </div>
                            
                            
                            
                            <div id="buttonLegenda">
                                <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                            </div>
                        </div>
                    </div>

                </div>
            </header>
        </body> 
    </html>
</xsl:template>                        

<!--gap non è più un tag ma diventa una classe del tag span, poichè nel namespace html <gap> non esiste e dunque verrebbe trattato come plain text-->
<xsl:template match="tei:gap">
    <span class="gap">XXX</span>    
</xsl:template>

<xsl:template match="tei:pause">
    <span class="pause">(...)</span>
</xsl:template>

<xsl:template match="tei:vocal">
    <span class="vocal">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:incident">
    <span class="incident">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:kinesic">
    <span class="kinesic">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:del">
    <span class="del">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:sic">
    <span class="sic">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:corr">
    <span class="corr">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:orig">
    <span class="orig">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:reg">
    <span class="reg">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:abbr">
    <span class="abbr">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:expan">
    <span class="expan">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:emph">
    <span class="emph">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:foreign">
    <span class="foreign">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:persName">
    <span class="persName">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:placeName">
    <span class="placeName">
            <xsl:apply-templates/>
        </span>
</xsl:template>

<xsl:template match="tei:orgName">
    <span class="orgName">
            <xsl:apply-templates/>
        </span>
</xsl:template>

</xsl:stylesheet>