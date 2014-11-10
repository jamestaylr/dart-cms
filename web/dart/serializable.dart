library json;

import 'dart:mirrors';

// ~ Object Definitions .......................................................

abstract class Serializable {

  // ----------------------------------------------------------
  /**
   * Serializes a object; allows generation of custom class definitions to JSON
   */
  Map toJson() {
    Map map = new Map();
    InstanceMirror im = reflect(this);
    ClassMirror cm = im.type;
    var decls = cm.declarations.values.where((dm) => dm is VariableMirror);
    decls.forEach((dm) {
      var key = MirrorSystem.getName(dm.simpleName);
      var val = im.getField(dm.simpleName).reflectee;
      map[key] = val;
    });

    return map;
  }

}
