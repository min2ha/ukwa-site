FROM klakegg/hugo:0.83.1-onbuild AS hugo

FROM nginx
COPY --from=hugo /target /usr/share/nginx/html
