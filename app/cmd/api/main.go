package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"cloud.google.com/go/bigquery"
	"github.com/JordanDeBeer/sts2-data/internal"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"

	echojwt "github.com/labstack/echo-jwt/v5"
)

var (
	projectId = os.Getenv("PROJECT_ID")
	secretKey = os.Getenv("SECRET_KEY")
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	logger()

	if secretKey == "" {
		log.Fatalf("could not start server. no secret key")
	}

	e := echo.New()

	e.Use(middleware.RequestLoggerWithConfig(getMwrlConfig()))

	r := e.Group("/auth")
	r.Use(echojwt.WithConfig(getechojwtConfig()))

	if projectId == "" {
		projectId = bigquery.DetectProjectID
	}

	bqClient, err := bigquery.NewClient(ctx, projectId)
	if err != nil {
		log.Fatalf("could not start server. no bq client. err: %v", err)
	}

	s := internal.NewServer(bqClient, []byte(secretKey))
	e.GET("/login", echo.WrapHandler(http.HandlerFunc(s.LoginHandler)))
	r.POST("/upload", s.HandleBq)

	sc := echo.StartConfig{
		Address:    ":8080",
		HideBanner: true,
		HidePort:   true,
	}
	if err := sc.Start(ctx, e); err != nil {
		e.Logger.Error("failed to start server", "error", err)
	}
}
