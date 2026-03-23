package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"log/slog"
	"mime/multipart"
	"net/http"
	"os"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/storage"
	"github.com/cespare/xxhash/v2"
	"golang.org/x/sync/errgroup"
)

var (
	bucketName = os.Getenv("BUCKET_NAME")
)

type server struct {
	gcs *storage.Client
	bq  *bigquery.Client
}

func (s *server) batchUploadGcs(ctx context.Context, files []*multipart.FileHeader) ([]string, error) {
	var filesUploaded []string

	g, ctx := errgroup.WithContext(ctx)
	g.SetLimit(10)

	filesCh := make(chan string, len(files))
	for _, fileHeader := range files {
		g.Go(func() error {
			file, err := fileHeader.Open()
			if err != nil {
				return err
			}
			defer file.Close()

			data, err := io.ReadAll(file)
			if err != nil {
				return err
			}

			h := xxhash.Sum64(data)
			hashName := fmt.Sprintf("%016x.run", h) // 16-char hex string

			obj := s.gcs.Bucket(bucketName).Object(hashName)
			sw := obj.NewWriter(ctx)
			if _, err := sw.Write(data); err != nil {
				return err
			}
			if err := sw.Close(); err != nil {
				return err
			}
			filesCh <- fmt.Sprintf("gs://%s/%s", obj.BucketName(), obj.ObjectName())
			return nil
		})
	}
	err := g.Wait()
	close(filesCh)
	if err != nil {
		return filesUploaded, fmt.Errorf("error writing files. err: %w", err)
	}
	for f := range filesCh {
		filesUploaded = append(filesUploaded, f)
	}
	return filesUploaded, nil
}

func (s *server) handleFileUpload(w http.ResponseWriter, r *http.Request) {
	// Limit to 32MB max memory for form parsing
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		http.Error(w, "Failed to parse multipart form", http.StatusBadRequest)
		return
	}

	files := r.MultipartForm.File["files"]
	if len(files) == 0 {
		http.Error(w, "No files uploaded", http.StatusBadRequest)
		return
	}

	ctx := r.Context()
	uploadedFiles, err := s.batchUploadGcs(ctx, files)
	if err != nil {
		http.Error(w, "failed to upload", http.StatusInternalServerError)
	}
	gcsRef := bigquery.NewGCSReference(uploadedFiles...)
	gcsRef.SourceFormat = bigquery.JSON
	gcsRef.AutoDetect = true

	loader := s.bq.Dataset("slaythespire2").Table("runs-raw").LoaderFrom(gcsRef)
	job, err := loader.Run(ctx)
	if err != nil {
		slog.ErrorContext(ctx, "bq job", slog.Any("err", err))
		http.Error(w, "could not start bq job", http.StatusInternalServerError)
		return
	}
	slog.InfoContext(ctx, "started job", "job_id", job.ID())

	w.WriteHeader(http.StatusAccepted)
	fmt.Fprintf(w, "Successfully uploaded %d files", len(files))
}

func main() {
	handler := slog.NewJSONHandler(os.Stdout, nil)
	logger := slog.New(handler)
	slog.SetDefault(logger)

	if bucketName == "" {
		bucketName = "sts2-runs"
	}
	ctx := context.Background()

	gcsClient, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalf("could not start server. no gcs client. err: %v", err)
	}
	defer gcsClient.Close()

	bqClient, err := bigquery.NewClient(ctx, bigquery.DetectProjectID)
	if err != nil {
		log.Fatalf("could not start server. no bq client. err: %v", err)
	}
	defer bqClient.Close()

	s := &server{
		gcs: gcsClient,
		bq:  bqClient,
	}

	http.HandleFunc("POST /upload", s.handleFileUpload)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("failed to start server: %v", err)
	}
}
