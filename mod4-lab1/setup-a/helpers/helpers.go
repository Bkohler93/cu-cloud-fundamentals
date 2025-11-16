package helpers

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"
)

func GetLocalIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()
	fullAddr := conn.LocalAddr().String()
	ip := strings.Split(fullAddr, ":")[0]
	return ip
}

func InternalServerError(w http.ResponseWriter, errString string) {
	log.Println(errString)
	w.WriteHeader(http.StatusInternalServerError)
	fmt.Fprint(w, errString)
}
