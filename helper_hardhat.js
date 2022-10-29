const networkConfig = {
  31337: {
    Registry_Address: "0x02777053d6764996e594c3E88AF1D58D5363a2e6",
    Registrar_Address: "0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d",
    LINK_Token: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
    Impersonate: "0xc58Bb74606b73c5043B75d7Aa25ebe1D5D4E7c72",
    Comet: "0xc3d688B66703497DAA19211EEdff47f25384cdc3",
  },

  80001: {
    name: "polygon mumbai",
    Registry_Address: "0x02777053d6764996e594c3E88AF1D58D5363a2e6",
    Registrar_Address: "0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d",
    LINK_Token: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
  },

  5: {
    name: "goerli",
    Comet: "0x3EE77595A8459e93C2888b13aDB354017B198188",
  },
};

module.exports = {
  networkConfig,
};
