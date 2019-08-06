/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "http://localhost:3000/packs/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 409);
/******/ })
/************************************************************************/
/******/ ({

/***/ 1:
/***/ (function(module, exports) {

module.exports = React;

/***/ }),

/***/ 17:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = {
  POSITION: {
    TOP_LEFT: 'top-left',
    TOP_RIGHT: 'top-right',
    TOP_CENTER: 'top-center',
    BOTTOM_LEFT: 'bottom-left',
    BOTTOM_RIGHT: 'bottom-right',
    BOTTOM_CENTER: 'bottom-center'
  },
  TYPE: {
    INFO: 'info',
    SUCCESS: 'success',
    WARNING: 'warning',
    ERROR: 'error',
    DEFAULT: 'default'
  },
  ACTION: {
    SHOW: 'SHOW_TOAST',
    CLEAR: 'CLEAR_TOAST',
    MOUNTED: 'CONTAINER_MOUNTED'
  }
};

/***/ }),

/***/ 2:
/***/ (function(module, exports, __webpack_require__) {

/**
 * Copyright 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

if (false) {
  var REACT_ELEMENT_TYPE = (typeof Symbol === 'function' &&
    Symbol.for &&
    Symbol.for('react.element')) ||
    0xeac7;

  var isValidElement = function(object) {
    return typeof object === 'object' &&
      object !== null &&
      object.$$typeof === REACT_ELEMENT_TYPE;
  };

  // By explicitly using `prop-types` you are opting into new development behavior.
  // http://fb.me/prop-types-in-prod
  var throwOnDirectAccess = true;
  module.exports = require('./factoryWithTypeCheckers')(isValidElement, throwOnDirectAccess);
} else {
  // By explicitly using `prop-types` you are opting into new production behavior.
  // http://fb.me/prop-types-in-prod
  module.exports = __webpack_require__(38)();
}


/***/ }),

/***/ 32:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright 2014-2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */



/**
 * Similar to invariant but only logs a warning if the condition is not met.
 * This can be used to log issues in development environments in critical
 * paths. Removing the logging code for production environments will keep the
 * same logic and follow the same code paths.
 */

var warning = function() {};

if (false) {
  warning = function(condition, format, args) {
    var len = arguments.length;
    args = new Array(len > 2 ? len - 2 : 0);
    for (var key = 2; key < len; key++) {
      args[key - 2] = arguments[key];
    }
    if (format === undefined) {
      throw new Error(
        '`warning(condition, format, ...args)` requires a warning ' +
        'message argument'
      );
    }

    if (format.length < 10 || (/^[s\W]*$/).test(format)) {
      throw new Error(
        'The warning format should be able to uniquely identify this ' +
        'warning. Please, use a more descriptive format than: ' + format
      );
    }

    if (!condition) {
      var argIndex = 0;
      var message = 'Warning: ' +
        format.replace(/%s/g, function() {
          return args[argIndex++];
        });
      if (typeof console !== 'undefined') {
        console.error(message);
      }
      try {
        // This error was thrown as a convenience so that you can use this stack
        // to find the callsite that caused this warning to fire.
        throw new Error(message);
      } catch(x) {}
    }
  };
}

module.exports = warning;


/***/ }),

/***/ 38:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */



var emptyFunction = __webpack_require__(39);
var invariant = __webpack_require__(40);
var ReactPropTypesSecret = __webpack_require__(41);

module.exports = function() {
  function shim(props, propName, componentName, location, propFullName, secret) {
    if (secret === ReactPropTypesSecret) {
      // It is still safe when called from React.
      return;
    }
    invariant(
      false,
      'Calling PropTypes validators directly is not supported by the `prop-types` package. ' +
      'Use PropTypes.checkPropTypes() to call them. ' +
      'Read more at http://fb.me/use-check-prop-types'
    );
  };
  shim.isRequired = shim;
  function getShim() {
    return shim;
  };
  // Important!
  // Keep this list in sync with production version in `./factoryWithTypeCheckers.js`.
  var ReactPropTypes = {
    array: shim,
    bool: shim,
    func: shim,
    number: shim,
    object: shim,
    string: shim,
    symbol: shim,

    any: shim,
    arrayOf: getShim,
    element: shim,
    instanceOf: getShim,
    node: shim,
    objectOf: getShim,
    oneOf: getShim,
    oneOfType: getShim,
    shape: getShim
  };

  ReactPropTypes.checkPropTypes = emptyFunction;
  ReactPropTypes.PropTypes = ReactPropTypes;

  return ReactPropTypes;
};


/***/ }),

/***/ 39:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


/**
 * Copyright (c) 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 * 
 */

function makeEmptyFunction(arg) {
  return function () {
    return arg;
  };
}

/**
 * This function accepts and discards inputs; it has no side effects. This is
 * primarily useful idiomatically for overridable function endpoints which
 * always need to be callable, since JS lacks a null-call idiom ala Cocoa.
 */
var emptyFunction = function emptyFunction() {};

emptyFunction.thatReturns = makeEmptyFunction;
emptyFunction.thatReturnsFalse = makeEmptyFunction(false);
emptyFunction.thatReturnsTrue = makeEmptyFunction(true);
emptyFunction.thatReturnsNull = makeEmptyFunction(null);
emptyFunction.thatReturnsThis = function () {
  return this;
};
emptyFunction.thatReturnsArgument = function (arg) {
  return arg;
};

