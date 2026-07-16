# Publicação no GitHub

## Criar repositório

```bash
git init
git branch -M main
git add .
git commit -m "Release v1.0.0"
git remote add origin https://github.com/Azevedo1996/linux-automation-toolkit.git
git push -u origin main
```

## Criar tag

```bash
git tag -a v1.0.0 -m "Primeira release"
git push origin v1.0.0
```
