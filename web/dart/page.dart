library page;

import '../dart/serializable.dart';
import '../dart/page-element.dart';

// ~ Object Definitions .......................................................

class Page extends Object with Serializable {
  String name;
  List<PageElement> elements = new List<PageElement>();

  // ----------------------------------------------------------
  /**
   * Creates a new Page object that holds a name and a list of PageElements
   */
  Page(this.name);

  // ----------------------------------------------------------
  /**
   * Creates a new PageElement from JSON data
   */
  Page.fromJson(Map json) {
    this.name = json['name'];

    List elementList = json['elements'];

    for (int i = 0; i < elementList.length; i++) {
      elements.add(
          new PageElement(elementList[i]['content'], elementList[i]['type']));
    }

  }

}
