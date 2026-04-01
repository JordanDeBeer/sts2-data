package internal

import (
	"context"
	"log/slog"
	"sync"
)

type key struct{}

var attrsKey key

type contextAttrs struct {
	mu    sync.RWMutex
	attrs []slog.Attr
}

type Handler struct {
	slog.Handler
}

func NewHandler(baseHandler slog.Handler) *Handler {
	return &Handler{baseHandler}
}

func (h *Handler) Handle(ctx context.Context, r slog.Record) error {
	ca, ok := ctx.Value(attrsKey).(*contextAttrs)
	if !ok {
		return h.Handler.Handle(ctx, r)
	}
	ca.mu.RLock()
	r.AddAttrs(ca.attrs...)
	ca.mu.RUnlock()
	return h.Handler.Handle(ctx, r)
}

func (h *Handler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return &Handler{h.Handler.WithAttrs(attrs)}
}

func (h *Handler) WithGroup(name string) slog.Handler {
	return &Handler{h.Handler.WithGroup(name)}
}

func WithLogging(ctx context.Context) context.Context {
	if _, ok := ctx.Value(attrsKey).(*contextAttrs); ok {
		return ctx
	}
	return context.WithValue(ctx, attrsKey, &contextAttrs{})
}

func Add(ctx context.Context, attr ...slog.Attr) {
	ca, ok := ctx.Value(attrsKey).(*contextAttrs)
	if !ok {
		ca = &contextAttrs{}
		ctx = context.WithValue(ctx, attrsKey, ca)
	}
	ca.mu.Lock()
	ca.attrs = append(ca.attrs, attr...)
	ca.mu.Unlock()
}