module.exports = emptyFunction;

/***/ }),

/***/ 40:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright (c) 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 */



/**
 * Use invariant() to assert state which your program assumes to be true.
 *
 * Provide sprintf-style format (only %s is supported) and arguments
 * to provide information about what broke and what you were
 * expecting.
 *
 * The invariant message will be stripped in production, but the invariant
 * will remain to ensure logic does not differ in production.
 */

var validateFormat = function validateFormat(format) {};

if (false) {
  validateFormat = function validateFormat(format) {
    if (format === undefined) {
      throw new Error('invariant requires an error message argument');
    }
  };
}

function invariant(condition, format, a, b, c, d, e, f) {
  validateFormat(format);

  if (!condition) {
    var error;
    if (format === undefined) {
      error = new Error('Minified exception occurred; use the non-minified dev environment ' + 'for the full error message and additional helpful warnings.');
    } else {
      var args = [a, b, c, d, e, f];
      var argIndex = 0;
      error = new Error(format.replace(/%s/g, function () {
        return args[argIndex++];
      }));
      error.name = 'Invariant Violation';
    }

    error.framesToPop = 1; // we don't care about invariant's own frame
    throw error;
  }
}

module.exports = invariant;

/***/ }),

/***/ 409:
/***/ (function(module, exports, __webpack_require__) {

// (function (global) {
//   global.clearTimeout = global.clearTimeout || function () {};
//   global.setTimeout = global.setTimeout || function () {};
// }(this));

__webpack_require__(410);
__webpack_require__(411);
__webpack_require__(412);
// require('react-block-ui/style.css');
__webpack_require__(413);

toast = __webpack_require__(91).toast;
// ToastContainer = require('react-toastify').ToastContainer;

// BlockUi = require('react-block-ui/dist/reactblockui.js').default;


// ReactSelect = require('react-select');

// ReactSlider = require('rc-slider').default;
// ReactRange = require('rc-slider').Range;

// DropNCrop = require('@synapsestudios/react-drop-n-crop').default;

// GooglePlacesAutocomplete = require('react-places-autocomplete').default;
// GeocodeByAddress         = require('react-places-autocomplete').geocodeByAddress;
// GetLatLng                = require('react-places-autocomplete').getLatLng;

// ReactTooltip = require('react-tooltip');

// GoogleMapReact = require('google-map-react').default;

// moment = require('moment');
// Datetime = require('react-datetime');

// BootstrapMultiSelect = require('react-bootstrap-multiselect');

/***/ }),

/***/ 41:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */



var ReactPropTypesSecret = 'SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED';

module.exports = ReactPropTypesSecret;


/***/ }),

/***/ 410:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 411:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 412:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 413:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 48:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (obj) {
  var values = [];
  Object.keys(obj).forEach(function (key) {
    return values.push(obj[key]);
  });
  return values;
};

/***/ }),

/***/ 49:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.falseOrElement = exports.falseOrNumber = undefined;
exports.typeOf = typeOf;
exports.isValidDelay = isValidDelay;

var _react = __webpack_require__(1);

function typeOf(obj) {
  return Object.prototype.toString.call(obj).slice(8, -1);
}

function isValidDelay(val) {
  return typeOf(val) === 'Number' && !isNaN(val) && val > 0;
}

function withRequired(fn) {
  fn.isRequired = function (props, propName, componentName) {
    var prop = props[propName];

    if (typeof prop === 'undefined') {
      return new Error('The prop ' + propName + ' is marked as required in \n      ' + componentName + ', but its value is undefined.');
    }

    fn(props, propName, componentName);
  };
  return fn;
}

/**
 * TODO: Maybe rethink about the name
 */
var falseOrNumber = exports.falseOrNumber = withRequired(function (props, propName, componentName) {
  var prop = props[propName];

  if (prop !== false && !isValidDelay(prop)) {
    return new Error(componentName + ' expect ' + propName + ' \n      to be a valid Number > 0 or equal to false. ' + prop + ' given.');
  }

  return null;
});

var falseOrElement = exports.falseOrElement = withRequired(function (props, propName, componentName) {
  var prop = props[propName];

  if (prop !== false && !(0, _react.isValidElement)(prop)) {
    return new Error(componentName + ' expect ' + propName + ' \n      to be a valid react element or equal to false. ' + prop + ' given.');
  }

  return null;
});

/***/ }),

/***/ 50:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

var eventManager = {
  eventList: new Map(),

  on: function on(event, callback) {
    this.eventList.has(event) || this.eventList.set(event, []);

    this.eventList.get(event).push(callback);

    return this;
  },
  off: function off() {
    var event = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : null;

    return this.eventList.delete(event);
  },
  emit: function emit(event) {
    var _this = this;

    for (var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
      args[_key - 1] = arguments[_key];
    }

    if (!this.eventList.has(event)) {
      /* eslint no-console: 0 */
      console.warn("<" + event + "> Event is not registered. Did you forgot to bind the event ?");
      return false;
    }

    this.eventList.get(event).forEach(function (callback) {
      return setTimeout(function () {
        return callback.call.apply(callback, [_this].concat(_toConsumableArray(args)));
      }, 0);
    });

    return true;
  }
};

