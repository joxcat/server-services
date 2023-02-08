FROM sharelatex/sharelatex:latest
RUN wget "https://ftp.tu-chemnitz.de/pub/tex/systems/texlive/tlnet/update-tlmgr-latest.sh"
RUN sh update-tlmgr-latest.sh
RUN tlmgr update --all
RUN tlmgr install numprint
RUN tlmgr install babel-french
RUN tlmgr install hyphen-french
RUN tlmgr install hyphenat
RUN tlmgr install lua-uni-algos

RUN tlmgr install fontspec
RUN cd /usr/share/fonts; \
    mkdir Signika && cd Signika; \
    curl -L -o Signika.zip "https://fonts.google.com/download?family=Signika"; \
    unzip Signika.zip && rm Signika.zip && cd ..; \
    mkdir Neuton && cd Neuton; \
    curl -L -o Neuton.zip "https://fonts.google.com/download?family=Neuton"; \
    unzip Neuton.zip && rm Neuton.zip && cd ..; \
    curl -L -o Iosevka.tar.gz "https://github.com/joxcat/Iosevka-custom-conf/releases/download/v1.2.0/iosevka.tar.gz"; \
    tar -xvzf Iosevka.tar.gz && rm Iosevka.tar.gz \
    fc-cache -f -v
RUN tlmgr install titlesec
RUN tlmgr install microtype

RUN tlmgr install minted fvextra etoolbox fancyvrb upquote lineno catchfile xstring framed float xcolor
RUN apt-get update && apt-get install -y python-pygments
RUN echo 'shell_escape = t' >> /usr/local/texlive/2022/texmf.cnf
RUN apt-get clean
RUN tlmgr install todonotes
RUN tlmgr install setspace
RUN tlmgr install glossaries glossaries-french mfirstuc textcase xfor datatool tracklang
RUN tlmgr install lastpage
RUN tlmgr install glossaries-extra
RUN tlmgr install footmisc
RUN tlmgr install csquotes
RUN tlmgr install outlines
RUN tlmgr install adjustbox
RUN tlmgr install collectbox
