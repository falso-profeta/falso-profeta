from invoke import task


@task
def build(ctx):
    ctx.run("sassc scss/main.scss static/main.css ")
    ctx.run("elm make src/AppProduction.elm --optimize --output=static/app.min.js")


@task
def start(ctx):
    ctx.run("elm reactor")


@task(build)
def site(ctx):
    ctx.run("python -m http 8000")

