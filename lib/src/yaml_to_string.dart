final _unsuportedCharacters = RegExp(r'''^[\n\t ,[\]{}#&*!|<>'"%@']|^[?-]$|^[?-][ \t]|[\n:][ \t]|[ \t]\n|[\n\t ]#|[\n\t :]$''');

class YamlToString {
  const YamlToString({
    this.indent = ' ',
    this.quotes = "'",
  });

  final String indent, quotes;
  static final _divider = ': ';

  String toYamlString(node) {
    final stringBuffer = StringBuffer();
    writeYamlString(node, stringBuffer);
    return stringBuffer.toString();
  }

  /// Serializes [node] into a String and writes it to the [sink].
  void writeYamlString(node, StringSink sink) {
    _writeYamlString(node, 0, sink, true);
  }

  void _writeYamlString(
    node,
    int indentCount,
    StringSink stringSink,
    bool isTopLevel, {
    String preType,
  }) {
    if (node is Map) {
      _mapToYamlString(node, indentCount, stringSink, isTopLevel);
    } else if (node is Iterable) {
      _listToYamlString(node, indentCount, stringSink, isTopLevel);
    } else if (node is String) {
      stringSink.writeln(_escapeString(node));
    } else if (node is double) {
      stringSink.writeln("!!float $node");
    } else {
      stringSink.writeln(node);
    }
  }

  String _escapeString(String line) {
    line = line.replaceAll('"', r'\"').replaceAll('\n', r'\n');

    if (line.contains(_unsuportedCharacters)) {
      line = quotes + line + quotes;
    }

    return line;
  }

  void _mapToYamlString(
    node,
    int indentCount,
    StringSink stringSink,
    bool isTopLevel, {
    String preType,
  }) {
    if (!isTopLevel) {
      if (preType == "list") {
        stringSink.writeln();
      }
      indentCount += 2;
    }

    final keys = _sortKeys(node);
    bool b = false;

    keys.forEach((key) {
      final value = node[key];
      if (preType == "list") {
        if (b) {
          _writeIndent(indentCount, stringSink);
        } else {
          _writeIndent(0, stringSink);
          b = true;
        }
      } else {
        _writeIndent(indentCount, stringSink);
      }

      stringSink..write(key)..write(_divider);
      _writeYamlString(value, indentCount, stringSink, false, preType: "map");
    });
  }

  Iterable<String> _sortKeys(Map map) {
    final simple = <String>[], maps = <String>[], lists = <String>[], other = <String>[];

    map.forEach((key, value) {
      if (value is String) {
        simple.add(key);
      } else if (value is Map) {
        maps.add(key);
      } else if (value is Iterable) {
        lists.add(key);
      } else {
        other.add(key);
      }
    });

    return [...simple, ...maps, ...lists, ...other];
  }

  void _listToYamlString(
    Iterable node,
    int indentCount,
    StringSink stringSink,
    bool isTopLevel, {
    String preType,
  }) {
    if (!isTopLevel) {
      stringSink.writeln();
      indentCount += 2;
    }

    node.forEach((value) {
      _writeIndent(indentCount, stringSink);
      stringSink.write('- ');
      _writeYamlString(value, indentCount, stringSink, false, preType: "list");
    });
  }

  void _writeIndent(int indentCount, StringSink stringSink) => stringSink.write(indent * indentCount);
}
