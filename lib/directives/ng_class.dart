library angular.directive.ng_class;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../scope.dart";
import "../utils.dart";

/**
 * The `ngClass` allows you to set CSS classes on HTML an element, dynamically,
 * by databinding an expression that represents all classes to be added.
 *
 * The directive won't add duplicate classes if a particular class was
 * already set.
 *
 * When the expression changes, the previously added classes are removed and
 * only then the new classes are added.
 *
 * The result of the expression evaluation can be a string representing space
 * delimited class names, an array, or a map of class names to boolean values.
 * In the case of a map, the names of the properties whose values are truthy
 * will be added as css classes to the element.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <p ng-class="{strike: strike, bold: bold, red: red}">Map Syntax Example</p>
 *     <input type="checkbox" ng-model="bold"> bold
 *     <input type="checkbox" ng-model="strike"> strike
 *     <input type="checkbox" ng-model="red"> red
 *     <hr>
 *     <p ng-class="style">Using String Syntax</p>
 *     <input type="text" ng-model="style" placeholder="Type: bold strike red">
 *     <hr>
 *     <p ng-class="[style1, style2, style3]">Using Array Syntax</p>
 *     <input ng-model="style1" placeholder="Type: bold"><br>
 *     <input ng-model="style2" placeholder="Type: strike"><br>
 *     <input ng-model="style3" placeholder="Type: red"><br>
 *
 * style.css:
 *
 *     .strike {
 *       text-decoration: line-through;
 *     }
 *     .bold {
 *         font-weight: bold;
 *     }
 *     .red {
 *         color: red;
 *     }
 *
 */
@NgDirective(
    selector: '[ng-class]',
    map: const {'ng-class': '@.valueExpression'})
class NgClassAttrDirective extends _NgClassBase {
  NgClassAttrDirective(dom.Element element, Scope scope)
      : super(element, scope, null);
}

/**
 * The `ngClassOdd` and `ngClassEven` directives work exactly as
 * {@link ng.directive:ngClass ngClass}, except it works in
 * conjunction with `ngRepeat` and takes affect only on odd (even) rows.
 *
 * This directive can be applied only within a scope of an `ngRepeat`.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <li ng-repeat="name in ['John', 'Mary', 'Cate', 'Suz']">
 *       <span ng-class-odd="'odd'" ng-class-even="'even'">
 *         {{name}}
 *       </span>
 *     </li>
 *
 * style.css:
 *
 *     .odd {
 *       color: red;
 *     }
 *     .even {
 *       color: blue;
 *     }
 */
@NgDirective(
    selector: '[ng-class-odd]',
    map: const {'ng-class-odd': '@.valueExpression'})
class NgClassOddAttrDirective extends _NgClassBase {
  NgClassOddAttrDirective(dom.Element element, Scope scope)
      : super(element, scope, 0);
}

/**
 * The `ngClassOdd` and `ngClassEven` directives work exactly as
 * {@link ng.directive:ngClass ngClass}, except it works in
 * conjunction with `ngRepeat` and takes affect only on odd (even) rows.
 *
 * This directive can be applied only within a scope of an `ngRepeat`.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <li ng-repeat="name in ['John', 'Mary', 'Cate', 'Suz']">
 *       <span ng-class-odd="'odd'" ng-class-even="'even'">
 *         {{name}}
 *       </span>
 *     </li>
 *
 * style.css:
 *
 *     .odd {
 *       color: red;
 *     }
 *     .even {
 *       color: blue;
 *     }
 */
@NgDirective(
    selector: '[ng-class-even]',
    map: const {'ng-class-even': '@.valueExpression'})
class NgClassEvenAttrDirective extends _NgClassBase {
  NgClassEvenAttrDirective(dom.Element element, Scope scope)
      : super(element, scope, 1);
}

abstract class _NgClassBase {
  final dom.Element element;
  final Scope scope;
  final int mode;
  var previousSet = [];
  var currentSet = [];

  _NgClassBase(this.element, this.scope, this.mode) {
    var prevClass;
    var observer = new dom.MutationObserver(
        (List<dom.MutationRecord> mutations, _) {
          if (prevClass != element.className) {
            prevClass = element.className;
            _handleChange(scope[r'$index']);
          }
        });
    observer.observe(element, attributes: true, attributeFilter: ['class']);
  }

  set valueExpression(currentExpression) {
    // this should be called only once, so we don't worry about cleaning up
    // watcher registrations.
    scope.$watchCollection(currentExpression, (current) {
      currentSet = _flatten(current);
      _handleChange(scope[r'$index']);
    });
    if (mode != null) {
      scope.$watch(r'$index', (index, oldIndex) {
        var mod = index % 2;
        if (oldIndex == null || mod != oldIndex % 2) {
          if (mod == mode) {
            element.classes.addAll(currentSet);
          } else {
            element.classes.removeAll(previousSet);
          }
        }
      });
    }
  }

  _handleChange(index) {
    if (mode == null || (index != null && index % 2 == mode)) {
      element.classes.removeAll(previousSet);
      element.classes.addAll(currentSet);
    }

    previousSet = currentSet;
  }

  static List<String> _flatten(classes) {
    if (classes == null) return [];
    if (classes is List) {
      return classes;
    }
    if (classes is Map) {
      return classes.keys.where((key) => toBool(classes[key])).toList();
    }
    if (classes is String) {
      return classes.split(' ');
    }
    throw 'ng-class expects expression value to be List, Map or String.';
  }
}
