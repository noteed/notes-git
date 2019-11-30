# This is a set of derivations to create Markdown files to document Git.
#
# Example build instruction:
#  nix-build site/ -A md.init

{ nixpkgs ? <nixpkgs>
}:

let
  pkgs = import nixpkgs {};
  artefacts = import ../default.nix;
in rec
{
  md.init = pkgs.substituteAll {
    src = ./init.md;
    result = artefacts.init;
    initoutput = builtins.readFile (artefacts.init + "/output.txt");
    inittree = builtins.readFile (artefacts.init + "/tree.txt");
    script = builtins.readFile ../scripts/init.sh;
  };

  md.all = pkgs.runCommand "all" {} ''
    mkdir $out
    cp ${md.init} $out/init.md
  '';

  template = ../../design-system/pandoc/default.html;
  lua-filter = ../../design-system/pandoc/tachyons.lua;

  html.init = pkgs.runCommand "init" {} ''
    ${pkgs.pandoc}/bin/pandoc \
      --from markdown \
      --to html \
      --standalone \
      --template ${template} \
      --lua-filter ${lua-filter} \
      --output $out \
      ${md.init}
  '';

  html.all = pkgs.runCommand "all" {} ''
    mkdir $out
    cp ${html.init} $out/init.html
  '';
}
