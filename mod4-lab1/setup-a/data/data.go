package data

type TemplateData struct {
	NumHits  int        `json:"numHits"`
	FrontEnd ServerInfo `json:"frontEnd"`
	BackEnd  ServerInfo `json:"backEnd"`
}

type ServerInfo struct {
	IP   string `json:"ip"`
	Host string `json:"host"`
}
