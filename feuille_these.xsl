<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <xsl:text>\title{</xsl:text>
        <xsl:apply-templates select="/tei:TEI/tei:teiHeader//tei:titleStmt/tei:title"/>
        <xsl:text>\vspace{-6ex}}</xsl:text>
        <xsl:text>\begin{document}</xsl:text>

        <xsl:text>\tableofcontents </xsl:text>
        <xsl:apply-templates select="//tei:TEI[@type = 'these']"/>

        <!--<!-\-Règle qui crée un document montrant les débuts de chaque exemple-\->
        <xsl:result-document
            href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Dehors/these/extraction_incipit_exemples_glose.tex">
            <xsl:text>\documentclass[oneside,a4paper,12pt]{memoir}
\usepackage[T1]{fontenc} 
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
\usepackage{hyperref}
\usepackage{fbb}
\begin{document}
Chapitres 1 à 16
\begin{itemize}
</xsl:text>
            <xsl:for-each
                select="descendant::tei:TEI[@xml:id = 'Sev_Z']//tei:div[@type = 'chapitre'][not(@subtype)][number(@n) &lt; 17]/descendant::tei:seg[@type = 'exemple']">
                <xsl:text>\item \textbf{</xsl:text>
                <xsl:value-of select="ancestor::tei:div[not(@subtype)]/@n"/>
                <xsl:text>}: </xsl:text>
                <xsl:variable name="reduction">
                    <xsl:apply-templates/>
                </xsl:variable>
                <xsl:value-of select="substring($reduction/text(), 1, 95)"/>
                <xsl:text> [...]</xsl:text>
            </xsl:for-each>
            <xsl:text>\end{itemize}
                Chapitres 17 à 23
                \begin{itemize}</xsl:text>
            <xsl:for-each
                select="descendant::tei:TEI[@xml:id = 'Sev_Z']//tei:div[@n > 16]/descendant::tei:seg[@type = 'exemple']">
                <xsl:text>\item \textbf{</xsl:text>
                <xsl:value-of select="ancestor::tei:div[not(@subtype)]/@n"/>
                <xsl:text>}: </xsl:text>
                <xsl:variable name="reduction">
                    <xsl:apply-templates/>
                </xsl:variable>
                <xsl:value-of select="substring($reduction/text(), 1, 95)"/>
                <xsl:text> [...]</xsl:text>
            </xsl:for-each>
            <xsl:text>
                \end{itemize}
\end{document}</xsl:text>
        </xsl:result-document>
        -->
        <!--Règle qui crée un document montrant les débuts de chaque exemple-->

        <!--<!-\-Règle qui extrait les exemples-\->
        <xsl:result-document
            href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Dehors/these/extraction_exemples_glose.tex">
            <xsl:text>\documentclass[oneside,a4paper,12pt]{memoir}
