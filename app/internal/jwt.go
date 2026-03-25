package internal

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/solovev/steam_go"
)

// Claims represents the JWT claims, including custom and registered ones.
type Claims struct {
	SteamID string `json:"steam_id"`
	jwt.RegisteredClaims
}

// MintJWT generates a new JWT token for a given username with a secret and duration.
func MintJWT(secret []byte, steamId string) (string, error) {
	claims := Claims{
		SteamID: steamId,
		RegisteredClaims: jwt.RegisteredClaims{
			// 10 days
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 240)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "sts2-data",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secret)
}

func (s *Server) LoginHandler(w http.ResponseWriter, r *http.Request) {
	opId := steam_go.NewOpenId(r)
	switch opId.Mode() {
	case "":
		http.Redirect(w, r, opId.AuthUrl(), 301)
	case "cancel":
		w.Write([]byte("Authorization cancelled"))
	default:
		steamId, err := opId.ValidateAndGetId()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Do whatever you want with steam id
		token, err := MintJWT(s.jwtSecret, steamId)
		if err != nil {
			http.Error(w, "could not login", http.StatusUnauthorized)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"token": token,
		})
	}
}
