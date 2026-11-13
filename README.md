# Case Técnico - Automação de Processamento de Pedidos com API
Bem-vindo(a) ao nosso case técnico! O objetivo é avaliar suas habilidades em automação de fluxos, manipulação de dados e consumo de APIs RESTful.

O ambiente de desenvolvimento é simplificado: a API do case já está publicada e pronta para uso, permitindo que você foque totalmente na lógica da integração.

## Cenário

Sua tarefa é criar um fluxo de trabalho automatizado que é acionado quando um novo pedido é pago. O fluxo deve buscar os dados do cliente em uma API, transformar essas informações em um formato específico e, por fim, salvar o resultado em uma API de destino que simula um sistema de logística.

## Pré-requisitos

- Uma instância do n8n (a interna da empresa ou local via Docker)
- Nenhuma instalação adicional é necessária para acessar a API do case

> [!IMPORTANT]
> **Não tem Docker instalado? Use a API online.**
> A API do case já está publicada em **https://case-tecnico-api.onrender.com** e não exige nenhuma instalação local.
> Docker é **opcional** e só é necessário se você quiser rodar a API na sua própria máquina — veja a seção [Alternativa: rodar a API localmente](#alternativa-rodar-a-api-localmente).

## Como Iniciar o Ambiente

**Caminho principal (sem Docker):** use a API pública, que já está no ar:

```
https://case-tecnico-api.onrender.com
```

Basta configurar seu workflow no n8n apontando para essa base. As rotas disponíveis estão detalhadas na seção [API do Case](#api-do-case).

Exemplos rápidos:

```bash
# Passo 3: buscar o cliente
curl https://case-tecnico-api.onrender.com/users/5

# Passo 5: salvar o pedido processado
curl -X POST https://case-tecnico-api.onrender.com/processed \
  -H "Content-Type: application/json" \
  -d '{"order_id":101,"customer_name":"Chelsey Dietrich","customer_email":"Lucio_Hettinger@annie.ca","delivery_address":"Skiles Walks, Suite 351, Roscoeview, 33263","processed_at":"2025-09-09T12:29:00.000Z"}'

# Verificação: listar o que foi salvo
curl https://case-tecnico-api.onrender.com/processed
```

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

3.  **Enriquecimento de Dados:** Se a validação for positiva, o fluxo deve usar o `userId` para buscar os dados completos do usuário através de uma requisição `GET` para a API: `https://case-tecnico-api.onrender.com/users/{userId}`.

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

5.  **Gravação dos Dados:** O objeto JSON transformado deve ser enviado via `POST` para a seguinte API de destino: `https://case-tecnico-api.onrender.com/processed`

## Como Testar e Verificar o Resultado

1.  **Para disparar o fluxo:** Após importar e ativar seu workflow, use uma ferramenta como `curl` ou Postman para enviar o payload de teste para a URL do seu webhook.

2.  **Para verificar se os dados foram salvos:** Acesse a API de destino em seu navegador. Os registros que você enviou estarão listados lá:
    [https://case-tecnico-api.onrender.com/processed](https://case-tecnico-api.onrender.com/processed)

## API do Case

A API está publicada em **https://case-tecnico-api.onrender.com** e é servida por um [JSON Server](https://github.com/typicode/json-server) que lê o [`db.json`](db.json) deste repositório.

### Rotas disponíveis

| Operação | Método | Endpoint |
|---|---|---|
| Buscar cliente | `GET` | `https://case-tecnico-api.onrender.com/users/{userId}` |
| Listar clientes | `GET` | `https://case-tecnico-api.onrender.com/users` |
| Salvar processado | `POST` | `https://case-tecnico-api.onrender.com/processed` |
| Consultar processados | `GET` | `https://case-tecnico-api.onrender.com/processed` |
| Listar pedidos | `GET` | `https://case-tecnico-api.onrender.com/orders` |
| Listar logs | `GET` | `https://case-tecnico-api.onrender.com/logs` |

### Observações importantes

- **Primeira chamada pode demorar cerca de 1 minuto.** A API roda no plano gratuito do Render, que suspende o serviço após 15 minutos sem tráfego. A requisição seguinte "acorda" o serviço. Se a primeira chamada der timeout, aguarde e tente novamente.
- **Os dados enviados não são permanentes.** O plano gratuito usa disco efêmero: registros gravados via `POST` são perdidos quando o serviço reinicia ou é suspenso. O objetivo do passo 5 é validar que a chamada foi feita corretamente, não garantir armazenamento.
- A API é pública e sem autenticação, como no enunciado original.

### Alternativa: rodar a API localmente

Se preferir não depender da API pública (ou se ela estiver indisponível), rode a API na sua máquina. Requer Docker e Docker Compose:

```bash
docker compose up -d api
```

Isso serve o mesmo `db.json` em `http://localhost:3000`:

| Operação | Endpoint local |
|---|---|
| Buscar cliente | `GET http://localhost:3000/users/{userId}` |
| Salvar processado | `POST http://localhost:3000/processed` |
| Consultar processados | `GET http://localhost:3000/processed` |

**Do n8n rodando em container, use `http://api:3000`** em vez de `localhost`. Fora do Docker (curl, Postman, navegador), use `http://localhost:3000`.

Nesse modo os dados gravados vão para `./database/db.json`, e não para o `db.json` da raiz — assim o arquivo original fica intacto como seed. Para zerar o estado, apague `database/db.json` e reinicie a API:

```bash
rm -f database/db.json && docker compose restart api
```

Se quiser também subir o n8n localmente, use `docker compose up -d` e acesse [http://localhost:5678](http://localhost:5678).

## O Que Entregar

Ao finalizar, por favor, exporte seu workflow como um arquivo JSON (`workflow.json`) e o submeta para avaliação.

Boa sorte!
