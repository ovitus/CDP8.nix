{ inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, self }:
  { defaultPackage.x86_64-linux =
    with import nixpkgs { system = "x86_64-linux"; };
    let 
      cdp7 = fetchFromGitHub
      { owner = "ComposersDesktop";
        repo = "CDP7";
        rev = "master";
        hash = "sha256-pRXmbhb/szlMyLTNmdfHpXXZvrGndncvMzsIE4tDf+s=";
      };
      cdp8 = fetchFromGitHub
      { owner = "ComposersDesktop";
        repo = "CDP8";
        rev = "main";
        hash = "sha256-jlotr6RPEbRjWeu5nmNSNL9k/0DF1st9UGszotN+6oY=";
      };
    in
    stdenv.mkDerivation
    { name = "CDP 8.0.1";
      buildInputs = [ clang cmake ];
      buildCommand = ''
        tar fx ${cdp7}/libaaio/libaaio-0.3.1.tar.bz2
        libaaio-0.3.1/configure --prefix $out
        make install
        mkdir $out/src
        cp -r ${cdp8}/* $out/src
        chmod -R +w $out
        ln -s $out/include/* $out/src/dev/include
        sed -i '/option(USE_LOCAL_PORTAUDIO/c\option(USE_LOCAL_PORTAUDIO OFF)' $out/src/CMakeLists.txt
        sed -i 's/#*//' $out/src/dev/externals/CMakeLists.txt
        mkdir $out/src/build
        cd $out/src/build
        cmake -DAAIOLIB=$out/lib/libaaio.so -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ..
        make
        mkdir $out/bin
        mv $out/src/NewRelease/* $out/bin
        rm -r $out/include $out/lib $out/man $out/src 
      '';
    };
  };
}
