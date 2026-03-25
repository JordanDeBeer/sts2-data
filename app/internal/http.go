package internal

import (
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"cloud.google.com/go/bigquery"
	"github.com/labstack/echo/v5"
)

type Server struct {
	bq        *bigquery.Client
	jwtSecret []byte
}

func NewServer(bq *bigquery.Client, jwtSecret []byte) *Server {
	return &Server{
		bq:        bq,
		jwtSecret: jwtSecret,
	}
}

func (s *Server) HandleBq(c *echo.Context) error {
	// Limit to 32MB max memory for form parsing
	if err := c.Request().ParseMultipartForm(32 << 20); err != nil {
		return c.NoContent(http.StatusRequestEntityTooLarge)
	}

	form, err := c.MultipartForm()
	if err != nil {
		return err
	}
	files := form.File["files"]

	var rows []*Row
	for _, fileHeader := range files {
		file, err := fileHeader.Open()
		if err != nil {
			file.Close()
			Add(c.Request().Context(), slog.Group("error", slog.String("message", fmt.Sprintf("could not open file. err: %s", err))))
			return echo.NewHTTPError(http.StatusBadRequest, "")
		}

		data, err := io.ReadAll(file)
		if err != nil {
			Add(c.Request().Context(), slog.Group("error", slog.String("message", fmt.Sprintf("could not open file. err: %s", err))))
			return echo.NewHTTPError(http.StatusBadRequest, "")
		}
		file.Close()

		steamId := c.Get("steamId").(string)
		runStr := strings.TrimSuffix(fileHeader.Filename, filepath.Ext(fileHeader.Filename))
		runInt64, err := strconv.ParseInt(runStr, 10, 64)
		if err != nil {
			Add(c.Request().Context(), slog.Group("error", slog.String("message", fmt.Sprintf("could not parse run filename. err: %s", err))))
			return echo.NewHTTPError(http.StatusBadRequest, "")
		}
		run := time.Unix(runInt64, 0)

		row := &Row{
			SteamId: steamId,
			Run:     run,
			Data:    string(data),
		}
		rows = append(rows, row)
	}
	err = insertRows(c.Request().Context(), *s.bq, rows)
	if err != nil {
		Add(c.Request().Context(), slog.Group("error", slog.String("message", fmt.Sprintf("could not insert rows. err: %s", err))))
		return echo.NewHTTPError(http.StatusInternalServerError, "")
	}

	Add(c.Request().Context(), slog.Int("uploaded_files", len(files)))
	return c.NoContent(http.StatusAccepted)
}
