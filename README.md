# Hub-Spoke

Uma topologia de hub e spoke é uma maneira de isolar as cargas de trabalho enquanto se compartilham serviços comuns. Esses serviços incluem a identidade e segurança. O hub é uma rede virtual (VNet) no Azure que atua como ponto central de conectividade para sua rede local. Os spokes são VNets que se emparelham com o hub. Os serviços compartilhados são implantados no hub, enquanto as cargas de trabalho individuais são implantadas dentro das redes de spoke.
Essa arquitetura está se tornando cada vez mais popular à medida que as organizações buscam fazer a transição da infraestrutura local para a nuvem. Neste artigo, exploraremos os benefícios da arquitetura Azure Hub and Spoke

# Tecnologia Relacionadas
. Azure

. Terraform

ARQUIVOS RELACIONADOS
main.tf =	Criar uma topologia de rede híbrida de hub-spoke usando o Terraform no Azure

variables.tf =	Criar uma topologia de rede híbrida de hub-spoke usando o Terraform no Azure

on-prem.tf =	Criar rede virtual local com o Terraform no Azure

hub-vnet.tf =	Criar uma rede virtual de hub com o Terraform no Azure

hub-nva.tf =	Criar um dispositivo de rede virtual de hub com o Terraform no Azure

spoke1.tf =	Criar uma rede virtual spoke com o Terraform no Azure

spoke2.tf =	Criar uma rede virtual spoke com o Terraform no Azure