exports.default = eventManager;

/***/ }),

/***/ 91:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.toast = exports.ToastContainer = undefined;

var _ToastContainer = __webpack_require__(92);

var _ToastContainer2 = _interopRequireDefault(_ToastContainer);

var _toaster = __webpack_require__(99);

var _toaster2 = _interopRequireDefault(_toaster);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.ToastContainer = _ToastContainer2.default;
exports.toast = _toaster2.default;

/***/ }),

/***/ 92:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _react = __webpack_require__(1);

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(2);

var _propTypes2 = _interopRequireDefault(_propTypes);

var _TransitionGroup = __webpack_require__(93);

var _TransitionGroup2 = _interopRequireDefault(_TransitionGroup);

var _Toast = __webpack_require__(96);

var _Toast2 = _interopRequireDefault(_Toast);

var _DefaultCloseButton = __webpack_require__(98);

var _DefaultCloseButton2 = _interopRequireDefault(_DefaultCloseButton);

var _config = __webpack_require__(17);

var _config2 = _interopRequireDefault(_config);

var _EventManager = __webpack_require__(50);

var _EventManager2 = _interopRequireDefault(_EventManager);

var _objectValues = __webpack_require__(48);

var _objectValues2 = _interopRequireDefault(_objectValues);

var _propValidator = __webpack_require__(49);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var ToastContainer = function (_Component) {
  _inherits(ToastContainer, _Component);

  function ToastContainer(props) {
    _classCallCheck(this, ToastContainer);

    var _this = _possibleConstructorReturn(this, (ToastContainer.__proto__ || Object.getPrototypeOf(ToastContainer)).call(this, props));

    _this.isToastActive = function (id) {
      return _this.state.toast.indexOf(parseInt(id, 10)) !== -1;
    };

    _this.state = {
      toast: []
    };
    _this.collection = {};
    return _this;
  }

  _createClass(ToastContainer, [{
    key: "componentDidMount",
    value: function componentDidMount() {
      var _this2 = this;

      var _config$ACTION = _config2.default.ACTION,
          SHOW = _config$ACTION.SHOW,
          CLEAR = _config$ACTION.CLEAR,
          MOUNTED = _config$ACTION.MOUNTED;

      _EventManager2.default.on(SHOW, function (content, options) {
        return _this2.show(content, options);
      }).on(CLEAR, function (id) {
        return id !== null ? _this2.removeToast(id) : _this2.clear();
      }).emit(MOUNTED, this);
    }
  }, {
    key: "componentWillUnmount",
    value: function componentWillUnmount() {
      _EventManager2.default.off(_config2.default.ACTION.SHOW);
      _EventManager2.default.off(_config2.default.ACTION.CLEAR);
    }
  }, {
    key: "removeToast",
    value: function removeToast(id) {
      this.setState({
        toast: this.state.toast.filter(function (v) {
          return v !== parseInt(id, 10);
        })
      });
    }
  }, {
    key: "with",
    value: function _with(component, props) {
      return (0, _react.cloneElement)(component, _extends({}, props, component.props));
    }
  }, {
    key: "makeCloseButton",
    value: function makeCloseButton(toastClose, toastId) {
      var _this3 = this;

      var closeButton = this.props.closeButton;

      if ((0, _react.isValidElement)(toastClose) || toastClose === false) {
        closeButton = toastClose;
      }

      return closeButton === false ? false : this.with(closeButton, {
        closeToast: function closeToast() {
          return _this3.removeToast(toastId);
        }
      });
    }
  }, {
    key: "getAutoCloseDelay",
    value: function getAutoCloseDelay(toastAutoClose) {
      return toastAutoClose === false || (0, _propValidator.isValidDelay)(toastAutoClose) ? toastAutoClose : this.props.autoClose;
    }
  }, {
    key: "isFunction",
    value: function isFunction(object) {
      return !!(object && object.constructor && object.call && object.apply);
    }
  }, {
    key: "canBeRendered",
    value: function canBeRendered(content) {
      return (0, _react.isValidElement)(content) || (0, _propValidator.typeOf)(content) === "String" || (0, _propValidator.typeOf)(content) === "Number";
    }
  }, {
    key: "show",
    value: function show(content, options) {
      var _this4 = this;

      if (!this.canBeRendered(content)) {
        throw new Error("The element you provided cannot be rendered. You provided an element of type " + (typeof content === "undefined" ? "undefined" : _typeof(content)));
      }
      var toastId = options.toastId;
      var closeToast = function closeToast() {
        return _this4.removeToast(toastId);
      };
      var toastOptions = {
        id: toastId,
        type: options.type,
        closeButton: this.makeCloseButton(options.closeButton, toastId),
        position: options.position || this.props.position,
        pauseOnHover: options.pauseOnHover !== null ? options.pauseOnHover : this.props.pauseOnHover,
        closeOnClick: options.closeOnClick !== null ? options.closeOnClick : this.props.closeOnClick,
        className: options.className || this.props.toastClassName,
        bodyClassName: options.bodyClassName || this.props.bodyClassName,
        progressClassName: options.progressClassName || this.props.progressClassName
      };

      this.isFunction(options.onOpen) && (toastOptions.onOpen = options.onOpen);

      this.isFunction(options.onClose) && (toastOptions.onClose = options.onClose);

      toastOptions.autoClose = this.getAutoCloseDelay(options.autoClose !== false ? parseInt(options.autoClose, 10) : options.autoClose);

      toastOptions.hideProgressBar = typeof options.hideProgressBar === "boolean" ? options.hideProgressBar : this.props.hideProgressBar;

      toastOptions.closeToast = closeToast;

      if ((0, _react.isValidElement)(content) && (0, _propValidator.typeOf)(content.type) !== "String") {
        content = this.with(content, {
          closeToast: closeToast
        });
      }

      this.collection = _extends({}, this.collection, _defineProperty({}, toastId, {
        content: this.makeToast(content, toastOptions),
        position: toastOptions.position
      }));

      this.setState({
        toast: [].concat(_toConsumableArray(this.state.toast), [toastId])
      });
    }
  }, {
    key: "makeToast",
    value: function makeToast(content, options) {
      return _react2.default.createElement(
        _Toast2.default,
        _extends({}, options, { key: "toast-" + options.id + " " }),
        content
      );
    }
  }, {
    key: "clear",
    value: function clear() {
      this.setState({ toast: [] });
    }
  }, {
    key: "hasToast",
    value: function hasToast() {
      return this.state.toast.length > 0;
    }
  }, {
    key: "getContainerProps",
    value: function getContainerProps(pos, disablePointer) {
      var props = {
        className: "toastify toastify--" + pos,
        style: disablePointer ? { pointerEvents: "none" } : {}
      };

      if (this.props.className !== null) {
        props.className = props.className + " " + this.props.className;
      }

      if (this.props.style !== null) {
        props.style = _extends({}, this.props.style, props.style);
      }

      return props;
    }
  }, {
    key: "renderToast",
    value: function renderToast() {
      var _this5 = this;

      var toastToRender = {};
      var collection = this.props.newestOnTop ? Object.keys(this.collection).reverse() : Object.keys(this.collection);

      collection.forEach(function (toastId) {
        var item = _this5.collection[toastId];
        toastToRender[item.position] || (toastToRender[item.position] = []);

        if (_this5.state.toast.indexOf(parseInt(toastId, 10)) !== -1) {
          toastToRender[item.position].push(item.content);
        } else {
          // Temporal zone for animation
          toastToRender[item.position].push(null);
          // Delay garbage collecting. Useful when a lots of toast
          setTimeout(function () {
            return delete _this5.collection[toastId];
          }, collection.length * 10);
        }
      });

      return Object.keys(toastToRender).map(function (position) {
        var disablePointer = toastToRender[position].length === 1 && toastToRender[position][0] === null;

        return _react2.default.createElement(
          _TransitionGroup2.default,
          _extends({
            component: "div"
          }, _this5.getContainerProps(position, disablePointer), {
            key: "container-" + position
          }),
          toastToRender[position].map(function (item) {
            return item;
          })
        );
      });
    }
  }, {
    key: "render",
    value: function render() {
      return _react2.default.createElement(
        "div",
        null,
        this.renderToast()
      );
    }
  }]);

  return ToastContainer;
}(_react.Component);

