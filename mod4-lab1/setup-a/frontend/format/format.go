package format

import (
	"encoding/json"
	"html/template"
	"io"

	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/data"
)

var (
	templateFilename = "./index.html"
	indexTemplate    *template.Template
)

func LoadTemplate() error {
	var err error
	indexTemplate, err = template.New("index.html").ParseFiles(templateFilename)
	return err
}

func ExecuteTemplate(wr io.Writer, d *data.TemplateData) error {
	if d == nil { //sample data if none passed in
		d = &data.TemplateData{
			NumHits: 2,
			FrontEnd: data.ServerInfo{
				IP:   "1.1.1.1",
				Host: "gcp.server1",
			},
			BackEnd: data.ServerInfo{
				IP:   "1.1.2.2",
				Host: "gcp.server4",
			},
		}
	}

	return indexTemplate.Execute(wr, *d)
}

func ReturnJson(wr io.Writer, d *data.TemplateData) error {
	return json.NewEncoder(wr).Encode(*d)
}
