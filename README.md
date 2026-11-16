# RoboShop on AWS: Terraform + Ansible

Terraform builds the AWS infrastructure (VPC, one EC2 host per component,
Aurora MySQL, ElastiCache Redis, Route 53 private zone, a Cloudflare record for
the public frontend). Ansible installs and configures each RoboShop component
on its host. Jenkins runs both.

```
terraform/     AWS + Cloudflare infrastructure
roboshop.yml   main playbook (data tier -> app tier -> frontend)
roles/         one role per component, plus common
inventory/     aws_ec2 dynamic inventory (and a static example)
group_vars/    shared settings; secrets in group_vars/all/vault.yml (encrypted)
extras/        unrelated roles kept for reference, not deployed
examples/      Ansible basics playbooks (learning material)
```

## Components

| Component | Runs on | Notes |
|---|---|---|
| frontend | EC2, nginx | Public (80/443). Proxies `/api/*` to the services |
| catalogue, user, cart | EC2, Node.js 20 | |
| shipping | EC2, Java 11 | Jar built once on the controller |
| payment | EC2, Python + uwsgi | |
| mongodb | EC2, MongoDB 7.0 | Seeded with catalogue and users |
| rabbitmq | EC2, RabbitMQ | |
| mysql | Aurora MySQL 8 (Terraform) | `mysql` role is a self-hosted alternative |
| redis | ElastiCache Redis 7 (Terraform) | `redis` role is a self-hosted alternative |

All hosts run Rocky Linux 9 (official AMI, user `rocky`). Services run as the
unprivileged `roboshop` user from `/opt/roboshop/<component>`.

## Prerequisites

- Terraform >= 1.10, ansible-core >= 2.15, Python `boto3`/`botocore`, Maven + JDK 11
- `ansible-galaxy collection install -r requirements.yml`
- AWS credentials, and a Secrets Manager secret `rdscreds` with
  `{"SSH_USER": "...", "SSH_PASS": "..."}` (Aurora master user)
- `CLOUDFLARE_API_TOKEN` in the environment (never in code)
- `admin_cidrs` in `terraform/terraform.tfvars` set to the IPs allowed to SSH
  (your Jenkins agent and workstation). Plan fails until you set it.
- `group_vars/all/vault.yml`: copy `examples/vault.yml.example`, fill it in,
  then `ansible-vault encrypt group_vars/all/vault.yml`

## Run it by hand

```bash
export CLOUDFLARE_API_TOKEN=...
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply tfplan

# SSH key for Ansible (git-ignored)
(umask 077; terraform -chdir=terraform output -raw private_key > roboshop.pem)

mvn -B -f roles/shipping/files/pom.xml clean package -DskipTests
ansible-playbook roboshop.yml --ask-vault-pass
ansible-playbook roboshop.yml --ask-vault-pass --limit cart   # one component
```

On a single host without a controller:

```bash
ansible-pull -U https://github.com/moks-tech/ansible.git -i localhost, \
  roboshop.yml -e roboshop_component=cart --ask-vault-pass
```

## Jenkins

`Jenkinsfile` takes an `ACTION` parameter:

- **Plan**: lint + `terraform plan`
- **CreateInfra**: plan, manual approval, apply, build shipping, run Ansible
- **DeployApp**: build shipping and run Ansible against the existing hosts
- **DeleteInfra**: destroy plan, manual approval, apply

Credentials it needs are listed at the top of the file.

## Self-hosted MySQL / Redis

To run MySQL or Redis on EC2 instead of Aurora/ElastiCache: add `mysql` /
`redis` to `COMPONENT`, remove the matching managed resource and its Route 53
CNAME, and set `roboshop_mysql_mode: self_hosted` for MySQL.

## Linting

CI (`.github/workflows/lint.yml`) runs yamllint, ansible-lint,
`terraform fmt/validate`, tflint and gitleaks. Run the same locally with
`pip install pre-commit && pre-commit install`.
