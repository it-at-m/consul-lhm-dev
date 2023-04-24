(function() {
  "use strict";
  App.Map = {
    maps: [],
    initialize: function() {
      $("*[data-map]:visible").each(function() {
        App.Map.initializeMap(this);
      });
    },
    destroy: function() {
      App.Map.maps.forEach(function(map) {
        map.off();
        map.remove();
      });
      App.Map.maps = [];
    },
    initializeMap: function(element) {

      // variables to set map view
      var mapCenterLatitude = $(element).data("map-center-latitude");
      var mapCenterLongitude = $(element).data("map-center-longitude");
      var mapCenterLatLng = new L.LatLng(mapCenterLatitude, mapCenterLongitude);
      var zoom = $(element).data("map-zoom");

      // tile and overlay layers for map
      var layersData = $(element).data('map-layers');
      var baseLayers = {};
      var overlayLayers = {};
      var adminMarker = null;
      var adminShape = $(element).data("admin-shape");
      var showAdminShape = $(element).data("show-admin-shape");

      // variables that define map editing behaviour
      var adminEditor = $(element).data("admin-editor");
      var adminShapesColor = 'red';

      // variables that define location and tooltips of process coordinates (both pins and shapes)
      var process = $(element).data("parent-class");
      var processCoordinates = $(element).data("process-coordinates");

      // variables to define map form input selectors
      var latitudeInputSelector = $(element).data("latitude-input-selector");
      var longitudeInputSelector = $(element).data("longitude-input-selector");
      var zoomInputSelector = $(element).data("zoom-input-selector");
      var shapeInputSelector = $(element).data("shape-input-selector");
      var showAdminShapeInputSelector = $(element).data("show-admin-shape-input-selector");

      // defines if it's allowed to edit map
      var editable = $(element).data("editable");
      var enableGeomanControls = $(element).data("enable-geoman-controls");

      // biolerplate for marker
      var marker = null;
      var markersGroup = L.markerClusterGroup();
      var markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40]
      });


      /* Create leaflet map start */
      var map = L.map(element.id, {
        gestureHandling: true,
        maxZoom: 18
      }).setView(mapCenterLatLng, zoom);
      App.Map.maps.push(map);

      // update form fields when map center changes
      map.on("moveend", function() {
        if ( adminEditor && !marker ) {
          $(latitudeInputSelector).val(map.getCenter().lat);
          $(longitudeInputSelector).val(map.getCenter().lng);
          $(zoomInputSelector).val(map.getZoom());
        }
      });
      /* Create leaflet map end */


      /* Leaflet basic plugins start */
      // Leaflet.Locate plugin: ads control to map
      L.control.locate({icon: 'fa fa-map-marker'}).addTo(map);

      // Leaflet GeoSearch plugin: adds control to map
      var searchControl = new GeoSearch.GeoSearchControl({
        provider: new GeoSearch.OpenStreetMapProvider(),
        style: 'bar',
        showMarker: false,
        searchLabel: 'Nach Adresse suchen',
        notFoundMessage: 'Entschuldigung! Die Adresse wurde nicht gefunden.',
      });
      map.addControl(searchControl);

      // Leaflet.Deflate plugin: replaces shapes with markers when they are too small
      const deflateFeatures = L.deflate({
        minSize: 10,
        markerLayer: markersGroup,
        markerOptions: function(shape) {
          return {
            icon: markerIcon,
            id: getProcessId(shape)
          }
        }
      })

      deflateFeatures.addTo(map);

      function getProcessId(shape) {
        var id;

        if (process == "proposals") {
          id = shape.feature.proposal_id
        } else if (process == "deficiency-reports") {
          id = shape.feature.deficiency_report_id
        } else if (process == "projekts") {
          id = shape.feature.projekt_id
        } else {
          id = shape.feature.investment_id
        }

        return id
      }
      /* Leaflet basic plugins end */


      /* Function definitions start */
      // function to create a marker
      var getMarkerIconHTML = function(color, iconClass) {
        var markerIconHTML;

        if ( !iconClass ) {
          iconClass = 'circle';
        } else {
          iconClass = iconClass
        };

        if ( adminEditor ) {
          color = adminShapesColor;
        }

        if ( color ) {
          markerIconHTML = '<div class="map-icon icon-' + iconClass + '" style="background-color: ' + color + '"></div>'
        } else {
          markerIconHTML = '<div class="map-icon icon-' + iconClass + '"></div>'
        }

        return markerIconHTML;
      }

      var createMarker = function(latitude, longitude, color, iconClass) {

        var markerLatLng = new L.LatLng(latitude, longitude);

        markerIcon.options.html = getMarkerIconHTML(color, iconClass);

        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });

        if (editable) {
          marker.on("dragend", updateFormfieldsWithMarker);
          marker.addTo(map);
        } else {
          markersGroup.addLayer(marker);
        }

        return marker;
      };

      // function to create or move existing marker
      var moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfieldsWithMarker();
      };

      // function to update form fields when marker is updated
      var updateFormfieldsWithMarker = function() {
        $(latitudeInputSelector).val(marker.getLatLng().lat);
        $(longitudeInputSelector).val(marker.getLatLng().lng);
        $(zoomInputSelector).val(map.getZoom());
        $(shapeInputSelector).val(JSON.stringify({}));

        if ( adminEditor ) {
          $(showAdminShapeInputSelector).val(true);
        }
      };

      // function to open marker popup
      var openMarkerPopup = function(e) {
        var route;

        if ( process == "proposals" ) {
          route = "/proposals/" + e.target.options.id + "/json_data"
        } else if ( process == "deficiency-reports") {
          route = "/deficiency_reports/" + e.target.options.id + "/json_data"
        } else if ( process == "projekts") {
          route = "/projekts/" + e.target.options.id + "/json_data"
        } else {
          route = "/investments/" + e.target.options.id + "/json_data"
        }

        marker = e.target;
        $.ajax(route, {
          type: "GET",
          dataType: "json",
          success: function(data) {
            e.target.bindPopup(getPopupContent(data)).openPopup();
          }
        });
      };

      // function to generate marker popup content
      var getPopupContent = function(data) {
        if (process == "proposals" || data.proposal_id) {
          return "<a href='/proposals/" + data.proposal_id + "'>" + data.proposal_title + "</a>";
        } else if ( process == "deficiency-reports" ) {
          return "<a href='/deficiency_reports/" + data.deficiency_report_id + "'>" + data.deficiency_report_title + "</a>";
        } else if ( process == "projekts" ) {
          return "<a href='/projekts/" + data.projekt_id + "'>" + data.projekt_title + "</a>";
        } else {
          return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
        }
      };

      // function to add event listeners to the shape layer, used when shape layer is editable
      function addEventListenersToShapeLayer(layer) {
        layer.on('pm:edit', function(e) {
          updateShapeFieldInForm(e.layer);
        })

        layer.on('pm:dragend', function(e) {
          updateShapeFieldInForm(e.layer);
        })

        // allows multiple cuts
        layer.on('pm:cut', function(e) {
          if (typeof(e.layer.getLatLngs) == 'function') {
            e.originalLayer.setLatLngs(e.layer.getLatLngs());
            e.originalLayer.addTo(map);
            e.originalLayer._pmTempLayer = false;

            e.layer._pmTempLayer = true;
            e.layer.remove();
          }
        })
      }
      /* Function definitions end */


      /* Assembles a map: start */
      // function to create tile or overlay layer
      var createLayer = function(item, index) {

        if ( item.protocol == 'wms' ) {
          var layer = L.tileLayer.wms(item.provider, {
            attribution: item.attribution,
            layers: item.layer_names,
            format: (item.transparent ? 'image/png' : 'image/jpeg'),
            transparent: (item.transparent),
            show_by_default: (item.show_by_default)
          });

        } else {
          var layer = L.tileLayer(item.provider, {
            attribution: item.attribution
          });

        }

        if ( item.base ) {
          baseLayers[item.name] = layer;
        } else {
          overlayLayers[item.name] = layer;
        }
      }

      // function to ensure that at least one base layer exists
      var ensureBaseLayerExistence = function() {
        if ( Object.keys(baseLayers).length === 0 ) {
          var defaultLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors'
          });

          baseLayers['defaultLayer'] = defaultLayer;
        }
      }

      // creates tile and overlay layers if data is available
      if ( typeof layersData !== "undefined"  ) {
        layersData.forEach(createLayer);
      }

      // ensures that at least one base layer exists and adds it to map
      ensureBaseLayerExistence();
      baseLayers[Object.keys(baseLayers)[0]].addTo(map);

      // adds overlay layers to map if they should be visible by default
      if ( Object.keys(overlayLayers).length > 0 ) {
        for (let i = 0; i < Object.keys(overlayLayers).length; i++ ) {
          if ( overlayLayers[Object.keys(overlayLayers)[i]].options.show_by_default == true ) {
            overlayLayers[Object.keys(overlayLayers)[i]].addTo(map)
          }
        }
      }

      // adds layer control to map if there are more than one base and/or overlay layers
      if ( Object.keys(baseLayers).length > 1 && Object.keys(overlayLayers).length > 0 ) {
        L.control.layers(baseLayers, overlayLayers).addTo(map);
      } else if ( Object.keys(overlayLayers).length > 0 ) {
        L.control.layers({}, overlayLayers).addTo(map);
      }

      // render marker or shape created by admin, if available
      if (adminShape && showAdminShape) {
        if (App.Map.validCoordinates(adminShape)) {
          if ( adminEditor ) {
            marker = createMarker(adminShape.lat, adminShape.long, adminShapesColor, adminShape.fa_icon_class);


          } else {
            var markerLatLng = new L.LatLng(adminShape.lat, adminShape.long);
            markerIcon.options.html = getMarkerIconHTML(adminShapesColor, adminShape.fa_icon_class);

            adminMarker = L.marker(markerLatLng, {
              icon: markerIcon
            });
            adminMarker.pm.setOptions({ adminShape: true })

            adminMarker.on("click", function() {
              if (!this._popup) {
                this.bindPopup('Alle markierten Flächen und Pins in rot sind vom System vorgegeben').openPopup();
              }
            });

            adminMarker.addTo(map);
          }

        } else if (Object.keys(adminShape).length > 0) {
          var adminShapeLayer = L.geoJSON(adminShape);
          adminShapeLayer.pm.setOptions({ adminShape: true })
          adminShapeLayer.setStyle({
            color: adminShapesColor,
            fillColor: adminShapesColor,
            fillOpacity: 0.4,
          })

          if (editable) {
            addEventListenersToShapeLayer(adminShapeLayer)
          } else {
            adminShapeLayer.on("click", function() {
              if (!this._popup) {
                this.bindPopup('Alle markierten Flächen und Pins in rot sind vom System vorgegeben').openPopup();
              }
            });
          }

          adminShapeLayer.addTo(map);
        }
      }

      // adds second attribution to tell about admin pins and shapes
      if ( showAdminShape ) {
        var adminShapeExplainerText = 'Alle markierten Flächen und Pins in rot sind vom System vorgegeben';
        var adminShapeExplainer = L.control({
          position: 'bottomleft'
        });
        adminShapeExplainer.onAdd = function(map) {
          var container = L.DomUtil.create('div', 'my-attribution');
          container.innerHTML = adminShapeExplainerText;
          container.className += ' leaflet-control-attribution';
          container.style.color = adminShapesColor;
          return container;
        }
        adminShapeExplainer.addTo(map);
      }


      // ads pins and shapes created by user
      if (processCoordinates) {
        processCoordinates.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long, coordinates.color, coordinates.fa_icon_class);

            if (process == "proposals") {
              marker.options.id = coordinates.proposal_id
            } else if (process == "deficiency-reports") {
              marker.options.id = coordinates.deficiency_report_id
            } else if (process == "projekts") {
              marker.options.id = coordinates.projekt_id
            } else {
              marker.options.id = coordinates.investment_id
            }

            marker.on("click", openMarkerPopup);

          } else {
            var userShape = L.geoJSON(coordinates, {
              style: function(feature) {
                return { color: coordinates.color };
              }
            });

            if (process == "proposals") {
              userShape.options.id = coordinates.proposal_id
            } else if (process == "deficiency-reports") {
              userShape.options.id = coordinates.deficiency_report_id
            } else if (process == "projekts") {
              userShape.options.id = coordinates.projekt_id
            } else {
              userShape.options.id = coordinates.investment_id
            }

            userShape.on("click", openMarkerPopup);
            userShape.addTo(deflateFeatures);
            userShape.addTo(map);
          }
        });
      }
      /* Assembles a map: end */


      /* Leaflet-Geoman plugin: config start */
      // configure editor controls
      if ( editable ) {

        // sets default language to German
        map.pm.setLang('de');
 
        // set positions for geoman controls
        map.pm.Toolbar.setBlockPosition('draw', 'topright');
        map.pm.Toolbar.setBlockPosition('edit', 'topright');

        // remove unnecessary controls
        map.pm.addControls({
          drawMarker: false,
          drawCircleMarker: false,
          drawText: false,
          removalMode: false
        });
        if ( !enableGeomanControls ) {
          map.pm.addControls({
            drawPolyline: false,
            drawRectangle: false,
            drawPolygon: false,
            drawCircle: false,
            editMode: false,
            dragMode: false,
            cutPolygon: false,
            rotateMode: false,
            oneBlock: true
          })
        }

        // add consul marker to geoman controls
        if ( enableGeomanControls ) {
          map.pm.Toolbar.createCustomControl({
            name: 'consulMarker',
            className: 'control-icon leaflet-pm-icon-marker',
            title: 'Marker setzen',
            block: 'draw',
            onClick: function() {
              removeShapesAndMarkers();

              if (this.toggleStatus) {
                map.off("click", moveOrPlaceMarker);
              } else {
                map.on("click", moveOrPlaceMarker);
              }
            }
          });
        }

        // add remove consul marker to geoman controls
        map.pm.Toolbar.createCustomControl({
          name: 'clearMap',
          className: 'control-icon leaflet-pm-icon-delete',
          title: 'Clear Map',
          block: 'edit',
          onClick: function() {
            removeShapesAndMarkers();
            if ( enableGeomanControls ) {
              map.pm.Toolbar.toggleButton('clearMap', true);
              map.off("click", moveOrPlaceMarker);
            } else {
              map.pm.Toolbar.toggleButton('clearMap', false);
              map.pm.Toolbar.toggleButton('consulMarker', true);
              map.on("click", moveOrPlaceMarker);
            }
          },
          afterClick: function() {
            if (!enableGeomanControls) {
              $(".control-icon.leaflet-pm-icon-delete").closest(".active").removeClass("active")
            }

            if ( !adminEditor ) {
              $(latitudeInputSelector).val('');
              $(longitudeInputSelector).val('');
            }
          } 
        });

        // toggle consul marker button by default for regular users
        if ( !adminEditor ) {
          map.pm.Toolbar.toggleButton('consulMarker', true)
          map.on("click", moveOrPlaceMarker);
        }

        // reorder geoman controls
        map.pm.Toolbar.changeControlOrder([
          'consulMarker'
        ]);

        // set colors of shapes for admin
        if ( adminEditor ) {
          map.pm.setPathOptions({
            color: adminShapesColor,
            fillColor: adminShapesColor,
            fillOpacity: 0.4
          });
          map.pm.setGlobalOptions({
            templineStyle: { color: adminShapesColor },
            hintlineStyle: { color: adminShapesColor, dashArray: [5, 5]  }
          })
        }

        // remove past elements when new element is started, except for cutting
        map.on('pm:drawstart', function(e) {
          if (e.shape == 'Cut') {
            return
          }
          removeShapesAndMarkers();
        });

        // function to clear previously created shapes (only one shaped allowed)
        function removeShapesAndMarkers() {
          if (marker) {
            map.removeLayer(marker);
            marker = null;
          }

          map.pm.getGeomanLayers().forEach(function(layer) {
            if ( layer.pm.options.adminShape != true || adminEditor ) {
              layer.remove();
            }
          })

          $(shapeInputSelector).val({});
          $(showAdminShapeInputSelector).val(false);
        }

        // add newly created shape to form field
        map.on('pm:create', function(e) {
          var layer = e.layer;

          if (e.shape == 'Circle') {
            layer.options.shape = 'Circle'
          }

          updateShapeFieldInForm(layer);
          addEventListenersToShapeLayer(layer)
        })

        // update shape field in form
        var updateShapeFieldInForm = function(layer) {
          if (layer.options.shape == 'Circle') {
            layer = L.PM.Utils.circleToPolygon(layer, 60)
          }

          var shape = layer.toGeoJSON();
          var shapeString = JSON.stringify(shape);

          $(latitudeInputSelector).val(map.getCenter().lat);
          $(longitudeInputSelector).val(map.getCenter().lng);
          $(zoomInputSelector).val(map.getZoom());
          $(shapeInputSelector).val(shapeString);

          if (adminEditor) {
            $(showAdminShapeInputSelector).val(true);
          }
        };
      }
      /* Leaflet-Geoman plugin: config start */
    },

    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },

    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);
