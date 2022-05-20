(function() {
  "use strict";
  App.Map = {
    maps: [],
    initialize: function() {
      $("*[data-map]").each(function() {
        App.Map.initializeMap(this);
      });
      $(".js-toggle-map").on({
        click: function() {
          App.Map.toggleMap();
        }
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
      var addMarker, clearFormfields, createMarker, editable, getPopupContent, latitudeInputSelector, longitudeInputSelector, map, mapAttribution, mapCenterLatLng, mapCenterLatitude, mapCenterLongitude, mapTilesProvider, marker, markerIcon, markerLatitude, markerLongitude, markerColor, markerIconClass, moveOrPlaceMarker, openMarkerPopup, removeMarker, removeMarkerSelector, updateFormfields, zoom, zoomInputSelector, process, markersGroup, layersData;
      process = $(element).data("parent-class");
      App.Map.cleanCoordinates(element);
      mapCenterLatitude = $(element).data("map-center-latitude");
      mapCenterLongitude = $(element).data("map-center-longitude");
      markerLatitude = $(element).data("marker-latitude");
      markerLongitude = $(element).data("marker-longitude");
      markerColor = $(element).data("marker-color");
      markerIconClass = $(element).data("marker-fa-icon-class")
      zoom = $(element).data("map-zoom");
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");
      latitudeInputSelector = $(element).data("latitude-input-selector");
      longitudeInputSelector = $(element).data("longitude-input-selector");
      zoomInputSelector = $(element).data("zoom-input-selector");
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarker = $(element).data("marker-process-coordinates");
      editable = $(element).data("marker-editable");
      marker = null;
      markersGroup = L.markerClusterGroup();

      layersData = $(element).data('map-layers');

      createMarker = function(latitude, longitude, color, iconClass) {
        if ( !iconClass ) {
          iconClass = 'circle';
        } else {
          iconClass = iconClass
        };

        var markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);

        markerIcon = L.divIcon({
          className: "map-marker",
          iconSize: [30, 30],
          iconAnchor: [15, 40]
        });

        if ( color ) {
          markerIcon.options.html = '<div class="map-icon icon-' + iconClass + '" style="background-color: ' + color + '"></div>'
        } else {
          markerIcon.options.html = '<div class="map-icon icon-' + iconClass + '"></div>'
        }

        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });

        if (editable) {
          marker.on("dragend", updateFormfields);
          marker.addTo(map);
        } else {
          markersGroup.addLayer(marker);
        }

        return marker;
      };

      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        clearFormfields();
      };

      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfields();
      };

      updateFormfields = function() {
        $(latitudeInputSelector).val(marker.getLatLng().lat);
        $(longitudeInputSelector).val(marker.getLatLng().lng);
        $(zoomInputSelector).val(map.getZoom());
      };

      clearFormfields = function() {
        $(latitudeInputSelector).val("");
        $(longitudeInputSelector).val("");
        $(zoomInputSelector).val("");
      };

      openMarkerPopup = function(e) {
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

      // TODO: add projekts link
      getPopupContent = function(data) {
        if (process == "proposals") {
          return "<a href='/proposals/" + data.proposal_id + "'>" + data.proposal_title + "</a>";
        } else if ( process == "deficiency-reports" ) {
          return "<a href='/deficiency_reports/" + data.deficiency_report_id + "'>" + data.deficiency_report_title + "</a>";
        } else if ( process == "projekts" ) {
          return "<a href='/projekts/" + data.projekt_id + "'>" + data.projekt_title + "</a>";
        } else {
          return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
        }
      };

      mapCenterLatLng = new L.LatLng(mapCenterLatitude, mapCenterLongitude);

      map = L.map(element.id, {
        gestureHandling: true,
        maxZoom: 18
      }).setView(mapCenterLatLng, zoom);


      if ( !editable ) {
        map._layersMaxZoom = 19;
        map.addLayer(markersGroup);
      }

      App.Map.maps.push(map);



///

      var baseLayers = {};
      var overlayLayers = {};

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

      var ensureBaseLayerExistence = function() {
        if ( Object.keys(baseLayers).length === 0 ) {
          var defaultLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors'
          });

          baseLayers['defaultLayer'] = defaultLayer;
        }
      }

      if ( typeof layersData !== "undefined"  ) {
        layersData.forEach(createLayer);
      }

      if ( Object.keys(overlayLayers).length > 0 ) {
        for (let i = 0; i < Object.keys(overlayLayers).length; i++ ) {
          if ( overlayLayers[Object.keys(overlayLayers)[i]].options.show_by_default == true ) {
            overlayLayers[Object.keys(overlayLayers)[i]].addTo(map)
          }
        }

        L.control.layers(baseLayers, overlayLayers).addTo(map);
      }

      ensureBaseLayerExistence();
      baseLayers[Object.keys(baseLayers)[0]].addTo(map);

///


      var search = new GeoSearch.GeoSearchControl({
        provider: new GeoSearch.OpenStreetMapProvider(),
        style: 'bar',
        showMarker: false,
        searchLabel: 'Nach Adresse suchen',
        notFoundMessage: 'Entschuldigung! Die Adresse wurde nicht gefunden.',
      });

      map.addControl(search);

      L.control.locate({icon: 'fa fa-map-marker'}).addTo(map);


      if (markerLatitude && markerLongitude && !addMarker) {
        marker = createMarker(markerLatitude, markerLongitude, markerColor, markerIconClass);
      }

      if (editable) {
        $('.js-select-projekt').on("click", removeMarker);
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            updateFormfields();
          }
        });
        map.on("click", moveOrPlaceMarker);
      }

      if (addMarker) {
        addMarker.forEach(function(coordinates) {
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
          }
        });
      }
    },

    toggleMap: function() {
      $(".map").toggle();
      $(".js-location-map-remove-marker").toggle();
    },

    cleanCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-process-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-process-coordinates", clean_markers);
      }
    },

    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },

    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);
