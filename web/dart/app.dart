library app;

import 'dart:html';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'page.dart';
import 'page-element.dart';
import 'package:cookie/cookie.dart' as cookie;

String session = getSession(); // stores the session ID
List<Page> pages = getPagesList(); // page objects; initially from database
Page currentPage; // pointer to the current page in the pages list

// ~ Polymer Element Definitions ..............................................

// ----------------------------------------------------------
/**
 * Defines the functions for the 'nav-list' polymer element
 */
@CustomTag('nav-list')
class NavList extends PolymerElement {
  NavList.created() : super.created();
  @observable final List names = pages;

  // ----------------------------------------------------------
  /**
   * Called when the app is initally launched; redirects if the session is null
   */
  void attached() {
    if (cookie.get('session') == null) {
      window.location.assign('/');
    }
  }

  // ----------------------------------------------------------
  /**
   * Calls the page; alters the current page focus, adjusting the canvas;
   * toggles the checkboxes to reflect the selected page in the navigation
   * list
   */
  void callPage(Event event, var detail, var target) {
    Iterator<Page> iterator = pages.iterator;
    String name = target.attributes['value'];
    String id = target.attributes['id'];

    while (iterator.moveNext()) {

      if (name == iterator.current.name) {

        currentPage = iterator.current;

        clearElements();

        Iterator<PageElement> j = iterator.current.elements.iterator;
        while (j.moveNext()) {
          addElementToDisplay(j.current);

        }

      }
    }

    var a = this.shadowRoot.querySelectorAll("input");
    var b = a.iterator;
    while (b.moveNext()) {
      if (b.current.id == id) {
        b.current.checked = true;

      } else {
        b.current.checked = false;

      }
    }

  }

}

// ----------------------------------------------------------
/**
 * Defines the functions for the 'draggable-elements' polymer element
 */
@CustomTag('draggable-elements')
class DraggableElements extends PolymerElement {
  DraggableElements.created() : super.created();

  // ----------------------------------------------------------
  /**
   * Called on element load; initializes element listerners
   */
  void attached() {
    ($['title']).onDragStart.listen(dragStart);
    ($['title']).onDragOver.listen(dragOver);
    ($['title']).onDrop.listen(dragDrop);

    ($['text']).onDragStart.listen(dragStart);
    ($['text']).onDragOver.listen(dragOver);
    ($['text']).onDrop.listen(dragDrop);

    querySelector('body').onDragOver.listen(dragOver);
    querySelector('body').onDrop.listen(dragDrop);

  }

}

// ----------------------------------------------------------
/**
 * Defines the functions for the sidebar polymer element
 */
@CustomTag('sidebar-list')
class SidebarList extends PolymerElement {
  SidebarList.created() : super.created();
  @observable String value = '';
  @observable final List names = pages;

  // ----------------------------------------------------------
  /**
   * Deletes the current page; updates the database accordingly
   */
  void deletePage(Event event, var detail, var target) {
    String name = target.attributes['value'];

    bool found = false;
    Page toDelete;
    for (var page in pages) {
      if (page.name == name) {
        toDelete = page;
        break;

      }
    }

    pages.remove(toDelete);
    updateDatabase();
  }

  // ----------------------------------------------------------
  /**
   * Adds a page if the name is unique; propogates the page with a title element
   */
  void addPage(Event event, var detail, var target) {

    if (((event as KeyboardEvent).keyCode == 13) && (value != "")) {
      value = value.toLowerCase();

      Iterator<Page> iterator = pages.iterator;
      bool found = false;

      while (iterator.moveNext()) {
        if (value == iterator.current.name) {
          found = true;
        }
      }

      if (!(found)) {
        Page page = new Page(value);
        page.elements.add(new PageElement(value, "title"));
        pages.add(page);
      }

      value = '';

    }

    updateDatabase();
  }
}

// ----------------------------------------------------------
/**
 * Updates the database by sending JSON to the dataserver
 */
void updateDatabase() {

  var webSocket = new WebSocket('ws://0.0.0.0:9878/ws');

  webSocket.onOpen.listen((e) {
    webSocket.send('${session},${JSON.encode(pages)}');
  });

}

/**
 * Gets the session ID from a cookie; redirects the user if the cookie is null
 */
String getSession() {
  if (cookie.get('session') == null) {
    window.location.assign('/');
  }

  return cookie.get('session');
}

/**
 * Propagates the pages list by querying the database
 */
