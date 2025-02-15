FROM fluent/fluent-bit:latest

# Install a minimal shell/tools
# RUN apk add --no-cache bash coreutils

# Create or ensure /fluent-bit/out exists and adjust permissions
RUN mkdir -p /fluent-bit/out && chmod 777 /fluent-bit/out

# (Optional) revert to non-root user if desired
USER fluentbit

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]