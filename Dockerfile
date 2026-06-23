# Build Flutter Web, then serve static files with nginx.
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG ODOO_URL=http://localhost:8069
ARG ODOO_DB=dev1

RUN flutter gen-l10n && \
    flutter build web --release \
      --dart-define=ODOO_URL=${ODOO_URL} \
      --dart-define=ODOO_DB=${ODOO_DB}

FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
