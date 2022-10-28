from invoke import task


@task
def build(ctx, compress=False):
    """
    Build and maybe compress assets.
    """

    if compress:
        ctx.run("sassc scss/main.scss | cleancss -O3 > static/main.css")
        ctx.run("elm make src/Main.elm --optimize --output=static/app.js")
        ctx.run(
            "uglifyjs static/app.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output static/app.js"
        )
        ctx.run("python data/extract.py | jq -c > static/data.json")
    else:
        ctx.run("sassc scss/main.scss static/main.css")
        ctx.run("elm make src/Main.elm --output=static/app.js")
        ctx.run("python data/extract.py > static/data.json")

    ctx.run("cp main.html index.html")


@task
def dev(ctx, hot_reload=False):
    """
    Starts development server
    """
    flags = []
    if hot_reload:
        flags.append("-H")
    flags = " ".join(flags)
    ctx.run(
        f"elm-live src/Main.elm {flags} -vu -s main.html -- --output static/main.js"
    )


@task(build)
def prod(ctx):
    """
    Makes a build and serves a production-like version of the site.

    Live reload and hot reload are disabled and assets are compressed.
    """
    ctx.run("python -m http.server 8001")


@task
def publish(ctx, message=None):
    """
    Publish site in github.
    """
    ctx.run("black .")
    ctx.run("elm-format src/ --yes")
    build(ctx, compress=True)

    ctx.run("git add .")
    ctx.run("git status", pty=True)
    if not message:
        print("-" * 40)
        message = input("Commit message: ")
    ctx.run(f'git commit -m "{message}"')
    ctx.run("git push")


@task(build)
def check(ctx):
    """
    Run sanity checks.
    """
    ctx.run("python data/check_links.py")