ToastContainer.propTypes = {
  /**
   * Set toast position
   */
  position: _propTypes2.default.oneOf((0, _objectValues2.default)(_config2.default.POSITION)),

  /**
   * Disable or set autoClose delay
   */
  autoClose: _propValidator.falseOrNumber,

  /**
   * Disable or set a custom react element for the close button
   */
  closeButton: _propValidator.falseOrElement,

  /**
   * Hide or not progress bar when autoClose is enabled
   */
  hideProgressBar: _propTypes2.default.bool,

  /**
   * Pause toast duration on hover
   */
  pauseOnHover: _propTypes2.default.bool,

  /**
   * Dismiss toast on click
   */
  closeOnClick: _propTypes2.default.bool,

  /**
   * Newest on top
   */
  newestOnTop: _propTypes2.default.bool,

  /**
   * An optional className
   */
  className: _propTypes2.default.string,

  /**
   * An optional style
   */
  style: _propTypes2.default.object,

  /**
   * An optional className for the toast
   */
  toastClassName: _propTypes2.default.string,

  /**
   * An optional className for the toast body
   */
  bodyClassName: _propTypes2.default.string,

  /**
   * An optional className for the toast progress bar
   */
  progressClassName: _propTypes2.default.string
};
ToastContainer.defaultProps = {
  position: _config2.default.POSITION.TOP_RIGHT,
  autoClose: 5000,
  hideProgressBar: false,
  closeButton: _react2.default.createElement(_DefaultCloseButton2.default, null),
  pauseOnHover: true,
  closeOnClick: true,
  newestOnTop: false,
  className: null,
  style: null,
  toastClassName: '',
  bodyClassName: '',
  progressClassName: ''
};
exports.default = ToastContainer;

/***/ }),

/***/ 93:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var _chainFunction = __webpack_require__(94);

var _chainFunction2 = _interopRequireDefault(_chainFunction);

var _react = __webpack_require__(1);

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(2);

var _propTypes2 = _interopRequireDefault(_propTypes);

var _warning = __webpack_require__(32);

var _warning2 = _interopRequireDefault(_warning);

