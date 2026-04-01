package main

import (
	"log/slog"
	"os"
	"runtime/debug"

	"github.com/JordanDeBeer/sts2-data/internal"
)

func logger() {
	opts := &slog.HandlerOptions{
		ReplaceAttr: func(groups []string, a slog.Attr) slog.Attr {
			// If the key is 'msg' and the value is empty, return an empty Attr to drop it
			if a.Key == slog.MessageKey {
				return slog.Attr{Key: "message", Value: a.Value}
			}
			if a.Key == slog.LevelKey {
				return slog.Attr{Key: "severity", Value: a.Value}
			}
			return a
		},
	}
	logger := slog.New(internal.NewHandler(slog.NewJSONHandler(os.Stdout, opts)))
	info, _ := debug.ReadBuildInfo()
	hostname, _ := os.Hostname()
	logger = logger.With(
		slog.Group("debug",
			slog.String("GoVersion", info.GoVersion),
			slog.String("Hostname", hostname),
			slog.Int("pid", os.Getpid()),
		),
	)
	slog.SetDefault(logger)
}
