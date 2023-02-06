# マルチステージビルド
# メリット
# ービルド環境とランタイム環境を分離することが可能で依存性を分離することができる
# ーDockerイメージをかなり小さくできる
# ー今までみたいなレイヤを同一コマンドにまとめたり、aptをクリーンする必要性が減った
# ポイント
# ー複数のFROM句を使うことでビルド環境を視覚的に分離する※asで命名できる
# ーCOPY句でasで指定したビルドステージのimageにアクセスできる
# ー最後に残るイメージは最後のFROM句環境のみ
# デプロイ用コンテナに含めるバイナリを作成するコンテナ
FROM golang:1.18.2-bullseye as deploy-builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

# ---------------------------------------------------

FROM debian:bullseye-slim as deploy

RUN apt-get update

COPY --from=deploy-builder /app/app .

CMD ["./app"]

# ---------------------------------------------------

FROM golang:1.18.2 as dev
WORKDIR /app
RUN go install github.com/cosmtrek/air@latest
CMD ["air"]