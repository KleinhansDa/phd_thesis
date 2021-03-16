% This file is copyright (C) 2003 Sam Noble. It may be modified so long
% as my name is not removed and the modifier adds his name to the file.
% Redistribution permitted.
%
% 27 Jan 2004	Sam Noble	Removed tocbibind dependency.
% 04 Dec 2001 	Sam Noble	Class file
% 03 Sep 1995	David Perkinson	Title Page
% Acknowledgements Page, David Perkinson & Sam Noble
% May 2005 Patrick Carlisle Table of contents chapter definition
% 2004-2005 Ben Salzberg (BTS) a variety of tweaks here and in the template
% 2015 Chester Ismay (CII) modified to create R Markdown template

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{reedthesis}[2004/01/27 The Reed College Thesis Class]
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\LoadClass{book}
\RequirePackage{fancyhdr}

% Added by CII to produce nice looking code in BeginVerbatimEnvironment
\RequirePackage{fancyvrb}

% Added by CII
\usepackage{ifxetex,ifluatex}
\usepackage{fixltx2e} % provides \textsubscript
\ifnum 0\ifxetex 1\fi\ifluatex 1\fi=0 % if pdftex
  \usepackage[T1]{fontenc}
  \usepackage[utf8]{inputenc}
\else % if luatex or xelatex
  \ifxetex
    \usepackage{mathspec,wasysym}
    \usepackage{xltxtra,xunicode}
  \else
    \usepackage{fontspec}
  \fi
  \defaultfontfeatures{Mapping=tex-text, Scale=MatchLowercase}
  \newcommand{\euro}{€}
\fi
% use upquote if available, for straight quotes in verbatim environments
\IfFileExists{upquote.sty}{\usepackage{upquote}}{}
% use microtype if available
\IfFileExists{microtype.sty}{%
\usepackage{microtype}
\UseMicrotypeSet[protrusion]{basicmath} % disable protrusion for tt fonts
}{}
\usepackage{color}
%\newcommand{\VerbBar}{|}
%\newcommand{\VERB}{\Verb[commandchars=\\\{\}]}
\DefineVerbatimEnvironment{verbatim}{Verbatim}{xleftmargin=-1em}
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{commandchars=\\\{\}}
% Add ',fontsize=\small' for more characters per line
\usepackage{framed}
\definecolor{shadecolor}{RGB}{248,248,248}
\setlength{\emergencystretch}{3em}  % prevent overfull lines
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
% End of CII add

% This gives us rules below the headers

% Stolen from book.cls and modified
\let\RToldchapter\chapter
\renewcommand{\chapter}{
  \if@openright\RTcleardoublepage
  \else\clearpage\fi
  \thispagestyle{empty}%
  %\renewcommand{\headrulewidth}{0pt} % no top rule
  \global\@topnum\z@
	\@afterindentfalse
	\secdef\@chapter\@schapter}

