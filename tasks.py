from invoke import task


@task
def build(ctx):
    ctx.run("sassc scss/main.scss static/main.css ")
    ctx.run("elm make src/App.elm --optimize --output=static/app.min.js")
    ctx.run("elm make src/App.elm --output=static/app.js")
    ctx.run('python data/extract.py > static/data.json')
    ctx.run("cp main.html index.html")


@task
def start(ctx):
    ctx.run("elm reactor")


@task(build)
def site(ctx):
    ctx.run("python -m http.server 8001")

