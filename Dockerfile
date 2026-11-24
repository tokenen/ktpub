FROM alpine:latest

# ca-certificates + python3 是用来起假健康服务的
RUN apk add --no-cache ca-certificates python3

WORKDIR /app

COPY kt .

RUN chmod +x kt

# 准备一个健康检查页面
RUN mkdir -p /tmp/www && echo "ok" > /tmp/www/health && echo "kt worker running" > /tmp/www/index.html

# Orkestr 会注入 PORT，没有就默认 8080
ENV PORT=8080
EXPOSE 8080

# 关键改动在这里：
# 1. 先在后台起一个 python http 服务，占用 $PORT
# 2. 再用 exec 跑你的 kt，让 kt 成为主进程
CMD sh -c "python3 -m http.server ${PORT:-8080} --directory /tmp/www --bind 0.0.0.0 > /tmp/http.log 2>&1 & exec ./kt"
