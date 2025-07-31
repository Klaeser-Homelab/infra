FROM nginx:alpine

# Copy nginx configuration files
COPY nginx/conf.d/ /etc/nginx/conf.d/

# Expose ports
EXPOSE 80 443

# Use the default nginx command
CMD ["nginx", "-g", "daemon off;"]