var _ChildMapping = __webpack_require__(95);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var propTypes = {
  component: _propTypes2.default.any,
  childFactory: _propTypes2.default.func,
  children: _propTypes2.default.node
};

var defaultProps = {
  component: 'span',
  childFactory: function childFactory(child) {
    return child;
  }
};

var TransitionGroup = function (_React$Component) {
  _inherits(TransitionGroup, _React$Component);

  function TransitionGroup(props, context) {
    _classCallCheck(this, TransitionGroup);

    var _this = _possibleConstructorReturn(this, _React$Component.call(this, props, context));

    _this.performAppear = function (key, component) {
      _this.currentlyTransitioningKeys[key] = true;

      if (component.componentWillAppear) {
        component.componentWillAppear(_this._handleDoneAppearing.bind(_this, key, component));
      } else {
        _this._handleDoneAppearing(key, component);
      }
    };

    _this._handleDoneAppearing = function (key, component) {
      if (component.componentDidAppear) {
        component.componentDidAppear();
      }

      delete _this.currentlyTransitioningKeys[key];

      var currentChildMapping = (0, _ChildMapping.getChildMapping)(_this.props.children);

      if (!currentChildMapping || !currentChildMapping.hasOwnProperty(key)) {
        // This was removed before it had fully appeared. Remove it.
        _this.performLeave(key, component);
      }
    };

    _this.performEnter = function (key, component) {
      _this.currentlyTransitioningKeys[key] = true;

      if (component.componentWillEnter) {
        component.componentWillEnter(_this._handleDoneEntering.bind(_this, key, component));
      } else {
        _this._handleDoneEntering(key, component);
      }
    };

    _this._handleDoneEntering = function (key, component) {
      if (component.componentDidEnter) {
        component.componentDidEnter();
      }

      delete _this.currentlyTransitioningKeys[key];

      var currentChildMapping = (0, _ChildMapping.getChildMapping)(_this.props.children);

      if (!currentChildMapping || !currentChildMapping.hasOwnProperty(key)) {
        // This was removed before it had fully entered. Remove it.
        _this.performLeave(key, component);
      }
    };

    _this.performLeave = function (key, component) {
      _this.currentlyTransitioningKeys[key] = true;

      if (component.componentWillLeave) {
        component.componentWillLeave(_this._handleDoneLeaving.bind(_this, key, component));
      } else {
        // Note that this is somewhat dangerous b/c it calls setState()
        // again, effectively mutating the component before all the work
        // is done.
        _this._handleDoneLeaving(key, component);
      }
    };

    _this._handleDoneLeaving = function (key, component) {
      if (component.componentDidLeave) {
        component.componentDidLeave();
      }

      delete _this.currentlyTransitioningKeys[key];

      var currentChildMapping = (0, _ChildMapping.getChildMapping)(_this.props.children);

      if (currentChildMapping && currentChildMapping.hasOwnProperty(key)) {
        // This entered again before it fully left. Add it again.
        _this.keysToEnter.push(key);
      } else {
        _this.setState(function (state) {
          var newChildren = _extends({}, state.children);
          delete newChildren[key];
          return { children: newChildren };
        });
      }
    };

    _this.childRefs = Object.create(null);

    _this.state = {
      children: (0, _ChildMapping.getChildMapping)(props.children)
    };
    return _this;
  }

  TransitionGroup.prototype.componentWillMount = function componentWillMount() {
    this.currentlyTransitioningKeys = {};
    this.keysToEnter = [];
    this.keysToLeave = [];
  };

  TransitionGroup.prototype.componentDidMount = function componentDidMount() {
    var initialChildMapping = this.state.children;
    for (var key in initialChildMapping) {
      if (initialChildMapping[key]) {
        this.performAppear(key, this.childRefs[key]);
      }
    }
  };

  TransitionGroup.prototype.componentWillReceiveProps = function componentWillReceiveProps(nextProps) {
    var nextChildMapping = (0, _ChildMapping.getChildMapping)(nextProps.children);
    var prevChildMapping = this.state.children;

    this.setState({
      children: (0, _ChildMapping.mergeChildMappings)(prevChildMapping, nextChildMapping)
    });

    for (var key in nextChildMapping) {
      var hasPrev = prevChildMapping && prevChildMapping.hasOwnProperty(key);
      if (nextChildMapping[key] && !hasPrev && !this.currentlyTransitioningKeys[key]) {
        this.keysToEnter.push(key);
      }
    }

    for (var _key in prevChildMapping) {
      var hasNext = nextChildMapping && nextChildMapping.hasOwnProperty(_key);
      if (prevChildMapping[_key] && !hasNext && !this.currentlyTransitioningKeys[_key]) {
        this.keysToLeave.push(_key);
      }
    }

    // If we want to someday check for reordering, we could do it here.
  };

  TransitionGroup.prototype.componentDidUpdate = function componentDidUpdate() {
    var _this2 = this;

    var keysToEnter = this.keysToEnter;
    this.keysToEnter = [];
    keysToEnter.forEach(function (key) {
      return _this2.performEnter(key, _this2.childRefs[key]);
    });

    var keysToLeave = this.keysToLeave;
    this.keysToLeave = [];
    keysToLeave.forEach(function (key) {
      return _this2.performLeave(key, _this2.childRefs[key]);
    });
  };

  TransitionGroup.prototype.render = function render() {
    var _this3 = this;

    // TODO: we could get rid of the need for the wrapper node
    // by cloning a single child
    var childrenToRender = [];

    var _loop = function _loop(key) {
      var child = _this3.state.children[key];
      if (child) {
        var isCallbackRef = typeof child.ref !== 'string';
        var factoryChild = _this3.props.childFactory(child);
        var ref = function ref(r) {
          _this3.childRefs[key] = r;
        };

         false ? (0, _warning2.default)(isCallbackRef, 'string refs are not supported on children of TransitionGroup and will be ignored. ' + 'Please use a callback ref instead: https://facebook.github.io/react/docs/refs-and-the-dom.html#the-ref-callback-attribute') : void 0;

        // Always chaining the refs leads to problems when the childFactory
        // wraps the child. The child ref callback gets called twice with the
        // wrapper and the child. So we only need to chain the ref if the
        // factoryChild is not different from child.
        if (factoryChild === child && isCallbackRef) {
          ref = (0, _chainFunction2.default)(child.ref, ref);
        }

        // You may need to apply reactive updates to a child as it is leaving.
        // The normal React way to do it won't work since the child will have
        // already been removed. In case you need this behavior you can provide
        // a childFactory function to wrap every child, even the ones that are
        // leaving.
        childrenToRender.push(_react2.default.cloneElement(factoryChild, {
          key: key,
          ref: ref
        }));
      }
    };

    for (var key in this.state.children) {
      _loop(key);
    }

    // Do not forward TransitionGroup props to primitive DOM nodes
    var props = _extends({}, this.props);
    delete props.transitionLeave;
    delete props.transitionName;
    delete props.transitionAppear;
    delete props.transitionEnter;
    delete props.childFactory;
    delete props.transitionLeaveTimeout;
    delete props.transitionEnterTimeout;
    delete props.transitionAppearTimeout;
    delete props.component;

    return _react2.default.createElement(this.props.component, props, childrenToRender);
  };

  return TransitionGroup;
}(_react2.default.Component);

