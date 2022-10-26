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
    ctx.run("elm-live src/Main.elm -Hv -s main.html")


@task(build)
def site(ctx):
    ctx.run("python -m http.server 8001")



@task(build)
def publish(ctx, message="Update site"):
    ctx.run("git add .")
    ctx.run("git status", pty=True)
    ctx.run(f'git commit -m "{message}"')
    ctx.run('git push')

