# hadolint ignore=DL3006
FROM nginx AS build

COPY src/dist/browser /var/www
