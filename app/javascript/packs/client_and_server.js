(function (global) {
  global.clearTimeout = global.clearTimeout || function () {};
  global.setTimeout = global.setTimeout || function () {};
  global.window = global.window || {};
}(this));

// ReactDOMServer = require('react-dom/server'),
ReactDOM = require('react-dom');
React = require('react');

ReactSelect = require('react-select');

ReactSlider = require('rc-slider').default;
ReactRange = require('rc-slider').Range;

DropNCrop = require('@synapsestudios/react-drop-n-crop').default;

GooglePlacesAutocomplete = require('react-places-autocomplete').default;
GeocodeByAddress         = require('react-places-autocomplete').geocodeByAddress;
GetLatLng                = require('react-places-autocomplete').getLatLng;

ReactTooltip = require('react-tooltip');

GoogleMapReact = require('google-map-react').default;

moment = require('moment');
Datetime = require('react-datetime');

ToastContainer = require('react-toastify').ToastContainer;
toast = require('react-toastify').toast;

BlockUi = require('react-block-ui/dist/reactblockui.js').default;

// BootstrapMultiSelect = require('react-bootstrap-multiselect');