% Stolen from book.cls PBC 5/12/05
% Using this to actually show "Chapter 1" in TOC instead of "1"
\def\@chapter[#1]#2{
  \ifnum \c@secnumdepth >\m@ne
  \if@mainmatter
    \refstepcounter{chapter}
    \typeout{\@chapapp\space\thechapter.}
    \addcontentsline{toc}{chapter}
    {\@chapapp\space\thechapter:\space#1}
  \else
    \addcontentsline{toc}{chapter}{#1}
  \fi
  \else
    \addcontentsline{toc}{chapter}{#1}
  \fi
  \chaptermark{#1}
  \addtocontents{lof}{\protect\addvspace{10\p@}}
  \addtocontents{lot}{\protect\addvspace{10\p@}}
  \if@twocolumn
    \@topnewpage[\@makechapterhead{#2}]
  \else
    \@makechapterhead{#2}
    \@afterheading
  \fi
  }

\newcommand{\RTcleardoublepage}{
	\clearpage\if@twoside \ifodd\c@page\else
	\thispagestyle{empty}\hbox{}\newpage
  \if@twocolumn\hbox{}\newpage\fi\fi\fi
  }

\let\RToldcleardoublepage\cleardoublepage
\renewcommand{\cleardoublepage}{\RTcleardoublepage}

% adjust margins for binding  (changed 2007-04-24 tgp)
\setlength{\oddsidemargin}{.2in}
\setlength{\evensidemargin}{.2in}
\setlength{\textwidth}{5in}
\setlength{\textheight}{8in}
% top margin
\setlength\topmargin{0in}
\addtolength\topmargin{-\headheight}
\addtolength\topmargin{-\headsep}

% degree
\def\degree#1{\gdef \@degree{#1}}
\def\@degree{\@latex@warning@no@line{No \noexpand\degree given}}
% institution
\def\institution#1{\gdef \@institution{#1}}
\def\@institution{\@latex@warning@no@line{No \noexpand\institution given}}
% division
\def\division#1{\gdef \@division{#1}}
\def\@division{\@latex@warning@no@line{No \noexpand\division given}}
% department
\def\department#1{\gdef \@department{#1}}
\def\@department{\@latex@warning@no@line{No \noexpand\department given}}
% division of
\def\thedivisionof#1{\gdef \@thedivisionof{#1}}
\def\@thedivisionof{The Division of}
% approvedforthe
\def\approvedforthe#1{\gdef \@approvedforthe{#1}}
\def\@approvedforthe{Division}
% advisor
\def\advisor#1{\gdef \@advisor{#1}}
\def\@advisor{\@latex@warning@no@line{No \noexpand\advisor given}}
% altadvisor
\def\altadvisor#1{\gdef \@altadvisor{#1} \@altadvisortrue}
\global\let\@altadvisor\@empty
\newif\if@altadvisor
\@altadvisorfalse

\renewcommand\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{1.5em}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      \leavevmode \bfseries
      \advance\leftskip\@tempdima
      \hskip -\leftskip
      #1\nobreak\normalfont
      \leaders\hbox{$\m@th \mkern \@dotsep mu\hbox{.}\mkern \@dotsep mu$}\hfill
      \nobreak\hb@xt@\@pnumwidth{\bfseries \hss #2}\par
      \penalty\@highpenalty
    \endgroup
  \fi}

%%% Preliminary Content
\newenvironment{acknowledgements}{
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{Acknowledgements}
  \fontsize{12}{14}\selectfont
}{\clearpage \if@restonecol\twocolumn\fi}

\newenvironment{preface}{
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{Preface}
  \fontsize{12}{14}\selectfont
}{\clearpage \if@restonecol\twocolumn\fi}

\newenvironment{abstract}{
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{Abstract}
  \fontsize{12}{14}\selectfont
}{\clearpage \if@restonecol\twocolumn\fi}%

\newenvironment{dedication}{
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{Dedication}
  \fontsize{12}{14}\selectfont
}{\clearpage \if@restonecol\twocolumn\fi}

% I hacked the title page to all be the same font size
% as requested by the library, BTS 2005

\renewcommand{\maketitle}{
  {
    \pagestyle{empty}
    \fontsize{12}{14}\selectfont
    \begin{titlepage}
    \newpage
    \let\footnotesize\small
    \let\footnoterule\relax
    \let\footnote\thanks

    \baselineskip = 1.4\baselineskip %changed for b5paper
    %\baselineskip = -5\baselineskip
    \setbox0=\hbox{of the Requirements for the Degree}

    \begin{center}
    %\setcounter{page}{1}
    \null\vfil
    {\fontsize{12}{14}\selectfont \@title}
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \vfil
    Dissertation \\
    zur Erlangung des Doktorgrades \\
    der Naturwissenschaften
    %\@thedivisionof \ \@division \\
    %\@institution
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \vfil
    Vorgelegt am Fachbereich Biowissenschaften \\
    der Johann Wolfgang Goethe-Universität \\
    in Frankfurt am Main \\
    %\@degree
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \bigskip
    \centerline{}
    \bigskip
    {\fontsize{12}{14}\selectfont \lineskip .75em
    \begin{tabular}[t]{c}
    von \\ \@author
    \\ aus Mannheim
    \end{tabular}\par}
    \vskip 1.5em
    {\fontsize{12}{14}\selectfont \@date \par}
    {D30}
  \end{center}\par
  \end{titlepage}

%% Approved for the division page
  \cleardoublepage
  {\fontsize{12}{14}
  \setbox0=\hbox{vom \@department}
  \thispagestyle{empty}
  \null\vfil		% just below center of page
  %\par\vskip 6cm	% below center, not center
  \centerline{\copy0}	% approved
  \vspace{3mm}
  \centerline{der \@institution} %major
  \vspace{3mm}
  \centerline{als Dissertation angenommen} %major
  \vskip 2cm		%space to sign
  \centerline{\makebox[5cm][c]{\textbf{Dekan}}}
  \vspace{3mm}
  \centerline{\makebox[5cm][c]{\@advisor}}
  \centerline{\makebox[5cm][c]{(Goethe-Universität)}}
  \vspace{12mm}
  \centerline{\makebox[5cm][c]{\textbf{Gutachter}}}
  \vspace{3mm}
  \centerline{\makebox[5cm][c]{\@altadvisor}}
  \centerline{\makebox[5cm][c]{(Goethe-Universität)}}
  \vspace{3mm}
  \centerline{\makebox[5cm][c]{Prof. Dr. Manfred Schliwa}}
  \centerline{\makebox[5cm][c]{(Goethe-Universität)}}
  \vskip 4cm
  \centerline{\makebox[5cm][c]{\hrulefill}}
  \centerline{\makebox[5cm][c]{(Datum der Disputation)}}
  \par\vfil\null
  }
  \cleardoublepage
  }
}

% From JSS
% Added by CII
\renewcommand{\title}[1]{\def\@title{#1}}
%\newcommand{\Shorttitle}[1]{\def\@Shorttitle{#1}}
\newcommand{\Plainauthor}[1]{\def\@Plainauthor{#1}}
\newcommand{\Abstract}[1]{\def\@Abstract{#1}}
%\newcommand{\Keywords}[1]{\def\@Keywords{#1}}
%\newcommand{\Plainkeywords}[1]{\def\@Plainkeywords{#1}}
\newcommand{\Acknowledgements}[1]{\def\@Acknowledgements{#1}}
\newcommand{\Dedication}[1]{\def\@Dedication{#1}}
\newcommand{\Preface}[1]{\def\@Preface{#1}}
% End of CII add

% Flipbook stuff
\pagestyle{fancy} % turns page numbering back on
\makeatletter % To have access to \if@twoside
\fancyhead{} % clear header
\fancyfoot{} % clear footer
\fancyhfoffset[LO,RE]{\evensidemargin}
\fancyhfoffset[LE,RO]{\evensidemargin}
% display chapter and section alternately
\fancyhead[LE]{\slshape \leftmark} %section
\fancyhead[RO]{\slshape \rightmark} % chapter
% Add flipbook frames to the footer, next to page numbers
% https://github.com/nilsleiffischer/latex-flipbook
\fancyfoot[RO] {
  %\renewcommand{\labeledflipbookframe}[3]{\includegraphics{#1#2.#3}}
  \labeledflipbookframe[0][0.5]{figures/flipbook/tex/wt_}[tex][0.2]{r}{\thepage}{2em}%
}
\fancyfoot[LE] {
  %\renewcommand{\labeledflipbookframe}[3]{\includegraphics{#1#2.#3}}
  \labeledflipbookframe[0][0.5]{figures/flipbook/tex/hom_}[tex][0.2]{l}{\thepage}{2em}%
}

\makeatother