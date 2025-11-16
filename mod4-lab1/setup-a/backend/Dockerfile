FROM golang:1.24

WORKDIR /app

# copy code
COPY backend/ backend/
COPY helpers/ helpers/
COPY data/  data/

COPY go.mod go.sum ./

# change to backend directory
WORKDIR /app/backend

RUN go build -o app .

CMD ["./app"]
