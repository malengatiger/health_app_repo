class CurrencyIcons {
  static const String prefix = "currency_assets/";
  static String getCurrencyImagePath(String? assetCode) {
    switch (assetCode) {
      case 'USDC':
        return "${prefix}us.png";
        break;
      case 'ZARK':
        return "${prefix}za.png";
        break;
      case 'GBP':
        return "${prefix}gb-eng.png";
        break;
      case 'EURT':
        return "${prefix}eu.png";
        break;
      case 'ZIMDOLLAR':
        return "${prefix}zw.png";
        break;
      case 'XLM':
        return "${prefix}stellar-xlm.png";
        break;
    }
    return "${prefix}stellar-xlm.png";
  }
}
