FROM node:18-alpine

USER root

RUN apk add --no-cache git
RUN apk add --no-cache python3 py3-pip make g++
# needed for pdfjs-dist
RUN apk add --no-cache build-base cairo-dev pango-dev

# Install Chromium
RUN apk add --no-cache chromium

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# You can install a specific version like: flowise@1.0.0
RUN npm install -g flowise@1.5.0

RUN apk add --no-cache poppler-utils tesseract-ocr
RUN npm install -g tesseract.js@latest pdf-parse textract 

WORKDIR /data

CMD "flowise"
