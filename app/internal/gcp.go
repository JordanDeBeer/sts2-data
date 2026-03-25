package internal

import (
	"context"
	"time"

	"cloud.google.com/go/bigquery"
)

type Row struct {
	SteamId string    `bigquery:"steamid"`
	Run     time.Time `bigquery:"run"`
	Data    string    `bigquery:"data"`
}

func insertRows(ctx context.Context, client bigquery.Client, rows []*Row) error {
	inserter := client.Dataset("slaythespire2").Table("runs").Inserter()
	if err := inserter.Put(ctx, rows); err != nil {
		return err // Check for bigquery.PutMultiError
	}
	return nil
}