TransitionGroup.displayName = 'TransitionGroup';


TransitionGroup.propTypes =  false ? propTypes : {};
TransitionGroup.defaultProps = defaultProps;

exports.default = TransitionGroup;
module.exports = exports['default'];

/***/ }),

/***/ 94:
/***/ (function(module, exports) {


module.exports = function chain(){
  var len = arguments.length
  var args = [];

  for (var i = 0; i < len; i++)
    args[i] = arguments[i]

  args = args.filter(function(fn){ return fn != null })

  if (args.length === 0) return undefined
  if (args.length === 1) return args[0]

  return args.reduce(function(current, next){
    return function chainedFunction() {
      current.apply(this, arguments);
      next.apply(this, arguments);
    };
  })
}


/***/ }),

/***/ 95:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.getChildMapping = getChildMapping;
exports.mergeChildMappings = mergeChildMappings;

var _react = __webpack_require__(1);

/**
 * Given `this.props.children`, return an object mapping key to child.
 *
 * @param {*} children `this.props.children`
 * @return {object} Mapping of key to child
 */
function getChildMapping(children) {
  if (!children) {
    return children;
  }
  var result = {};
  _react.Children.map(children, function (child) {
    return child;
  }).forEach(function (child) {
    result[child.key] = child;
  });
  return result;
}

/**
 * When you're adding or removing children some may be added or removed in the
 * same render pass. We want to show *both* since we want to simultaneously
 * animate elements in and out. This function takes a previous set of keys
 * and a new set of keys and merges them with its best guess of the correct
 * ordering. In the future we may expose some of the utilities in
 * ReactMultiChild to make this easy, but for now React itself does not
 * directly have this concept of the union of prevChildren and nextChildren
 * so we implement it here.
 *
 * @param {object} prev prev children as returned from
 * `ReactTransitionChildMapping.getChildMapping()`.
 * @param {object} next next children as returned from
 * `ReactTransitionChildMapping.getChildMapping()`.
 * @return {object} a key set that contains all keys in `prev` and all keys
 * in `next` in a reasonable order.
 */
function mergeChildMappings(prev, next) {
  prev = prev || {};
  next = next || {};

  function getValueForKey(key) {
    if (next.hasOwnProperty(key)) {
      return next[key];
    }

    return prev[key];
  }

  // For each key of `next`, the list of keys to insert before that key in
  // the combined list
  var nextKeysPending = {};

  var pendingKeys = [];
  for (var prevKey in prev) {
    if (next.hasOwnProperty(prevKey)) {
      if (pendingKeys.length) {
        nextKeysPending[prevKey] = pendingKeys;
        pendingKeys = [];
      }
    } else {
      pendingKeys.push(prevKey);
    }
  }

  var i = void 0;
  var childMapping = {};
  for (var nextKey in next) {
    if (nextKeysPending.hasOwnProperty(nextKey)) {
      for (i = 0; i < nextKeysPending[nextKey].length; i++) {
        var pendingNextKey = nextKeysPending[nextKey][i];
        childMapping[nextKeysPending[nextKey][i]] = getValueForKey(pendingNextKey);
      }
    }
    childMapping[nextKey] = getValueForKey(nextKey);
  }

  // Finally, add the keys which didn't appear before any key in `next`
  for (i = 0; i < pendingKeys.length; i++) {
    childMapping[pendingKeys[i]] = getValueForKey(pendingKeys[i]);
  }

  return childMapping;
}

