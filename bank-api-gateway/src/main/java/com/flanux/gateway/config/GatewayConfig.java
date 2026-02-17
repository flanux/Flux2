package com.flanux.gateway.config;

import org.springframework.context.annotation.Configuration;

// Gateway routes are configured in application.yml
// AuthenticationFilter is applied per-route via filter chain
@Configuration
public class GatewayConfig {
    // Routes defined in application.yml
    // Authentication handled by AuthenticationFilter applied globally but with RouteValidator whitelist
}
