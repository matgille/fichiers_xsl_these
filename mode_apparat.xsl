<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:myfunctions="https://www.matthiasgillelevenson.fr/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tex="placeholder.uri" exclude-result-prefixes="tex">


    <!--On rassemble deux modes ici: 
    - citation apparat = le mode qui gère tout ce qui permet de rendre une citation avec (ou sans) apparat
    - apparat = le mode qui gère le fonctionnement à l'intérieur d'un apparat-->



    <xsl:template match="tei:hi[@rend = 'initiale' or @rend = 'non_initiale']"
        mode="apparat omission_simple">
        <xsl:value-of select="."/>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'lettre_attente']" mode="apparat omission_simple"/>


    <xsl:template mode="apparat omission_simple"
        match="tei:note[@subtype = 'lexicale'][not(parent::tei:head)] | tei:note[@type = 'particulier'] | tei:note[@type = 'general'] | tei:note[@type = 'sources']">
        <xsl:text>\footnote</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'sources'">
                <xsl:text>C</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>B</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>{\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="@corresp">
                <xsl:variable name="corresponding_witness" select="@corresp"/>
                <xsl:if test="@type">
                    <!--<xsl:if test="@type = 'particulier'"> Mode debug-->
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="translate(@corresp, '_#', ' ')"/>
                    <!--<xsl:text>. Leçon du témoin: \enquote{</xsl:text>
                    <xsl:for-each
                        select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $corresponding_witness)]//tei:w">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text>}</xsl:text>-->
                    <xsl:text>] </xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!--Debug pour retrouver plus facilement les notes dans le xml-->
                <xsl:text>[Témoin </xsl:text>
                <xsl:value-of select="replace(ancestor::tei:TEI/@xml:id, '_', ' ')"/>
                <xsl:text>]</xsl:text>
                <!--Debug pour retrouver plus facilement les notes dans le xml-->
            </xsl:otherwise>
        </xsl:choose>
        <!--On fait ça pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@ana = '#injected'">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="translate(ancestor::tei:div[not(ancestor::tei:div)]/@corresp, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates
            select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')//tei:TEI[@xml:id = $corresponding_wit]/descendant::tei:div[@n = $division]/descendant::tei:note[@xml:id = $xml_id]/node()"
            mode="apparat"/>
        <!--On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-->
        <xsl:text>
            }</xsl:text>
    </xsl:template>

    <xsl:template match="tei:quote[@type = 'primaire']" mode="apparat omission_simple">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'lat'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'eng'">english</xsl:when>
                <xsl:when test="@xml:lang = 'spo' or @xml:lang = 'esp'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue != 'french'">
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:choose>
                            <xsl:when test="string-length(string-join(descendant::text())) &gt; 200">
                                <xsl:text>\begin{note_quote}\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates/>
                                <xsl:text>}\end{otherlanguage}\end{note_quote}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates/>
                                <xsl:text>}\end{otherlanguage}}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <!--  <xsl:template match="tei:witEnd" mode="citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:variable name="firstAnchorCorresps" select="@corresp"/>
        <xsl:variable name="lastAnchorCorresps"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@corresp"/>
        <xsl:variable name="firstAnchorID" select="@xml:id"/>
        <xsl:variable name="lastAnchorID"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@xml:id"/>
        <xsl:text>
        </xsl:text>
        <xsl:choose>
            <xsl:when test="$firstAnchorCorresps = $lastAnchorCorresps">
                <xsl:choose>
                    <!-\-Premier cas: le témoin courant n'omet pas le texte-\->
                    <xsl:when test="not(contains($firstAnchorCorresps, $temoin_base_citation))">
                        <xsl:text>\edtext{</xsl:text>
                        <!-\-La transposition va poser problème ici dans les cas de suites d'apparats compliqués Passer dans l'@ana des tei:app la transposition.-\->
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][not(ancestor::tei:seg[@ana = '#transposition'])]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}{</xsl:text>
                        <xsl:text>\lemma{</xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][1]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>\ldots ~</xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][last()]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}\Dfootnote{\,|\,\textit{om.} \textit{</xsl:text>
                        <xsl:value-of select="myfunctions:witstosigla($firstAnchorCorresps)"/>
                        <xsl:text>}}}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="first_preceding_sibling"
                            select="preceding::tei:app[1]/descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]"/>
                        <xsl:variable name="omitted_witnesses">
                            <xsl:choose>
                                <xsl:when test="$first_preceding_sibling/ancestor::tei:rdgGrp">
                                    <xsl:for-each
                                        select="$first_preceding_sibling/ancestor::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_citation)]]/descendant::tei:rdg">
                                        <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                                        <xsl:if test="following-sibling::tei:rdg">
                                            <xsl:text>`</xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="myfunctions:witstosigla($first_preceding_sibling/descendant::tei:rdg[contains(@wit, $temoin_base_citation)]/@wit)"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>\edtext{}{\lemma{</xsl:text>
                        <xsl:apply-templates select="$first_preceding_sibling"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}\Dfootnote{\textit{</xsl:text>
                        <xsl:value-of select="$omitted_witnesses"/>
                        <xsl:text>}\,|\,</xsl:text>
                        <xsl:apply-templates select="$first_preceding_sibling"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                    <!-\-Premier cas: le témoin courant n'omet pas le texte-\->
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
-->

    <!--  <xsl:template match="tei:witEnd" mode="citation_apparat">
        <xsl:param name="temoin_base_edition"/>
        <xsl:text>% Omission ici &#10;</xsl:text>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:message>
            <xsl:value-of select="$div_n"/>
        </xsl:message>
        <xsl:variable name="temoin_base" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <!-\-Quand le témoin de base n'est pas concerné, c'est le cas le plus simple: on n'a qu'à indiquer par une lettre en exposant
            le ou les témoins où le texte s'arrête.-\->
            <xsl:when test="not(contains(@corresp, $temoin_base))">
                <xsl:variable name="wits" select="myfunctions:witstosigla(@corresp)"/>
                <xsl:text>\textsuperscript{</xsl:text>
                <xsl:value-of select="$wits"/>
                <xsl:text>}</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:when>
            <!-\-Dans le cas contraire, ça se complique: il faut aller indiquer qu'à un point précis il y a un bout de texte que
            le témoin base ne propose pas. On va donc devoir travailler sur du contexte à gauche pour produire un apparat compréhensible-\->
            <xsl:otherwise>
                <xsl:text>% Omission du témoin base &#10;</xsl:text>
                <xsl:variable name="wits" select="@xml:id"/>
                <xsl:choose>
                    <!-\-Omission simple-\->
                    <xsl:when test="following::tei:witStart[translate(@previous, '#', '') = $wits]">
                        <xsl:message>OK</xsl:message>
                        <xsl:variable name="following_witstart_id"
                            select="following::tei:witStart[translate(@previous, '#', '') = $wits]/@xml:id"/>
                        <xsl:variable name="next_node_div_n"
                            select="following::tei:witStart[translate(@previous, '#', '') = $wits]/ancestor::tei:div[@type = 'chapitre']/@n"/>
                        <xsl:variable name="corresponding_nodes">
                            <!-\-Essayer de simplifier l'expression.-\->
                            <xsl:copy-of
                                select="following::tei:app[ancestor::tei:div[@type = 'chapitre'][@n &gt; $div_n - 1][@n &lt; $next_node_div_n + 1]][following::tei:witStart[@xml:id = $following_witstart_id]]"
                            />
                        </xsl:variable>
                        <xsl:variable name="preceding_omitted_lemma">
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]] | self::tei:w][1]/name() = 'app'">
                                    <xsl:apply-templates
                                        select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base)]/tei:w"
                                        mode="apparat"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates
                                        select="preceding-sibling::node()[self::tei:w][1]" mode="apparat"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="preceding_omitted_witnesses">
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]] | self::tei:w][1]/name() = 'app'">
                                    <xsl:value-of
                                        select="myfunctions:witstosigla(preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdgGrp[contains(string-join(descendant::tei:rdg/@wit), $temoin_base)]/descendant::tei:rdg/@wit)"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring-after($temoin_base, '_')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>\edtext{}{\lemma{</xsl:text>
                        <xsl:value-of select="$preceding_omitted_lemma"/>
                        <xsl:text>}\Afootnote{\textit{</xsl:text>
                        <xsl:value-of select="myfunctions:debug($following_witstart_id)"/>
                        <xsl:value-of select="$preceding_omitted_witnesses"/>
                        <xsl:text>} | </xsl:text>
                        <xsl:if test="@ana = '#homeoteleuton'">
                            <xsl:text> Saut du même au même pour le témoin base: </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$preceding_omitted_lemma"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="$corresponding_nodes" mode="omission_simple">
                            <xsl:with-param name="temoin_base">
                                <!-\-Il faut choisir un autre témoin base. On prend le premier de la liste, arbitrairement.-\->
                                <!-\-https://stackoverflow.com/a/25405132-\->
                                <xsl:value-of
                                    select="replace(following::tei:app[1]/descendant::tei:rdg[descendant::tei:w][1]/@wit, '^.*#', '')"
                                />
                            </xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:text>~\textit{</xsl:text>
                        <xsl:value-of
                            select="myfunctions:witstosigla(following::tei:app[1]/descendant::tei:rdg[descendant::tei:w]/@wit)"/>
                        <xsl:text>}}}</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

-->



    <xsl:template match="tei:app[@ana = '#not_apparat']"
        mode="citation_omission_complexe apparat rdg_apparat omission_simple citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
            mode="citation_apparat"/>
    </xsl:template>



    <xsl:template
        match="tei:app[@ana = '#graphique'][not(contains(@ana, '#omission'))] | tei:app[contains(@ana, '#filtre')][not(contains(@ana, '#omission'))][count(descendant::tei:rdg) = 1] | tei:app[contains(@ana, '#auxiliarite')][not(contains(@ana, '#omission'))] | tei:app[contains(@ana, '#normalisation')][not(contains(@ana, '#omission'))]"
        mode="citation_apparat">
        <xsl:text> </xsl:text>
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
            mode="citation_apparat"/>
    </xsl:template>


    <xsl:template
        match="tei:app[contains(@ana, '#filtre')][count(descendant::tei:rdg) > 1][not(contains(@ana, '#omission'))]"
        mode="citation_apparat">
        <xsl:text> </xsl:text>
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
            mode="citation_apparat"/>
    </xsl:template>


    <xsl:template match="
            tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) = 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) = 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) = 1]"
        mode="citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="citation_apparat"/>
    </xsl:template>


    <xsl:template match="
            tei:app[contains(@ana, '#entite_nommee')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#personne')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#genre')][count(descendant::tei:rdg) > 1]"
        mode="citation_omission_complexe" priority="3">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:text>[ </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"/>
        <xsl:choose>
            <xsl:when test="tei:rdgGrp">
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_citation)]]/descendant::tei:rdg">
                        <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                        <xsl:if test="following-sibling::tei:rdg">
                            <xsl:text>`</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="$grouped_sigla"/>
                <xsl:text>} </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>]</xsl:text>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="tei:app[@ana = '#graphique'] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite']"
        mode="citation_omission_complexe citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"/>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> % témoin base 2: </xsl:text>
            <xsl:value-of select="$temoin_base_citation"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:w[not(ancestor::tei:app)]" mode="citation_apparat">
        <!--Dans le cas de citations du texte transcrit et non édité-->
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="citation_apparat"/>
        <xsl:if
            test="following::node()[1][self::text()[not(starts-with(., '.')) or not(starts-with(., ',')) or not(starts-with(., '?')) or not(starts-with(., '!')) or not(starts-with(., ';')) or not(starts-with(., ':'))]]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template
        match="tei:app[contains(@ana, '#omission')][contains(@ana, '#filtre') or contains(@ana, '#normalisation')]"
        priority="1" mode="citation_apparat">
        <!--Filtre avec omission: on imprime l'omission et tous les témoins regroupés sans tenir compte des apparats-->
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <!--Quand le témoin courant n'est pas omis-->
            <xsl:when
                test="descendant::tei:rdg[contains(@wit, $temoin_base_citation)][descendant::tei:w]">
                <xsl:text> % Omission avec variante filtrée ici, témoin courant présent 
                </xsl:text>
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[descendant::tei:rdg[descendant::tei:w]]/descendant::tei:rdg">
                        <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="$grouped_sigla"/>
                <xsl:text>}\,|\,</xsl:text>
                <xsl:text>\textit{om.} \textit{</xsl:text>
                <xsl:value-of
                    select="myfunctions:witstosigla(descendant::tei:rdg[not(descendant::tei:w)]/@wit)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <!--Quand le témoin courant est omis-->

            <!--Si le témoin courant est omis-->
            <xsl:otherwise>
                <xsl:text> % Omission binaire ici, témoin courant omis 
                </xsl:text>
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_citation)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text> </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>}\Bfootnote{| </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of
                    select="myfunctions:witstosigla(descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]/@wit)"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> % témoin base: </xsl:text>
            <xsl:value-of select="$temoin_base_citation"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>



    <xsl:template match="tei:app[contains(@ana, '#omission')][contains(@ana, '#graphique')]" priority="1"
        mode="citation_apparat">
        <!--Si #omission est la seule valeur de l'analyse, alors il s'agit d'une omission binaire (un témoin ou un groupe omet du texte;
        les autres témoins concordent complètement)-->
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <!--Quand le témoin courant n'est pas omis-->
            <xsl:when test="descendant::tei:rdg[contains(@wit, $temoin_base_citation)][tei:w]">
                <xsl:text> % Omission avec variante graphique ici, témoin courant présent 
                </xsl:text>
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[contains(translate(string-join(tei:rdg/@wit), '#', ''), $temoin_base_citation)]">
                        <xsl:for-each select="descendant::tei:rdg">
                            <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                            <xsl:if test="following-sibling::tei:rdg">
                                <xsl:text>`</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="$grouped_sigla"/>
                <xsl:text>}\,|\,</xsl:text>
                <xsl:text>\textit{om.} \textit{</xsl:text>
                <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[not(tei:w)]/@wit)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <!--Quand le témoin courant est omis-->

            <!--Si le témoin courant est omis-->
            <xsl:otherwise>
                <xsl:text> % Omission binaire ici, témoin courant omis 
                </xsl:text>
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_citation)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text> </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>}\Dfootnote{| </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of
                    select="myfunctions:witstosigla(descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]/@wit)"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> % témoin base: </xsl:text>
            <xsl:value-of select="$temoin_base_citation"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:app[@ana = '#omission']" mode="citation_apparat" priority="1">
        <!--Si #omission est la seule valeur de l'analyse, alors il s'agit d'une omission binaire (un témoin ou un groupe omet du texte;
        les autres témoins concordent complètement)-->
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <!--Quand le témoin courant n'est pas omis-->
            <xsl:when
                test="descendant::tei:rdg[contains(@wit, $temoin_base_citation)][descendant::tei:w]">
                <xsl:text> % Omission binaire ici, témoin courant présent 
                </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[tei:w]/@wit)"/>
                <xsl:text>}\,|\,</xsl:text>
                <xsl:text>\textit{om.} \textit{</xsl:text>
                <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[not(tei:w)]/@wit)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <!--Quand le témoin courant est omis-->

            <!--Si le témoin courant est omis-->
            <xsl:otherwise>
                <xsl:text> % Omission binaire ici, témoin courant omis 
                </xsl:text>
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_citation)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text> </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_base_citation, '_')"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>}\Dfootnote{| </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of
                    select="myfunctions:witstosigla(descendant::tei:rdg[not(contains(@wit, $temoin_base_citation))]/@wit)"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:sic[not(@ana = '#omission')]" mode="citation_apparat">
        <xsl:apply-templates mode="citation_apparat"/>
        <xsl:text>\textsuperscript{\textit{[sic]}}</xsl:text>
    </xsl:template>




    <xsl:template
        match="tei:app[@ana = '#graphique'] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite']"
        mode="citation_apparat" priority="1">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:text> %TEST&#10;</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
            mode="citation_apparat"/>
        <!--<xsl:if
            test="descendant::tei:note[not(ancestor::tei:rdg[contains(@wit, $temoin_base_citation)]])]">
            <xsl:apply-templates
                select="descendant::tei:note[not(ancestor::tei:rdg[contains(@wit, $temoin_base_citation)]])]"
                mode="citation_apparat"/>
        </xsl:if>-->
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> %TEST&#10;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="
            tei:app[contains(@ana, '#entite_nommee')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#personne')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#genre')][count(descendant::tei:rdg) > 1]
            " mode="citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:text>% Variante de type </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:text>; témoin courant: </xsl:text>
        <xsl:value-of select="$temoin_base_citation"/>
        <xsl:text>
        </xsl:text>
        <xsl:text> </xsl:text>
        <xsl:variable name="temoin_base_citation2" select="substring-after($temoin_base_citation, '_')"/>
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_citation)]"
            mode="citation_apparat"/>
        <xsl:text>}{\Bfootnote{</xsl:text>
        <xsl:text>\textit{</xsl:text>
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:choose>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:when
                test="descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_citation)]]">
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_citation)]]/descendant::tei:rdg">
                        <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                        <xsl:if test="following-sibling::tei:rdg">
                            <xsl:text>`</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$grouped_sigla"/>
            </xsl:when>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:otherwise>
                <xsl:value-of
                    select="myfunctions:witstosigla(tei:rdg[contains(@wit, $temoin_base_citation)]/@wit)"
                />
            </xsl:otherwise>
        </xsl:choose>
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:text>}\,|\,</xsl:text>
        <!--La même chose mais en utilisant une autre méthode-->
        <xsl:choose>
            <xsl:when test="descendant::tei:rdgGrp">
                <xsl:for-each
                    select="descendant::tei:rdgGrp[not(descendant::tei:rdg[contains(@wit, $temoin_base_citation)])]">
                    <xsl:variable name="grouped_sigla">
                        <xsl:for-each select="descendant::tei:rdg">
                            <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                            <xsl:if test="following-sibling::tei:rdg">
                                <xsl:text>`</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:apply-templates select="tei:rdg[1]" mode="rdg_apparat"/>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="$grouped_sigla"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tei:rdg[not(contains(@wit, $temoin_base_citation))]">
                    <xsl:variable name="sigle_temoin" select="myfunctions:witstosigla(@wit)"/>
                    <xsl:apply-templates select="." mode="rdg_apparat"/>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="$sigle_temoin"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}}</xsl:text>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:rdg" mode="rdg_apparat">
        <xsl:param name="temoin_base_edition"/>
        <xsl:text>%temoin base rdg apparat:</xsl:text>
        <xsl:value-of select="$temoin_base_edition"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:rdg" mode="citation_apparat">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:unclear" mode="citation_apparat apparat omission_simple">
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>~(?)</xsl:text>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_citation)][node()]]]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- <xsl:template match="tei:rdg[not(contains(@wit, $temoin_base_citation))]" mode="citation_apparat">
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:apply-templates mode="citation_apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.} </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    <xsl:template match="tei:milestone"/>

    <xsl:template match="tei:note" mode="citation_apparat"/>


    <xsl:template match="tei:lb[@break = 'yes']" mode="citation_apparat">
        <!--On va ignorer les lb-->
        <xsl:text> </xsl:text>
    </xsl:template>

    <!--<xsl:template match="tei:witStart" mode="citation_apparat">
        <xsl:text>\footnoteA{Le témoin </xsl:text>
        <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
        <xsl:text> reprend ici.}</xsl:text>
    </xsl:template>-->

    <xsl:template match="tei:cb" mode="citation_apparat">
        <xsl:text>\textsuperscript{[cb]}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:space" mode="citation_apparat">
        <xsl:text> </xsl:text>
    </xsl:template>



    <xsl:template match="tei:fw" mode="citation_apparat"/>


    <xsl:template match="tei:supplied" mode="citation_apparat">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:add[@type = 'correction']" mode="citation_apparat">
        <xsl:text>[Correction d'une main:</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>



</xsl:stylesheet>
