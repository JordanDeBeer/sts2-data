package main

import (
	"log/slog"
	"strings"

	"github.com/JordanDeBeer/sts2-data/internal"
	"github.com/golang-jwt/jwt/v5"
	echojwt "github.com/labstack/echo-jwt/v5"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func getechojwtConfig() echojwt.Config {
	return echojwt.Config{
		NewClaimsFunc: func(c *echo.Context) jwt.Claims {
			return new(internal.Claims)
		},
		SigningKey: []byte(secretKey),
		SuccessHandler: func(c *echo.Context) error {
			token, err := echo.ContextGet[*jwt.Token](c, "user")
			if err != nil {
				return echo.ErrUnauthorized.Wrap(err)
			}
			claims := token.Claims.(*internal.Claims)
			c.Set("steamId", claims.SteamID)
			internal.Add(c.Request().Context(), slog.String("steamId", claims.SteamID))
			return nil
		},
	}
}

func getMwrlConfig() middleware.RequestLoggerConfig {
	return middleware.RequestLoggerConfig{
		LogProtocol:     true,
		LogMethod:       true,
		LogUserAgent:    true,
		LogRemoteIP:     true,
		LogStatus:       true,
		LogReferer:      true,
		LogResponseSize: true,
		LogHeaders:      []string{"Traceparent"},
		Skipper: func(c *echo.Context) bool {
			// Skip health check endpoint
			return c.Request().URL.Path == "/health"
		},
		BeforeNextFunc: func(c *echo.Context) {
			ctx := internal.WithLogging(c.Request().Context())
			c.SetRequest(c.Request().WithContext(ctx))
		},
		LogValuesFunc: func(c *echo.Context, v middleware.RequestLoggerValues) error {
			internal.Add(c.Request().Context(), slog.Group("httpRequest",
				slog.String("protocol", v.Protocol),
				slog.String("remoteIp", v.RemoteIP),
				slog.String("requestMethod", v.Method),
				slog.Int("status", v.Status),
				slog.String("referer", v.Referer),
				slog.String("userAgent", v.UserAgent),
				slog.Int64("responseSize", v.ResponseSize),
			))

			// if we're running in Cloud Run, this should always be present.
			tph := v.Headers["Traceparent"]
			if len(tph) != 0 {
				traceparent := tph[0]
				tracespan := strings.Split(traceparent, "-")
				if len(tracespan) == 4 {
					trace := tracespan[1]
					span := tracespan[2]
					internal.Add(c.Request().Context(), slog.String("logging.googleapis.com/trace", trace), slog.String("logging.googleapis.com/spanId", span))
				}
			}
			if v.Error != nil {
				slog.Log(c.Request().Context(), slog.LevelError, "event")
				return nil
			}
			slog.Log(c.Request().Context(), slog.LevelInfo, "event")
			return nil
		},
	}
}
