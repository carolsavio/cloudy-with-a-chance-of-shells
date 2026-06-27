# Cloudy with a chance of shells - AWS Vunerable lab

![Red Team](https://img.shields.io/badge/Red%20Team-Lab-cc0000?style=for-the-badge&logo=target&logoColor=white)
![Pentest](https://img.shields.io/badge/Pentest-Offensive%20Security-black?style=for-the-badge&logo=kalilinux&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

![Status](https://img.shields.io/badge/Status-Em%20desenvolvimento-yellow?style=for-the-badge)
![Licença](https://img.shields.io/badge/Licença-MIT-green?style=for-the-badge)
![Uso](https://img.shields.io/badge/Uso-Apenas%20educacional-blue?style=for-the-badge)

![Banner do projeto](/docs/images/cloudy-with-a-chances-of-shells.png)

Laboratório de pentest provisionado na AWS via Terraform, derivado do projeto [aws-resilient-web-infra](https://github.com/carolsavio/aws-resilient-web-infra). A infraestrutura é **intencionalmente vulnerável** para fins de estudo de segurança ofensiva.

> ⚠️ **AVISO LEGAL**: Este ambiente contém vulnerabilidades deliberadas. Use exclusivamente em sua própria conta AWS, nunca em produção. O autor não se responsabiliza por uso indevido.

---
## O que é este projeto?

A **PetroTask™** é uma startup fictícia que levantou 10 milhões de dólares para construir um to-do list com "IA Quântica e Blockchain". O sistema deles é um desastre de segurança — e é exatamente por isso que você foi contratado para fazer o pentest.

Este lab provisiona automaticamente na AWS:
- Uma instância EC2 com a aplicação web vulnerável (DVWA com tema PetroTask)
- Um bucket S3 com arquivos expostos publicamente
- Infraestrutura com misconfigurations reais de cloud (IAM, IMDSv1, S3)
- Alertas de custo para não ter surpresas na fatura

**Baseado no OWASP Top 10**, cobrindo vulnerabilidades web e de cloud em conjunto.

---

## ⚠️ Aviso Legal

> Este ambiente é **intencionalmente vulnerável** e deve ser usado **apenas para fins educacionais**.

- ✓ Use somente na **sua própria conta AWS**
- ✓ Siga a [Política de Testes de Penetração da AWS](https://aws.amazon.com/security/penetration-testing/)
- ✓ Execute `terraform destroy` ao finalizar - não deixe o lab no ar
- ✖ Nunca aponte ferramentas para sistemas que não são seus
- ✖ Não use este ambiente para atividades ilegais

---