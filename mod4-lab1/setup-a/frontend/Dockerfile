FROM golang:1.24

WORKDIR /app

# copy dependency files
COPY go.mod go.sum ./

# copy code
COPY frontend/ frontend/
COPY helpers/ helpers/ 
COPY data/ data/

RUN go mod tidy

WORKDIR /app/frontend

RUN go build -o app .

CMD ["./app"]