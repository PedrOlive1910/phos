# phos

Personalização do LordOS baseada em Debian 13, com nome phos e integração do Google Chrome na ISO amd64.

## O que está pronto

- Nome phos nos textos da interface, login, tela Sobre, instalador e menus de inicialização.
- Identificação phos em /etc/os-release, aplicada durante a geração da ISO.
- Saída da ISO: phos-live-0.8.8.7-amd64.iso.
- Google Chrome Stable instalado pelo APT no sistema da ISO amd64. O instalador copia esse sistema para o disco, incluindo o navegador e seu atalho oficial.
- Repositório Google configurado com HTTPS, Signed-By e verificação da impressão digital da chave primária.
- Repositório de atualizações LordOS desativado nesta cópia para não sobrescrever a personalização. Atualizações Debian e Google permanecem disponíveis. O phos ainda não possui servidor de atualizações próprio.
- Interface compilada e manifesto de código regenerado como compilação de desenvolvimento sem assinatura.

## Construir a ISO

Para gerar pelo GitHub, use **Actions → Gerar ISO PHOS → Run workflow**. Instruções em [docs/PHOS-GITHUB.md](docs/PHOS-GITHUB.md). O workflow compila em Debian 13 e disponibiliza a ISO e o checksum como artefato, sem publicar release.

É necessário Debian 13 e as dependências de compilação descritas em docs/VM-SETUP.md e docs/ISO.md. A extração do ZIP precisa preservar ou restaurar os modos executáveis dos scripts antes do uso no Linux.

```sh
npm ci
npm run build
make -C server -j"$(nproc)"
make -C server test
# Prepare também os auxiliares opcionais exigidos por mkdeb.sh (inclusive TTS),
# seguindo docs/VM-SETUP.md, docs/VOICE.md e docs/ISO.md.
sh tools/iso/mkdeb-rclone.sh /var/tmp/phos-iso/out amd64
sudo sh tools/iso/build.sh /var/tmp/phos-iso
```

O build precisa de rede para baixar a base Debian e o Chrome. A versão do Chrome será a Stable disponível no repositório no momento do build; ela é registrada na saída da instalação. O executável do Chrome não está neste ZIP: será instalado dentro da imagem Linux pelo script tools/iso/phos-customize.sh.

A integração do Chrome é para amd64. Em arm64, o script mantém os navegadores existentes e avisa que não incluiu Chrome. O navegador padrão não é alterado.

## Validação desta alteração

- Build de três temas, app-host e seis aplicativos isolados: aprovado.
- Três arquivos de testes JavaScript: aprovados.
- Sintaxe shell dos scripts da ISO e personalização: aprovada.
- Testes com chroot simulado: integração amd64, fallback arm64, rejeição de chave inesperada e rejeição da raiz do host aprovados. Esses testes não instalam o navegador real.
- Não executados: compilação C, instalação real do Chrome, geração da ISO e teste de inicialização em VM. O ambiente de alteração é Windows sem WSL.

## Origem e limites da personalização

Base: LordOS 0.8.8.7, de iPERFEX e colaboradores. Veja README-UPSTREAM.md, LICENSE e THIRD_PARTY.md. Avisos de autoria e licenças foram preservados.

Identificadores técnicos como lord-server, pacote Debian lordos, APIs @lordos, caminhos internos, temas GTK e diretório EFI permanecem por compatibilidade. Documentação histórica, endereço do projeto de origem e papéis de parede herdados continuam presentes; o logotipo fornecido foi aplicado à interface, e o símbolo PHOS substitui a coroa na inicialização e nos ícones. O mascote da interface agora é um panda. Os papéis de parede antigos com Lumo foram retirados do seletor; arquivos históricos continuam no código-fonte. Antes de distribuir publicamente, substitua os materiais de marca que exijam autorização e revise as condições de distribuição do Chrome.

Chaves do projeto de origem não são chaves do phos. Este pacote é uma versão de desenvolvimento sem assinatura; não representa uma publicação oficial do LordOS. Uma distribuição independente exige infraestrutura e chaves de lançamento próprias.

Referência Google para a chave de assinatura: https://www.google.com/linuxrepositories/

## Identidade visual PHOS

A nova imagem fornecida, com o panda ao lado do nome PHOS, está preservada sem alterações em assets/brand/phos-original.png e aparece na tela de login e nos componentes de identificação. Um fundo branco garante contraste para as letras escuras. Os ícones pequenos, GRUB e Plymouth usam o avatar do mascote panda já incluído no projeto. O vetor verde anterior permanece apenas como arquivo histórico, sem uso pelo gerador da marca.

Regenerar ícones: `npm run build:brand`. Depois executar `npm run build` para atualizar os bundles e o manifesto. As versões PNG necessárias já estão incluídas.

## Mascote panda

Panda com detalhes verdes criado com a ferramenta integrada de geração de imagens. Seis poses e dois avatares substituem o mascote anterior na interface e no instalador. Regenerar os PNGs: `npm run build:mascot`; recompilar a interface em seguida. A folha original e o prompt ficam em assets/brand/phos-panda-sheet.png e assets/brand/phos-panda-prompt.txt. Os nomes de API Lumo/lumoSource são mantidos por compatibilidade. O papel de parede inicial passa a Infinite Galaxy para não exibir o mascote antigo.
