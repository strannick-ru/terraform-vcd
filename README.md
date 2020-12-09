# Terraform

Пример использования Terraform совместно с VMWare Cloud Director.

Для работы склонируйте себе проект и заполните vcd.tfvars
И запустите следующие команды:

```
terraform init
terraform plan -var-file=vcd.tfvars
terraform apply -var-file=vcd.tfvars
```

Будет создана маршрутизируемая сеть организации ApplicaNet, vApp Applica и в ней виртуальная машина vm1
На виртуальной машине создаются пользователи и прописываются ssh-ключи.
Пользователю root прописывается дефолтный пароль.

Также создаются SNAT для всей сети и DNAT для 22 порта.