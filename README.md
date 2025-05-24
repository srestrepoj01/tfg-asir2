# Arquitectura en AWS

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Mastodon](https://img.shields.io/badge/Mastodon-6364FF.svg?style=for-the-badge&logo=mastodon&logoColor=white)](https://joinmastodon.org)

Este proyecto implementa una infraestructura escalable y segura en AWS utilizando herramientas modernas de despliegue.

## Características principales

- **Infraestructura como Código (IaC)**: Despliegue reproducible con Terraform.
- **Arquitectura en AWS**:
  - **EC2**: Instancias para aplicaciones y servicios.
  - **RDS**: Base de datos gestionada (PostgreSQL).
  - **ALB**: Balanceo de carga y terminación SSL.
  - **ACM**: Gestión automática de certificados SSL/TLS.
  - **S3 + CloudFront**: Distribución de contenido estático.
  - **Alta disponibilidad**: Instancias distribuidas en múltiples zonas de disponibilidad (AZ).
  - **Seguridad reforzada**:
    - Certificados SSL/TLS gestionados por AWS Certificate Manager (ACM).
    - Firewalls (Security Groups).
    - IAM con mínimos privilegios.
  - **Monitorización**: Integración con Amazon CloudWatch para métricas y alertas.

## Diagrama de la arquitectura

<img src="esquema-de-red/srestrepoj-esquema-de-red.drawio.png" alt="Arquitectura en AWS">
