{ lib
, buildPythonPackage
, fetchFromGitHub
, six
, pathlib
, pytest
, mock
, parameterized
, isPy27
, isPy35
}:

buildPythonPackage rec {
  pname = "aws-lambda-builders";
  version = "1.11.0";

  # No tests available in PyPI tarball
  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "aws-lambda-builders";
    rev = "v${version}";
    sha256 = "sha256-3zlEpPo35K9R3uyUUsvsCx45E93Ih9VVhdRhNwIvZ7k=";
  };

  # Package is not compatible with Python 3.5
  disabled = isPy35;

  propagatedBuildInputs = [
    six
  ] ++ lib.optionals isPy27 [ pathlib ];

  checkInputs = [
    pytest
    mock
    parameterized
  ];

  checkPhase = ''
    export PATH=$out/bin:$PATH
    pytest tests/functional -k 'not can_invoke_pip'
  '';

  meta = with lib; {
    homepage = "https://github.com/awslabs/aws-lambda-builders";
    description = "A tool to compile, build and package AWS Lambda functions";
    longDescription = ''
      Lambda Builders is a Python library to compile, build and package
      AWS Lambda functions for several runtimes & frameworks.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ dhkl ];
  };
}
