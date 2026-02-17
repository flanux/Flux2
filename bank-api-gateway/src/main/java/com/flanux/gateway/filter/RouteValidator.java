package com.flanux.gateway.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;

import java.util.List;
import java.util.function.Predicate;

@Component
public class RouteValidator {

    private static final AntPathMatcher pathMatcher = new AntPathMatcher();

    public static final List<String> openApiEndpoints = List.of(
            "/api/auth/**",
            "/actuator/**",
            "/fallback/**"
    );

    public Predicate<ServerHttpRequest> isSecured =
            request -> openApiEndpoints.stream()
                    .noneMatch(pattern -> pathMatcher.match(pattern, request.getURI().getPath()));
}