package com.flanux.gateway.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Predicate;

@Component
public class RouteValidator {

    public static final List<String> openApiEndpoints = List.of(
            "/api/auth/login",
            "/api/auth/register",
            "/api/auth/refresh",
            "/api/auth/forgot-password",
            "/api/auth/reset-password",
            "/actuator/**",
            "/fallback/**"
    );

    public Predicate<ServerHttpRequest> isSecured =
            request -> openApiEndpoints
                    .stream()
                    .noneMatch(uri -> {
                        String path = request.getURI().getPath();
                        // Simple wildcard matching
                        if (uri.endsWith("/**")) {
                            String baseUri = uri.substring(0, uri.length() - 3);
                            return path.startsWith(baseUri);
                        }
                        return path.equals(uri);
                    });
}
