# terraform-cloud-multi-environment
Provision infrastructure for multiple environments


```
curl \
  --header "Authorization: Bearer <api-key>" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data '{ "data": { "attributes": { "name": "beta1", "working-directory": "ephemerals_environments" }, "type": "workspaces" } }' \
  https://app.terraform.io/api/v2/organizations/otavio-corp/workspaces  
```

```
curl \
  --header "Authorization: Bearer <api-key>" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data '{ "data": { "attributes": { "key": "env_name", "value": "app-dev", "category":"terraform", "sensitive":false, "hcl":false }, "type": "vars" } }' \
  https://app.terraform.io/api/v2/workspaces/<workspace ID>/vars
```