# ---------- مرحله ۱: کلون مخزن ----------
FROM alpine/git AS source
WORKDIR /app
RUN git clone https://github.com/aghabanafshi6122/aghabanafshi.git .

# ---------- مرحله ۲: تصویر نهایی ----------
FROM node:20-alpine

# نصب پایتون + unbound + ابزارهای موردنیاز start.sh
RUN apk add --no-cache \
        python3 py3-pip bash sqlite curl \
        unbound bind-tools ca-certificates

# ساخت پوشه‌ی unbound در صورت نبودن
RUN mkdir -p /etc/unbound /var/lib/unbound /var/log/unbound

WORKDIR /app

COPY --from=source /app /app

RUN if [ -f package.json ]; then npm install --omit=dev; fi
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir --break-system-packages -r requirements.txt; fi

RUN chmod +x start.sh 2>/dev/null || true

ENV PORT=3000
EXPOSE 3000

CMD ["sh", "-c", "if [ -f start.sh ]; then bash start.sh; elif [ -f app.js ]; then node app.js; elif [ -f server.py ]; then python3 server.py; else echo 'No entrypoint found'; exit 1; fi"]
