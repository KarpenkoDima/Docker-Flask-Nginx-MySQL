FROM nginx:alpine

# Copying configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create directory for static files
RUN mkdir -p /var/www/static

# Create unprivileged user
# RUN addgroup -g 1001 -S ngonxuser && \
#    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginxuser -g

# rights configuration
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/login/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d
    
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]