/***/ }),

/***/ 96:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _react = __webpack_require__(1);

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(2);

var _propTypes2 = _interopRequireDefault(_propTypes);

var _ProgressBar = __webpack_require__(97);

var _ProgressBar2 = _interopRequireDefault(_ProgressBar);

var _config = __webpack_require__(17);

var _config2 = _interopRequireDefault(_config);

var _objectValues = __webpack_require__(48);

var _objectValues2 = _interopRequireDefault(_objectValues);

var _propValidator = __webpack_require__(49);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var Toast = function (_Component) {
  _inherits(Toast, _Component);

  function Toast(props) {
    _classCallCheck(this, Toast);

    var _this = _possibleConstructorReturn(this, (Toast.__proto__ || Object.getPrototypeOf(Toast)).call(this, props));

    _this.setRef = function (ref) {
      _this.ref = ref;
    };

    _this.pauseToast = function () {
      _this.setState({ isRunning: false });
    };

    _this.playToast = function () {
      _this.setState({ isRunning: true });
    };

    _this.ref = null;
    _this.state = {
      isRunning: true
    };
    return _this;
  }

  _createClass(Toast, [{
    key: 'componentDidMount',
    value: function componentDidMount() {
      this.props.onOpen !== null && this.props.onOpen(this.getChildrenProps());
    }
  }, {
    key: 'componentWillUnmount',
    value: function componentWillUnmount() {
      this.props.onClose !== null && this.props.onClose(this.getChildrenProps());
    }
  }, {
    key: 'getChildrenProps',
    value: function getChildrenProps() {
      return this.props.children.props;
    }
  }, {
    key: 'getToastProps',
    value: function getToastProps() {
      var toastProps = {
        className: 'toastify-content toastify-content--' + this.props.type + ' ' + this.props.className,
        ref: this.setRef
      };

      if (this.props.autoClose !== false && this.props.pauseOnHover === true) {
        toastProps.onMouseEnter = this.pauseToast;
        toastProps.onMouseLeave = this.playToast;
      }

      this.props.closeOnClick && (toastProps.onClick = this.props.closeToast);

      return toastProps;
    }
  }, {
    key: 'componentWillAppear',
    value: function componentWillAppear(callback) {
      this.ref.classList.add('toast-enter--' + this.props.position, 'toastify-animated');
      callback();
    }
  }, {
    key: 'componentWillEnter',
    value: function componentWillEnter(callback) {
      this.ref.classList.add('toast-enter--' + this.props.position, 'toastify-animated');
      callback();
    }
  }, {
    key: 'componentWillLeave',
    value: function componentWillLeave(callback) {
      this.ref.classList.remove('toast-enter--' + this.props.position, 'toastify-animated');
      this.ref.classList.add('toast-exit--' + this.props.position, 'toastify-animated');
      setTimeout(function () {
        return callback();
      }, 750);
    }
  }, {
    key: 'render',
    value: function render() {
      var _props = this.props,
          closeButton = _props.closeButton,
          children = _props.children,
          autoClose = _props.autoClose,
          type = _props.type,
          hideProgressBar = _props.hideProgressBar,
          closeToast = _props.closeToast;


      return _react2.default.createElement(
        'div',
        this.getToastProps(),
        _react2.default.createElement(
          'div',
          { className: 'toastify__body ' + this.props.bodyClassName },
          children
        ),
        closeButton !== false && closeButton,
        autoClose !== false && _react2.default.createElement(_ProgressBar2.default, {
          delay: autoClose,
          isRunning: this.state.isRunning,
          closeToast: closeToast,
          hide: hideProgressBar,
          type: type,
          className: this.props.progressClassName
        })
      );
    }
  }]);

  return Toast;
}(_react.Component);

Toast.propTypes = {
  closeButton: _propValidator.falseOrElement.isRequired,
  autoClose: _propValidator.falseOrNumber.isRequired,
  children: _propTypes2.default.node.isRequired,
  closeToast: _propTypes2.default.func.isRequired,
  position: _propTypes2.default.oneOf((0, _objectValues2.default)(_config2.default.POSITION)).isRequired,
  pauseOnHover: _propTypes2.default.bool.isRequired,
  closeOnClick: _propTypes2.default.bool.isRequired,
  hideProgressBar: _propTypes2.default.bool,
  onOpen: _propTypes2.default.func,
  onClose: _propTypes2.default.func,
  type: _propTypes2.default.oneOf((0, _objectValues2.default)(_config2.default.TYPE)),
  className: _propTypes2.default.string,
  bodyClassName: _propTypes2.default.string,
  progressClassName: _propTypes2.default.string
};
Toast.defaultProps = {
  type: _config2.default.TYPE.DEFAULT,
  hideProgressBar: false,
  onOpen: null,
  onClose: null,
  className: '',
  bodyClassName: '',
  progressClassName: ''
};
exports.default = Toast;

/***/ }),

/***/ 97:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _react = __webpack_require__(1);

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(2);

var _propTypes2 = _interopRequireDefault(_propTypes);

var _config = __webpack_require__(17);

