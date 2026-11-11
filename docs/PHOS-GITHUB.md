# Gerar a ISO PHOS no GitHub

O workflow `.github/workflows/phos-iso.yml` gera uma ISO amd64 com Debian 13, a marca PHOS e Google Chrome. Ele roda somente quando iniciado manualmente; não publica releases.

1. Envie o conteúdo do projeto para a raiz de um repositório GitHub. Não envie apenas o ZIP: `.github`, `tools`, `server` e `package.json` precisam estar na raiz.
2. Na aba **Actions**, escolha **Gerar ISO PHOS**.
3. Clique em **Run workflow**, selecione a branch e confirme **Run workflow**. O workflow deve estar na branch padrão para o botão aparecer.
4. Aguarde os passos terminarem. Abra a execução e baixe o artefato **phos-iso-amd64-N** na seção **Artifacts**.
5. Extraia o ZIP do artefato: dentro estarão a ISO e `SHA256SUMS`. O artefato fica disponível por sete dias.

Se houver erro, baixe **phos-build-log-N** ou abra o passo que falhou. O tempo máximo configurado é de três horas; isso não é uma previsão do tempo de compilação.

O build usa um container Debian 13 privilegiado num runner descartável para montar o chroot e preparar o boot. O token do GitHub tem apenas leitura e não é persistido no checkout. Não há necessidade de secrets para esta compilação de desenvolvimento.

Dependências Debian, Chrome Stable e a imagem Debian são resolvidas durante a execução, portanto builds em datas diferentes não são idênticos. A ISO não está assinada e não foi testada em boot por este workflow. Os achados de segurança e firmware da revisão anterior ainda precisam de correção. Teste a ISO em VM antes de instalar em hardware.

O consumo de Actions e armazenamento depende do plano e da visibilidade do repositório. Consulte o uso da conta antes de executar vários builds.

Referências: https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow e https://docs.github.com/en/actions/tutorials/store-and-share-data