\usepackage[T1]{fontenc} 
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
\usepackage{hyperref}
\usepackage{fbb}
\begin{document}
Chapitres 1 à 16
\begin{itemize}
</xsl:text>
            <xsl:for-each
                select="descendant::tei:TEI[@xml:id = 'Sev_Z']//tei:div[@type = 'chapitre'][not(@subtype)][number(@n) &lt; 17]/descendant::tei:seg[@type = 'exemple']">
                <xsl:text>\item \textbf{</xsl:text>
                <xsl:value-of select="ancestor::tei:div[not(@subtype)]/@n"/>
                <xsl:text>}: </xsl:text>
                <xsl:text>\marginpar{</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates/>
                <xsl:text> [...!]</xsl:text>
            </xsl:for-each>
            <xsl:text>\end{itemize}
                Chapitres 17 à 23
                \begin{itemize}</xsl:text>
            <xsl:for-each
                select="descendant::tei:TEI[@xml:id = 'Sev_Z']//tei:div[@n > 16]/descendant::tei:seg[@type = 'exemple']">
                <xsl:text>\item \textbf{</xsl:text>
                <xsl:value-of select="ancestor::tei:div[not(@subtype)]/@n"/>
                <xsl:text>}: </xsl:text>
                <xsl:text>\marginpar{</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates/>
                <xsl:text> [...]</xsl:text>
            </xsl:for-each>
            <xsl:text>
                \end{itemize}
\end{document}</xsl:text>
        </xsl:result-document>
        -->
        <!--Règle qui extrait les exemples-->

    </xsl:template>








    <!--  <xsl:template match="tei:TEI[@xml:id = 'Sal_J']">
        <xsl:result-document href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Statistiques/statistiques_glose_trad_j.csv"/>
    </xsl:template>-->

    <xsl:template match="tei:div[@type = 'partie']">
        <xsl:text>
            \part{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'chapitre']">
        <xsl:text>
            
            \chapter{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'section']">
        <xsl:text>
            
            \section{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'sous_section']">
        <xsl:text>
            
            \subsection{</xsl:text>
        <!--À ce niveau un apply-templates bloque: trouver pourquoi ça marche pas-->
        <xsl:value-of select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template match="tei:div[@type = 'sous_sous_section']">
        <xsl:text>
            
            \subsubsection{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template match="tei:div[@type = 'sous_sous_sous_section']">
        <xsl:text>
            
            \paragraph{</xsl:text>
        <xsl:value-of select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template match="tei:div[@xml:id = 'remerciements']">
        <xsl:text>\section{Remerciements}
            Mes remerciements à </xsl:text>
        <xsl:for-each select="descendant::tei:item">
            <xsl:value-of select="."/>
            <xsl:choose>
                <xsl:when test="following-sibling::tei:item">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:ptr[@type = 'inclusion']">
        <xsl:text>\input{</xsl:text>
        <xsl:value-of select="@target"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template
        match="tei:quote[@type = 'primaire'][not(parent::tei:note)][not(@subtype = 'vers')]">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                <xsl:when test="@xml:lang = 'eso' or @xml:lang = 'es'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(.) > 90">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(.) > 120">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:quote[@type = 'primaire'][not(parent::tei:note)][@subtype = 'vers']">
        <xsl:text>\begin{adjustwidth}{4.5cm}{2cm}</xsl:text>
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                <xsl:when test="@xml:lang = 'eso' or @xml:lang = 'es'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(.) > 90">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(.) > 120">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\end{adjustwidth}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:quote[@type = 'primaire'][parent::tei:note]">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                <xsl:when test="@xml:lang = 'eso' or @xml:lang = 'es'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue != 'french'">
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}}</xsl:text>
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


    <!--Ajouter les règles sur la langue-->
    <xsl:template match="tei:quote[@type = 'secondaire']">
        <xsl:variable name="texte">
            <xsl:for-each select="text()[not(parent::tei:note)]">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($texte) > 200">
                <xsl:text>\begin{quote}</xsl:text>
                <xsl:apply-templates/>
                <xsl:text/>
                <xsl:text>\end{quote}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\enquote{</xsl:text>
                <!--                <xsl:text>``</xsl:text>-->
                <xsl:apply-templates/>
                <!--                <xsl:text>''</xsl:text>-->
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:soCalled">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:list">
        <xsl:text>\begin{itemize}</xsl:text>
        <xsl:for-each select="tei:item">
            <xsl:text>\item </xsl:text>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>\end{itemize}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:div[@xml:id = 'PUIRiBQepM']">
        <xsl:text> \includepdf[scale=1]{../tableau_resume.pdf} </xsl:text>
        <!-- <xsl:result-document
            href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Dehors/these/tableau_resume_titre.tex">
            <xsl:text>
\documentclass[landscape,oneside,a1paper,14pt]{memoir}
\usepackage[T1]{fontenc} 
\usepackage[utf8]{inputenc}
\usepackage[french,spanish]{babel}
\usepackage{hyperref}
\usepackage{fbb}
\usepackage{lipsum}
\usepackage{array}
\usepackage{tabularx,ragged2e}
\newcolumntype{D}{>{\arraybackslash}X}
\newcolumntype{C}{>{\Centering\arraybackslash}X}
\usepackage{makecell}
\usepackage[a1paper,top=5cm, bottom=5cm, left=.5cm,right=.5cm, heightrounded]{geometry}
\usepackage[table]{xcolor}    % loads also »colortbl«

\date{}

\begin{document}
  \rowcolors{2}{gray!25}{white}
\thispagestyle{empty}
\begin{center}
{\Huge \textsc{Résumé des chapitres}}\vfill
            \begin{tabularx}{.8\textwidth}{|p{.1\textwidth}|p{.3\textwidth}|p{.20\textwidth}|p{.18\textwidth}|}\hline
      \rowcolor{gray!50}
            {\HUGE \textsc{Chapitre} }&amp; {\Huge \textsc{Titre} } &amp; {\Huge \textsc{Résumé traduction} } &amp; {\Huge \textsc{Résumé glose} }\\\hline\hline 
        </xsl:text>
            <xsl:for-each select="tei:div">
                <xsl:variable name="numero_chapitre" select="@n"/>
                <!-\-Gestion de la colonne numéro de chapitres-\->
                <xsl:text>\textbf{</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>}</xsl:text>
                <xsl:text> &amp; </xsl:text>
                <!-\-Gestion de la colonne numéro de chapitres-\->

                <!-\-Gestion de la colonne titre-\->
                <xsl:apply-templates
                    select="//tei:TEI[@xml:id = 'Sev_Z']//tei:div[@type = 'chapitre'][@n = $numero_chapitre]/tei:head"/>
                <xsl:text> &amp; </xsl:text>

                <!-\-Gestion de la colonne titre-\->

                <!-\-Gestion de la colonne traduction-\->

                <!-\-Reste a creer une règle avec l'opérateur mod (when test number(parent::div/@n) mod 2 = 1, then; otherwise )
            pour gérer les problèmes de couleur. Voir https://tex.stackexchange.com/questions/309383/table-cell-line-break-and-rowcolors-\->
                <xsl:choose>
                    <xsl:when test="count(tei:div[1]/tei:p) > 1">
                        <xsl:text>\makecell[l]{</xsl:text>
                        <xsl:for-each select="tei:div[1]/tei:p">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="following-sibling::tei:p">
                                <xsl:text> \\ </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="tei:div[1]/tei:p"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> &amp; </xsl:text>
                <!-\-Gestion de la colonne traduction-\->

                <!-\-Gestion de la colonne glose-\->
                <xsl:choose>
                    <xsl:when test="count(tei:div[2]/tei:p) > 1">
                        <xsl:text>\makecell[l]{</xsl:text>
                        <xsl:for-each select="tei:div[2]/tei:p">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="following-sibling::tei:p">
                                <xsl:text>\\</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="tei:div[2]/tei:p"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\\ \hline
                </xsl:text>

                <!-\-Gestion de la colonne glose-\->


            </xsl:for-each>
            <xsl:text>
            \end{tabularx}
            \end{center}\vfill</xsl:text>

            <!-\-Gestion des notes de bas de page1: fonctionne bien si on crée un document unique.
    À modifier si on veut inclure le tableau dans le document de thèse (gérer le numéro de note en particulier).-\->
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext[</xsl:text>
                <xsl:value-of
                    select="count(preceding::tei:note[ancestor::tei:div[@type = 'resume_par_chapitre']]) + 1"/>
                <xsl:text>]{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
            <!-\-Gestion des notes de bas de page: fonctionne bien si on crée un document unique-\->
            <xsl:text>
            \end{document}</xsl:text>
        </xsl:result-document>




        <!-\-Feuille qui crée le même tableau sans le titre-\->
        <xsl:result-document
            href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Dehors/these/tableau_resume.tex">
            <xsl:text>
\documentclass[landscape,oneside,a1paper,14pt]{memoir}
\usepackage[T1]{fontenc} 
\usepackage[utf8]{inputenc}
\usepackage[french,spanish]{babel}
\usepackage{hyperref}
\usepackage{fbb}
\usepackage{array}
\usepackage{tabularx,ragged2e}
\newcolumntype{D}{>{\arraybackslash}X}
\newcolumntype{C}{>{\Centering\arraybackslash}X}
\usepackage{makecell}
\usepackage[a1paper,top=5cm, bottom=5cm, left=.5cm,right=.5cm, heightrounded]{geometry}
\usepackage[table]{xcolor}    % loads also »colortbl«

\date{}

\begin{document}
  \rowcolors{2}{gray!25}{white}
\thispagestyle{empty}
\begin{center}
{\Huge \textsc{Résumé des chapitres}}\vfill
            \begin{tabularx}{.4\textwidth}{c|p{.25\textwidth}|p{.20\textwidth}}
      \rowcolor{gray!50}
            {\HUGE \textsc{Chapitre} } &amp; {\Huge \textsc{Résumé traduction} } &amp; {\Huge \textsc{Résumé glose} }\\
        </xsl:text>
            <xsl:for-each select="tei:div">
                <xsl:variable name="numero_chapitre" select="@n"/>
                <!-\-Gestion de la colonne numéro de chapitres-\->
                <xsl:text>\textbf{</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>}</xsl:text>
                <xsl:text> &amp; </xsl:text>
                <!-\-Gestion de la colonne numéro de chapitres-\->



                <!-\-Gestion de la colonne traduction-\->

                <!-\-Reste a creer une règle avec l'opérateur mod (when test number(parent::div/@n) mod 2 = 1, then; otherwise )
            pour gérer les problèmes de couleur. Voir https://tex.stackexchange.com/questions/309383/table-cell-line-break-and-rowcolors-\->
                <xsl:choose>
                    <xsl:when test="count(tei:div[1]/tei:p) > 1">
                        <xsl:text>\makecell[l]{</xsl:text>
                        <xsl:for-each select="tei:div[1]/tei:p">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="following-sibling::tei:p">
                                <xsl:text> \\ </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="tei:div[1]/tei:p"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> &amp; </xsl:text>
                <!-\-Gestion de la colonne traduction-\->

                <!-\-Gestion de la colonne glose-\->
                <xsl:choose>
                    <xsl:when test="count(tei:div[2]/tei:p) > 1">
                        <xsl:text>\makecell[l]{</xsl:text>
                        <xsl:for-each select="tei:div[2]/tei:p">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="following-sibling::tei:p">
                                <xsl:text>\\</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="tei:div[2]/tei:p"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\\
                </xsl:text>

                <!-\-Gestion de la colonne glose-\->


            </xsl:for-each>
            <xsl:text>
            \end{tabularx}
            \end{center}\vfill</xsl:text>

            <!-\-Gestion des notes de bas de page1: fonctionne bien si on crée un document unique.
    À modifier si on veut inclure le tableau dans le document de thèse (gérer le numéro de note en particulier).-\->
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext[</xsl:text>
                <xsl:value-of
                    select="count(preceding::tei:note[ancestor::tei:div[@type = 'resume_par_chapitre']]) + 1"/>
                <xsl:text>]{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
            <!-\-Gestion des notes de bas de page: fonctionne bien si on crée un document unique-\->
            <xsl:text>
            \end{document}</xsl:text>
        </xsl:result-document>
        -->
        <!--Feuille qui crée le même tableau sans le titre-->
    </xsl:template>

    <!--<xsl:template match="tei:*[@xml:lang]">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                <xsl:when test="@xml:lang = 'es'">spanish</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>\begin{otherlanguage}{</xsl:text>
        <xsl:value-of select="$langue"/>
        <xsl:text>}\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}\end{otherlanguage}</xsl:text>
    </xsl:template>-->

    <xsl:template match="tei:foreign[parent::tei:quote]">
        <!--Façon un peu propre d'utiliser les conditions-->
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                <xsl:otherwise>spanish</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>\begin{otherlanguage}{</xsl:text>
        <xsl:value-of select="$langue"/>
        <xsl:text>}\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}\end{otherlanguage}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:l">
        <xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="following-sibling::tei:l">
                <xsl:text>\\</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:graphic">
        <xsl:text>
        \begin{figure}[h]
        \centering
        \includegraphics[scale=</xsl:text>
        <xsl:value-of select="@scale"/>
        <xsl:text>]{</xsl:text>
        <xsl:value-of select="@url"/>
        <xsl:text>}
        \caption{</xsl:text>
        <xsl:apply-templates select="tei:desc"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>
        \end{figure}
    </xsl:text>
    </xsl:template>

    <xsl:template match="tei:foreign[not(parent::tei:quote)]">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!--Gestion des notes de bas de page2: fonctionne bien si on crée un document unique.
    À modifier si on veut inclure le tableau dans le document de thèse.-->
    <xsl:template match="tei:note[ancestor::tei:div[@type = 'resume_par_chapitre']]">
        <xsl:text>\footnotemark </xsl:text>
    </xsl:template>
    <!--Gestion des notes de bas de page: fonctionne bien si on crée un document unique-->
    <xsl:template match="tei:note">
        <xsl:text>\footnote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:reg | tei:expan"/>
    </xsl:template>

    <xsl:template match="tei:code">
        <xsl:text>\codeword{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:orig">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:p">
        <xsl:apply-templates/>
        <xsl:text>\par </xsl:text>
    </xsl:template>

    <xsl:template match="tei:lb[@break = 'y']">
        <xsl:text>\\</xsl:text>
    </xsl:template>

    <xsl:template match="tei:lb[@break = 'n']">
        <xsl:text>\textsuperscript{[lb]}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:fw | tei:teiHeader"/>

    <xsl:template match="tei:head">
        <xsl:text>~~</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'biblio']">
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:choose>
            <xsl:when test="parent::tei:note">
                <xsl:text>\cite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> [\cite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="tei:title">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'interne']">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:if test="not(//tei:*[@xml:id = $target]/ancestor-or-self::tei:graphic)">
            <xsl:text>\nameref{</xsl:text>
            <xsl:value-of select="$target"/>
            <xsl:text>}, page \pageref{</xsl:text>
            <xsl:value-of select="$target"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="//tei:*[@xml:id = $target]/ancestor-or-self::tei:graphic">
            <xsl:text>figure \ref{</xsl:text>
            <xsl:value-of select="$target"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'ref_textuelle']">
        <xsl:text>\footnote{\textit{Regimiento}, témoin </xsl:text>
        <xsl:value-of select="translate(substring-before(@target, '_'), '#', '')"/>
        <xsl:text>, chapitre </xsl:text>
        <xsl:variable name="paragraphe" select="substring-after(translate(@target, '#', ''), '_')"/>
        <xsl:variable name="temoin" select="substring-before(translate(@target, '#', ''), '_')"/>
        <xsl:value-of
            select="//tei:TEI[substring-after(@xml:id, '_') = $temoin]//tei:div[@type = 'chapitre'][not(@subtype)][descendant::tei:p/@n = $paragraphe]/@n"/>
        <xsl:text>, paragraphe </xsl:text>
        <!--Quand les identifiants de paragraphes seront fixés, 
            ajouter une règle pour récupérer le numéro de chapitre-->
        <xsl:value-of select="translate(substring-after(@target, '_'), '#', '')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>.}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'texte']">
        <xsl:value-of select="translate(@target, '#', '')"/>
        <!-- Décommenter quand le texte sera transformé en \LaTeX aussi
           
           <xsl:text>\nameref{</xsl:text>
        <xsl:value-of select="translate(@target, '#', '')"/>
        <xsl:text>}, page \pageref{</xsl:text>
        <xsl:value-of select="translate(@target, '#', '')"/>
        <xsl:text>}</xsl:text>-->
    </xsl:template>

    <xsl:template match="tei:emph">
        <xsl:choose>
            <xsl:when test="not(parent::tei:foreign)">
                <xsl:text>\emph{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>\textit{</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'url'][not(parent::tei:note)]">
        <xsl:variable name="echappement_url" select="replace(@target, '#', '\\#')"/>
        <xsl:choose>
            <xsl:when test="text()">
                <xsl:text>\footnote{\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\footnote{\url{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'url'][parent::tei:note]">
        <xsl:variable name="echappement_url" select="replace(@target, '#', '\\#')"/>
        <xsl:choose>
            <xsl:when test="text()">
                <xsl:text>\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\url{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="comment()">
        <xsl:text>%</xsl:text>
        <xsl:apply-templates select="replace(., '&#xA;', '')"/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:variable name="sub1" select="replace(., '⁊', 'e')"/>
        <xsl:variable name="sub2" select="replace($sub1, ' ', ' ')"/>
        <xsl:variable name="sub3" select="replace($sub2, '&amp;', '\\&amp;')"/>
        <xsl:variable name="sub4" select="replace($sub3, '%', '\\%')"/>
        <xsl:value-of select="$sub4"/>
    </xsl:template>

</xsl:stylesheet>