var _config2 = _interopRequireDefault(_config);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function ProgressBar(_ref) {
  var delay = _ref.delay,
      isRunning = _ref.isRunning,
      closeToast = _ref.closeToast,
      type = _ref.type,
      hide = _ref.hide,
      className = _ref.className;

  var style = {
    animationDuration: delay + 'ms',
    animationPlayState: isRunning ? 'running' : 'paused'
  };
  style.WebkitAnimationPlayState = style.animationPlayState;

  if (hide) {
    style.opacity = 0;
  }

  return _react2.default.createElement('div', {
    className: 'toastify__progress toastify__progress--' + type + ' ' + className,
    style: style,
    onAnimationEnd: closeToast
  });
}

ProgressBar.propTypes = {
  /**
   * The animation delay which determine when to close the toast
   */
  delay: _propTypes2.default.number.isRequired,

  /**
   * Whether or not the animation is running or paused
   */
  isRunning: _propTypes2.default.bool.isRequired,

  /**
   * Func to close the current toast
   */
  closeToast: _propTypes2.default.func.isRequired,

  /**
   * Optional type : info, success ...
   */
  type: _propTypes2.default.string,

  /**
   * Hide or not the progress bar
   */
  hide: _propTypes2.default.bool,

  /**
   * Optionnal className
   */
  className: _propTypes2.default.string
};

ProgressBar.defaultProps = {
  type: _config2.default.TYPE.DEFAULT,
  hide: false,
  className: ''
};

exports.default = ProgressBar;

/***/ }),

/***/ 98:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _react = __webpack_require__(1);

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(2);

var _propTypes2 = _interopRequireDefault(_propTypes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/* eslint react/require-default-props: 0 */
function DefaultCloseButton(_ref) {
  var closeToast = _ref.closeToast;

  return _react2.default.createElement(
    'button',
    {
      className: 'toastify__close',
      type: 'button',
      onClick: closeToast
    },
    '\u2716'
  );
}

DefaultCloseButton.propTypes = {
  closeToast: _propTypes2.default.func
};

exports.default = DefaultCloseButton;

/***/ }),

/***/ 99:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; /*
                                                                                                                                                                                                                                                                  * TODO: Add validation here :
                                                                                                                                                                                                                                                                  *   - Validate type
                                                                                                                                                                                                                                                                  *   - Maybe autoClose
                                                                                                                                                                                                                                                                  *   - Maybe closeButton as well
                                                                                                                                                                                                                                                                  * */


var _EventManager = __webpack_require__(50);

var _EventManager2 = _interopRequireDefault(_EventManager);

var _config = __webpack_require__(17);

var _config2 = _interopRequireDefault(_config);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var POSITION = _config2.default.POSITION,
    TYPE = _config2.default.TYPE,
    ACTION = _config2.default.ACTION;


var defaultOptions = {
  type: TYPE.DEFAULT,
  autoClose: null,
  closeButton: null,
  hideProgressBar: null,
  position: null,
  pauseOnHover: null,
  closeOnClick: null,
  className: null,
  bodyClassName: null,
  progressClassName: null
};

var container = null;
var queue = [];
var toastId = 0;

/**
 * Merge provided options with the defaults settings and generate the toastId
 * @param {*} options
 */
function mergeOptions(options) {
  return _extends({}, defaultOptions, options, { toastId: ++toastId });
}

/**
 * Dispatch toast. If the container is not mounted, the toast is enqueued
 * @param {*} content
 * @param {*} options
 */
function emitEvent(content, options) {
  if (container !== null) {
    _EventManager2.default.emit(ACTION.SHOW, content, options);
  } else {
    queue.push({ action: ACTION.SHOW, content: content, options: options });
  }

  return options.toastId;
}

var toaster = _extends(function (content, options) {
  return emitEvent(content, mergeOptions(options));
}, {
  success: function success(content, options) {
    return emitEvent(content, _extends(mergeOptions(options), { type: TYPE.SUCCESS }));
  },
  info: function info(content, options) {
    return emitEvent(content, _extends(mergeOptions(options), { type: TYPE.INFO }));
  },
  warn: function warn(content, options) {
    return emitEvent(content, _extends(mergeOptions(options), { type: TYPE.WARNING }));
  },
  warning: function warning(content, options) {
    return emitEvent(content, _extends(mergeOptions(options), { type: TYPE.WARNING }));
  },
  error: function error(content, options) {
    return emitEvent(content, _extends(mergeOptions(options), { type: TYPE.ERROR }));
  },
  dismiss: function dismiss() {
    var id = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : null;
    return _EventManager2.default.emit(ACTION.CLEAR, id);
  },
  isActive: function isActive() {
    return false;
  }
}, {
  POSITION: POSITION,
  TYPE: TYPE
});

/**
 * Wait until the ToastContainer is mounted to dispatch the toast
 * and attach isActive method
 */
_EventManager2.default.on(ACTION.MOUNTED, function (containerInstance) {
  container = containerInstance;

  toaster.isActive = function (id) {
    return container.isToastActive(id);
  };

  queue.forEach(function (item) {
    _EventManager2.default.emit(item.action, item.content, item.options);
  });
  queue = [];
});

exports.default = toaster;

/***/ })

/******/ });
//# sourceMappingURL=client_only-1f516c3d7e166b4b6e71.js.map