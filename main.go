package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"runtime"
	"time"
)

// Build information - to be set at build time
var (
	appName       = "ping"
	version       = "0.1.0"
	commitSHA     = "dev"
	repository    = "https://github.com/sharavara/ping"
	dockerImage   = "sharavara/ping:latest"
	environment   = getEnv("ENV", "dev")
)

// Response represents the ping API response
type Response struct {
	Time        string `json:"time"`
	ServiceName string `json:"service_name"`
	Version     string `json:"version"`
	DockerImage string `json:"docker_image"`
	HostIP      string `json:"host_ip"`
	ContainerIP string `json:"container_ip"`
	Environment string `json:"environment"`
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func getHostIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		return "unknown"
	}
	defer conn.Close()
	
	localAddr := conn.LocalAddr().(*net.UDPAddr)
	return localAddr.IP.String()
}

func getContainerIP() string {
	ifaces, err := net.Interfaces()
	if err != nil {
		return "unknown"
	}
	
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp == 0 {
			continue // interface down
		}
		if iface.Flags&net.FlagLoopback != 0 {
			continue // loopback interface
		}
		
		addrs, err := iface.Addrs()
		if err != nil {
			continue
		}
		
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			
			if ip == nil || ip.IsLoopback() {
				continue
			}
			
			ip = ip.To4()
			if ip == nil {
				continue // not an ipv4 address
			}
			
			return ip.String()
		}
	}
	
	return "unknown"
}

func pingHandler(w http.ResponseWriter, r *http.Request) {
	hostIP := getHostIP()
	containerIP := getContainerIP()
	
	response := Response{
		Time:        time.Now().Format(time.RFC3339),
		ServiceName: appName,
		Version:     version,
		DockerImage: dockerImage,
		HostIP:      hostIP,
		ContainerIP: containerIP,
		Environment: environment,
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	// Print application information
	fmt.Println("Application:", appName)
	fmt.Println("Version:", version)
	fmt.Println("Commit SHA:", commitSHA)
	fmt.Println("Repository:", repository)
	fmt.Println("Docker Image:", dockerImage)
	fmt.Println("Container IP:", getContainerIP())
	fmt.Println("Host IP:", getHostIP())
	fmt.Println("CPU Architecture:", runtime.GOARCH)
	fmt.Println("Environment:", environment)
	
	// Configure HTTP server
	http.HandleFunc("/ping", pingHandler)
	
	port := getEnv("PORT", "8080")
	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}