FROM node:22-alpine

WORKDIR /app

# json-server 1.0.0-beta.15 exige Node >= 22.12.0 (campo "engines"),
# por isso a imagem base precisa ser Node 22 ou superior.
RUN npm install json-server@1.0.0-beta.15 --silent

COPY db.json ./db.json

ENV PORT=10000
EXPOSE 10000

# O Render injeta a porta em PORT e exige bind publico em 0.0.0.0.
CMD ["sh", "-c", "exec npx json-server --watch db.json --host 0.0.0.0 --port ${PORT}"]
