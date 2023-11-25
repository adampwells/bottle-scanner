FROM nginx
RUN mkdir /bottle-tracker
COPY dist/spa /bottle-tracker
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
