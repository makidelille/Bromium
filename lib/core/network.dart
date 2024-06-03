import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

const DNS_SERVER = "api.buss.lol";

class DnsError extends Error {
  final int statusCode;

  DnsError({required this.statusCode});
}

class BussError extends Error {
  final int statusCode;

  BussError({required this.statusCode});
}

class Network {
  static Future<String> resolveDNS(Uri url) async {
    var dnsBox = await Hive.openBox("dnsBox");
    if (url.scheme != "buss") throw DnsError(statusCode: -1);
    List<String> host = url.host.split('.');
    String clientUrl = "https://$DNS_SERVER/domain/${host.first}/${host.last}";

    String? cache = dnsBox.get(clientUrl);
    if (cache != null) {
      return cache;
    }
    http.Response dnsResponse = await http.get(Uri.parse(clientUrl));
    if (dnsResponse.statusCode != 200) {
      throw DnsError(statusCode: dnsResponse.statusCode);
    }

    try {
      dynamic decoded = jsonDecode(dnsResponse.body);
      String host = decoded["ip"];
      dnsBox.put(clientUrl, host);
      return host;
    } catch (err) {
      throw DnsError(statusCode: 503);
    }
  }

  static Future<String> fetch(Uri url) async {
    var htmlBox = await Hive.openBox("htmlBox");
    String? cache = htmlBox.get(url.toString());
    if (cache != null) {
      return cache;
    }
    String dnsUrl = await resolveDNS(url);

    final file = url.path.split('/').last;
    if (dnsUrl.startsWith("https://github.com")) {
      List<String> parts = dnsUrl.split('/');
      dnsUrl =
          "https://raw.githubusercontent.com/${parts.elementAt(3)}/${parts.elementAt(4)}/main/";
    }

    http.Response fetchResponse = await http.get(Uri.parse("$dnsUrl/$file"));

    if (fetchResponse.statusCode != 200) {
      throw BussError(statusCode: fetchResponse.statusCode);
    }

    htmlBox.put(url.toString(), fetchResponse.body);
    return fetchResponse.body;
  }
}
