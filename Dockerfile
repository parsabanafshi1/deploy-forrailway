# ---------- مرحله ۱: کلون مخزن ----------
FROM alpine/git AS source
WORKDIR /app
RUN git clone https://github.com/aghabanafshi6122/aghabanafshi.git .

# ---------- مرحله ۲: تصویر نهایی ----------
FROM node:20-alpine

# نصب پایتون و ابزارهای موردنیاز
RUN apk add --no-cache python3 py3-pip bash sqlite curl

WORKDIR /app

# کپی سورس
COPY --from=source /app /app

# نصب وابستگی‌های Node.js در صورت وجود
RUN if [ -f package.json ]; then npm install --omit=dev; fi

# نصب وابستگی‌های پایتون در صورت وجود
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir --break-system-packages -r requirements.txt; fi

# اجرایی کردن اسکریپت‌ها
RUN chmod +x start.sh 2>/dev/null || true

# Railway پورت رو از متغیر PORT می‌خونه
ENV PORT=3000
EXPOSE 3000

# اجرای پروژه (اولویت: start.sh → app.js → server.py)
CMD ["sh", "-c", "if [ -f start.sh ]; then bash start.sh; elif [ -f app.js ]; then node app.js; elif [ -f server.py ]; then python3 server.py; else echo 'No entrypoint found'; exit 1; fi"]
