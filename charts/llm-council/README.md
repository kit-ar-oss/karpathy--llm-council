## LLM Council Helm Chart

Deploys:
- `frontend` (Nginx serving the UI, proxies `/api` to the backend service)
- `backend` (FastAPI on port 8001)

### Install

```bash
helm install llm-council ./charts/llm-council
```

### Images

Set your image repositories/tags (defaults are placeholders):

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set backend.image.repository="example.azurecr.io/example/llm-council/backend" \
  --set backend.image.tag="latest" \
  --set frontend.image.repository="example.azurecr.io/example/llm-council/frontend" \
  --set frontend.image.tag="latest"
```

### OpenRouter API Key

Provide an existing Secret:

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set backend.env.existingSecret="llm-council-secrets"
```

Or let the chart create a Secret (not recommended for GitOps unless encrypted):

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set backend.env.openrouterApiKey="sk-or-v1-..."
```

### Exposing the UI

#### Ingress (networking.k8s.io/v1)

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="llm-council.example.com"
```

#### Gateway API (gateway.networking.k8s.io/v1)

Create an `HTTPRoute` attached to an existing Gateway:

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set gateway.enabled=true \
  --set gateway.httpRoute.parentRefs[0].name="my-gateway" \
  --set gateway.httpRoute.hostnames[0]="llm-council.example.com"
```

Or have the chart create a Gateway (cluster must support this and you must set a GatewayClass):

```bash
helm upgrade --install llm-council ./charts/llm-council \
  --set gateway.enabled=true \
  --set gateway.createGateway=true \
  --set gateway.gatewayClassName="my-gateway-class" \
  --set gateway.httpRoute.hostnames[0]="llm-council.example.com"
```
