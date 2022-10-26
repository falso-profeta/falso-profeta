{ pkgs ? import <nixpkgs> {} }:
let
  tools = with pkgs; [
    sassc
    jq
  ];
  elmInputs = with pkgs.elmPackages; [
    elm
    elm-test
    elm-live
    elm-xref
    elm-json
    elm-review
    elm-format
    elm-upgrade
    elm-coverage
    elm-language-server
    elm-optimize-level-2
  ];
  pythonInputs = with pkgs.python310Packages; [
    black
    invoke
    watchdog
    ipython
  ];
  pythonLibs = with pkgs.python310Packages; [
    toolz
    pyyaml
    rich
    typer
    aiohttp
  ];
in
pkgs.mkShell {
  packages = elmInputs ++ pythonInputs ++ tools;
  buildInputs = pythonLibs;
  PORT = 3000;
}