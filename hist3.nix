let
  mkV4Network = args: args // {
    cidr = "${args.address}/${builtins.toString args.prefixLength}";
  };

in {
  networks = {
    k8s_pods = mkV4Network {
      address = "10.20.0.0";
      prefixLength = 22;
    };
    k8s_services = mkV4Network {
      address = "10.20.4.0";
      prefixLength = 22;
    };
    hist3_v4 = mkV4Network {
      address = "10.20.8.0";
      prefixLength = 22;
    };
  };
  nodes = {
    fingerbib = {
      addresses = {
        hist3_v4 = "10.20.8.1";
      };
    };
    ptolemy = {
      addresses = {
        hist3_v4 = "10.20.8.2";
      };
    };
    coloris = {
      addresses = {
        hist3_v4 = "10.20.8.3";
      };
    };
    saelli = {
      addresses = {
        hist3_v4 = "10.20.0.4";
      };
    };
  };
}
