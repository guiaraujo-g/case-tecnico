# Case Técnico - Automação de Processamento de Pedidos com API
Bem-vindo(a) ao nosso case técnico! O objetivo é avaliar suas habilidades em automação de fluxos, manipulação de dados e consumo de APIs RESTful.

O ambiente de desenvolvimento é simplificado e baseado em Docker, permitindo que você foque totalmente na lógica da integração.

## Cenário

Sua tarefa é criar um fluxo de trabalho automatizado que é acionado quando um novo pedido é pago. O fluxo deve buscar os dados do cliente em uma API, transformar essas informações em um formato específico e, por fim, salvar o resultado em uma API de destino que simula um sistema de logística.

## Pré-requisitos

- Docker
- Docker Compose

## Como Iniciar o Ambiente

1.  **Suba o contêiner do N8N:**
    No seu terminal, na raiz do projeto (onde o arquivo `docker-compose.yml` está localizado), execute o seguinte comando:

    ```bash
    docker-compose up -d
    ```
    Este comando irá baixar a imagem mais recente do N8N e iniciar o serviço. Não há dependências de banco de dados ou instalações customizadas.

2.  **Acesse o N8N:**
    Aguarde um momento para a inicialização. O editor do N8N estará disponível no seu navegador no seguinte endereço:
    [**http://localhost:5678**](http://localhost:5678)

## Detalhes do Fluxo de Trabalho

Seu workflow no N8N deve seguir os seguintes passos:

1.  **Gatilho (Trigger):** O fluxo deve ser iniciado por um **Webhook** que aguarda uma requisição `POST` com o seguinte payload:
    ```json
    {
      "orderId": 101,
      "userId": 5,
      "status": "paid"
    }
    ```

2.  **Validação:** O fluxo deve continuar apenas se o `status` for `"paid"`.

3.  **Enriquecimento de Dados:** Se a validação for positiva, o fluxo deve usar o `userId` para buscar os dados completos do usuário através de uma requisição `GET` para a API: `http://api:3000/users/{userId}` (do host: `http://localhost:3000/users/{userId}`).

4.  **Transformação:** Com os dados do pedido e do cliente em mãos, o fluxo deve montar um novo objeto JSON com a seguinte estrutura final:
    ```json
    {
      "order_id": 101,
      "customer_name": "Chelsey Dietrich",
      "customer_email": "Lucio_Hettinger@annie.ca",
      "delivery_address": "Skiles Walks, Suite 351, Roscoeview, 33263",
      "processed_at": "2025-09-09T12:29:00.000Z"
    }
    ```
    *Observação: O valor de `processed_at` deve ser a data e hora do momento do processamento, no formato ISO 8601.*

5.  **Gravação dos Dados:** O objeto JSON transformado deve ser enviado via `POST` para a seguinte API de destino: `http://api:3000/processed` (do host: `http://localhost:3000/processed`)

## Como Testar e Verificar o Resultado

1.  **Para disparar o fluxo:** Após importar e ativar seu workflow, use uma ferramenta como `curl` ou Postman para enviar o payload de teste para a URL do seu webhook.

2.  **Para verificar se os dados foram salvos:** Acesse a API de destino em seu navegador. Os registros que você enviou estarão listados lá:
    [http://localhost:3000/processed](http://localhost:3000/processed)

## API do Case

O `docker-compose.yml` sobe um serviço `api` que serve o `db.json` localmente, com os recursos `users`, `orders`, `processed` e `logs`, com leitura e escrita:

| Operação | Endpoint |
|---|---|
| Buscar cliente | `GET http://localhost:3000/users/{userId}` |
| Salvar processado | `POST http://localhost:3000/processed` |
| Consultar processados | `GET http://localhost:3000/processed` |
| De outro container | `http://api:3000/...` |

**Do n8n (dentro do Docker), use `http://api:3000`** em vez de `localhost`. Fora do Docker (curl, Postman, navegador), use `http://localhost:3000`.

Os dados gravados vão para `./database/db.json`, e não para o `db.json` da raiz — assim o arquivo original fica intacto como seed. Para zerar o estado, apague `database/db.json` e reinicie a API:

```bash
rm -f database/db.json && docker compose restart api
```

## O Que Entregar

Ao finalizar, por favor, exporte seu workflow como um arquivo JSON (`workflow.json`) e o submeta para avaliação.

Boa sorte!
