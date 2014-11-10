library element;

import '../dart/serializable.dart';

// ~ Object Definitions .......................................................

class PageElement extends Object with Serializable {
  String content;
  String type;

  // ----------------------------------------------------------
  /**
   * Creates a new PageElement object that holds content and a type
   */
  PageElement(this.content, this.type);
}