List<Page> getPagesList() {

  List result = toObservable([]);

  var webSocket = new WebSocket('ws://0.0.0.0:9978/ws');

  webSocket.onOpen.listen((e) {
    webSocket.send('${session}');
  });

  webSocket.onClose.listen((e) {
    window.location.assign('/');
    window.alert("Failed to connect! Please try again in a little while.");
  });

  webSocket.onMessage.listen((MessageEvent e) {
    List loadedPages = JSON.decode(e.data);

    for (int i = 0; i < loadedPages.length; i++) {
      result.add(new Page.fromJson(loadedPages[i]));
    }

    if (loadedPages.length == 0) {
      Page home = new Page('Home');
      home.elements.add(new PageElement('Add a catchy title', 'title'));
      home.elements.add(new PageElement('Tell your life story', 'text'));
      currentPage = home;

      clearElements();

      addElementToDisplay(home.elements.first);
      addElementToDisplay(home.elements.last);

      result.add(home);
    } else {
      currentPage = result.first;

      clearElements();
      Iterator<PageElement> j = result.first.elements.iterator;
      while (j.moveNext()) {
        addElementToDisplay(j.current);
      }
    }

  });

  return result;

}

// ~ Class Independent Definitions ............................................

int index;
String name;

/**
 * Called when any registered component is clicked and dragged
 */
void dragStart(MouseEvent event) {

  event.dataTransfer.effectAllowed = 'move';
  event.stopPropagation();
  name = event.target.id;
}

/**
 * Called continuously when a dragged component is over another registered
 * component
 */
void dragOver(MouseEvent event) {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';

}

/**
 * Called when a dragged component is dropped over another registered component
 */
void dragDrop(MouseEvent event) {
  event.stopPropagation();
  Element dropTarget = event.target;

  if (event.client.x > 220) {
    PageElement element = new PageElement("Add text here!", name);
    try {
      int index = int.parse(event.target.id);
      addElementIndexToDisplay(index, element);
      currentPage.elements.insert(index, element);
    } catch (FormatException) {
      addElementToDisplay(element);
      currentPage.elements.add(element);
    }

  }

}

/**
 * Clears the elements on the DOM canvas
 */
void clearElements() {
  var l = querySelector('p').children;
  var u = l.iterator;

  while (u.moveNext()) {
    u.current.remove();
  }

}

/**
 * Adds an element to the DOM canvas at a certain index
 */
void addElementIndexToDisplay(int position, PageElement element) {

  DivElement close = new DivElement()
      ..onClick.listen(deleteElement)
      ..setAttribute('class', 'close');

  TextAreaElement textarea = new TextAreaElement()
      ..value = element.content
      ..setAttribute('class', element.type)
      ..onKeyPress.listen(handler)
      ..onChange.listen(update);

  DivElement wrapper = new DivElement()
      ..children.add(textarea)
      ..children.add(close);

  var j = querySelector('p').children;

  j.insert(position, wrapper);

  var k = j.iterator;

  int count = 0;
  while (k.moveNext()) {
    k.current.setAttribute('id', '${count}');
    k.current.children.first.setAttribute('id', '${count}');
    count++;
  }

  resize(wrapper);

}

/**
 * Adds an element to the DOM canvas at the bottom of the canvas
 */
void addElementToDisplay(PageElement element) {
  addElementIndexToDisplay(querySelector('p').children.length, element);
}

/**
 * Deletes an element from the page element list and removes it from the list
 */
void deleteElement(Event event) {
  int index = int.parse(event.target.parent.attributes['id']);

  currentPage.elements.removeAt(index);

  var j = querySelector('p').children;
  j.removeAt(index);
  var k = j.iterator;

  int count = 0;
  while (k.moveNext()) {
    k.current.setAttribute('id', '${count}');
    k.current.children.first.setAttribute('id', '${count}');
    count++;
  }

}

/**
 * Updates the dynamic display, pushing changes to the database; called from
 * the textarea component
 */
void update(Event event) {
  handler(event);
  updateDatabase();

}

/**
 * Updates the pages data structure if changes are made to the textarea 
 * component
 */
void handler(Event event) {
  currentPage.elements.elementAt(
      int.parse(event.target.id)).content = event.target.value;
  resize(event.target.parent);

}

/**
 * Resizes the textarea to fit the dynamic content
 */
void resize(Element parent) {
  Element child = parent.children.first;
  child.style.height = "0px";
  child.style.height = "${child.scrollHeight + 14}px";

  int s = int.parse(parent.children.first.style.height.replaceAll('px', ''));

  parent.children.last.style.marginTop = '${(-s / 2) - 20}px';

}
