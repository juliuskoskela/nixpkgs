{ buildGoModule
, fetchFromGitHub
, installShellFiles
, lib
, makeWrapper
, xdg-utils
}:
buildGoModule rec {
  pname = "aws-vault";
  version = "6.5.0";

  src = fetchFromGitHub {
    owner = "99designs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-PYaCbefIglzvBTeFnyz+uQnFxE61cBMWvC3RdV8rq90=";
  };

  vendorSha256 = "sha256-GTP6KqAfESrdrtLkerRLmre2tBkG4CXMcfxL/flgya0=";

  nativeBuildInputs = [ installShellFiles makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/aws-vault --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
    installShellCompletion --cmd aws-vault \
      --bash $src/contrib/completions/bash/aws-vault.bash \
      --fish $src/contrib/completions/fish/aws-vault.fish \
      --zsh $src/contrib/completions/zsh/aws-vault.zsh
  '';


  doCheck = false;

  subPackages = [ "." ];

  # set the version. see: aws-vault's Makefile
  ldflags = [
    "-X main.Version=v${version}"
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/aws-vault --version 2>&1 | grep ${version} > /dev/null
  '';

  meta = with lib; {
    description =
      "A vault for securely storing and accessing AWS credentials in development environments";
    homepage = "https://github.com/99designs/aws-vault";
    license = licenses.mit;
    maintainers = with maintainers; [ zimbatm ];
  };
}
