define(['./createTaskProcessorWorker', './defaultValue-0a909f67', './WebMercatorProjection-13a90d41', './Matrix3-315394f6', './Math-2dbd6b93', './Check-666ab1a0'], function (createTaskProcessorWorker, defaultValue, WebMercatorProjection, Matrix3, Math$1, Check) {
  'use strict';

  /* global require */
  var draco;
  function bilinearInterpolate(tx, ty, h00, h10, h01, h11) {
    var a = h00 * (1 - tx) + h10 * tx;
    var b = h01 * (1 - tx) + h11 * tx;
    return a * (1 - ty) + b * ty;
  }
  function sampleMap(u, v, width, data) {
    var address = u + v * width;
    return data[address];
  }
  function sampleGeoid(sampleX, sampleY, geoidData) {
    var extent = geoidData.nativeExtent;
    var x = (sampleX - extent.west) / (extent.east - extent.west) * (geoidData.width - 1);
    var y = (sampleY - extent.south) / (extent.north - extent.south) * (geoidData.height - 1);
    var xi = Math.floor(x);
    var yi = Math.floor(y);
    x -= xi;
    y -= yi;
    var xNext = xi < geoidData.width ? xi + 1 : xi;
    var yNext = yi < geoidData.height ? yi + 1 : yi;
    yi = geoidData.height - 1 - yi;
    yNext = geoidData.height - 1 - yNext;
    var h00 = sampleMap(xi, yi, geoidData.width, geoidData.buffer);
    var h10 = sampleMap(xNext, yi, geoidData.width, geoidData.buffer);
    var h01 = sampleMap(xi, yNext, geoidData.width, geoidData.buffer);
    var h11 = sampleMap(xNext, yNext, geoidData.width, geoidData.buffer);
    var finalHeight = bilinearInterpolate(x, y, h00, h10, h01, h11);
    finalHeight = finalHeight * geoidData.scale + geoidData.offset;
    return finalHeight;
  }
  function sampleGeoidFromList(lon, lat, geoidDataList) {
    for (var i = 0; i < geoidDataList.length; i++) {
      var localExtent = geoidDataList[i].nativeExtent;
      var localPt = new Matrix3.Cartesian3();
      if (geoidDataList[i].projectionType === "WebMercator") {
        var radii = geoidDataList[i].projection._ellipsoid._radii;
        var webMercatorProj = new WebMercatorProjection.WebMercatorProjection(new Matrix3.Ellipsoid(radii.x, radii.y, radii.z));
        localPt = webMercatorProj.project(new Matrix3.Cartographic(lon, lat, 0));
      } else {
        localPt.x = lon;
        localPt.y = lat;
      }
      if (localPt.x > localExtent.west && localPt.x < localExtent.east && localPt.y > localExtent.south && localPt.y < localExtent.north) {
        return sampleGeoid(localPt.x, localPt.y, geoidDataList[i]);
      }
    }
    return 0;
  }
  function orthometricToEllipsoidal(vertexCount, position, scale_x, scale_y, center, geoidDataList, fast) {
    if (fast) {
      // Geometry is already relative to the tile origin which has already been shifted to account for geoid height
      // Nothing to do here
      return;
    }

    // For more precision, sample the geoid height at each vertex and shift by the difference between that value and the height at the center of the tile
    var centerHeight = sampleGeoidFromList(center.longitude, center.latitude, geoidDataList);
    for (var i = 0; i < vertexCount; ++i) {
      var height = sampleGeoidFromList(center.longitude + Math$1.CesiumMath.toRadians(scale_x * position[i * 3]), center.latitude + Math$1.CesiumMath.toRadians(scale_y * position[i * 3 + 1]), geoidDataList);
      position[i * 3 + 2] += height - centerHeight;
    }
  }
  function transformToLocal(vertexCount, positions, normals, cartographicCenter, cartesianCenter, parentRotation, ellipsoidRadiiSquare, scale_x, scale_y) {
    if (vertexCount === 0 || !defaultValue.defined(positions) || positions.length === 0) {
      return;
    }
    var ellipsoid = new Matrix3.Ellipsoid(Math.sqrt(ellipsoidRadiiSquare.x), Math.sqrt(ellipsoidRadiiSquare.y), Math.sqrt(ellipsoidRadiiSquare.z));
    for (var i = 0; i < vertexCount; ++i) {
      var indexOffset = i * 3;
      var indexOffset1 = indexOffset + 1;
      var indexOffset2 = indexOffset + 2;
      var cartographic = new Matrix3.Cartographic();
      cartographic.longitude = cartographicCenter.longitude + Math$1.CesiumMath.toRadians(scale_x * positions[indexOffset]);
      cartographic.latitude = cartographicCenter.latitude + Math$1.CesiumMath.toRadians(scale_y * positions[indexOffset1]);
      cartographic.height = cartographicCenter.height + positions[indexOffset2];
      var position = {};
      ellipsoid.cartographicToCartesian(cartographic, position);
      position.x -= cartesianCenter.x;
      position.y -= cartesianCenter.y;
      position.z -= cartesianCenter.z;
      var rotatedPosition = {};
      Matrix3.Matrix3.multiplyByVector(parentRotation, position, rotatedPosition);
      positions[indexOffset] = rotatedPosition.x;
      positions[indexOffset1] = rotatedPosition.y;
      positions[indexOffset2] = rotatedPosition.z;
      if (defaultValue.defined(normals)) {
        var normal = new Matrix3.Cartesian3(normals[indexOffset], normals[indexOffset1], normals[indexOffset2]);
        var rotatedNormal = {};
        Matrix3.Matrix3.multiplyByVector(parentRotation, normal, rotatedNormal);

        // TODO: check if normals are Z-UP or Y-UP and flip y and z
        normals[indexOffset] = rotatedNormal.x;
        normals[indexOffset1] = rotatedNormal.y;
        normals[indexOffset2] = rotatedNormal.z;
      }
    }
  }
  function cropUVs(vertexCount, uv0s, uvRegions) {
    for (var vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex) {
      var minU = uvRegions[vertexIndex * 4] / 65535.0;
      var minV = uvRegions[vertexIndex * 4 + 1] / 65535.0;
      var scaleU = (uvRegions[vertexIndex * 4 + 2] - uvRegions[vertexIndex * 4]) / 65535.0;
      var scaleV = (uvRegions[vertexIndex * 4 + 3] - uvRegions[vertexIndex * 4 + 1]) / 65535.0;
      uv0s[vertexIndex * 2] *= scaleU;
      uv0s[vertexIndex * 2] += minU;
      uv0s[vertexIndex * 2 + 1] *= scaleV;
      uv0s[vertexIndex * 2 + 1] += minV;
    }
  }
  function generateGltfBuffer(vertexCount, indices, positions, normals, uv0s, colors) {
    if (vertexCount === 0 || !defaultValue.defined(positions) || positions.length === 0) {
      return {
        buffers: [],
        bufferViews: [],
        accessors: [],
        meshes: [],
        nodes: [],
        nodesInScene: []
      };
    }
    var buffers = [];
    var bufferViews = [];
    var accessors = [];
    var meshes = [];
    var nodes = [];
    var nodesInScene = [];

    // If we provide indices, then the vertex count is the length
    // of that array, otherwise we assume non-indexed triangle
    if (defaultValue.defined(indices)) {
      vertexCount = indices.length;
    }

    // Allocate array
    var indexArray = new Uint32Array(vertexCount);
    if (defaultValue.defined(indices)) {
      // Set the indices
      for (var vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex) {
        indexArray[vertexIndex] = indices[vertexIndex];
      }
    } else {
      // Generate indices
      for (var newVertexIndex = 0; newVertexIndex < vertexCount; ++newVertexIndex) {
        indexArray[newVertexIndex] = newVertexIndex;
      }
    }

    // Push to the buffers, bufferViews and accessors
    var indicesBlob = new Blob([indexArray], {
      type: "application/binary"
    });
    var indicesURL = URL.createObjectURL(indicesBlob);
    var endIndex = vertexCount;

    // POSITIONS
    var meshPositions = positions.subarray(0, endIndex * 3);
    var positionsBlob = new Blob([meshPositions], {
      type: "application/binary"
    });
    var positionsURL = URL.createObjectURL(positionsBlob);
    var minX = Number.POSITIVE_INFINITY;
    var maxX = Number.NEGATIVE_INFINITY;
    var minY = Number.POSITIVE_INFINITY;
    var maxY = Number.NEGATIVE_INFINITY;
    var minZ = Number.POSITIVE_INFINITY;
    var maxZ = Number.NEGATIVE_INFINITY;
    for (var i = 0; i < meshPositions.length / 3; i++) {
      minX = Math.min(minX, meshPositions[i * 3 + 0]);
      maxX = Math.max(maxX, meshPositions[i * 3 + 0]);
      minY = Math.min(minY, meshPositions[i * 3 + 1]);
      maxY = Math.max(maxY, meshPositions[i * 3 + 1]);
      minZ = Math.min(minZ, meshPositions[i * 3 + 2]);
      maxZ = Math.max(maxZ, meshPositions[i * 3 + 2]);
    }

    // NORMALS
    var meshNormals = normals ? normals.subarray(0, endIndex * 3) : undefined;
    var normalsURL;
    if (defaultValue.defined(meshNormals)) {
      var normalsBlob = new Blob([meshNormals], {
        type: "application/binary"
      });
      normalsURL = URL.createObjectURL(normalsBlob);
    }

    // UV0s
    var meshUv0s = uv0s ? uv0s.subarray(0, endIndex * 2) : undefined;
    var uv0URL;
    if (defaultValue.defined(meshUv0s)) {
      var uv0Blob = new Blob([meshUv0s], {
        type: "application/binary"
      });
      uv0URL = URL.createObjectURL(uv0Blob);
    }

    // COLORS
    var meshColorsInBytes = defaultValue.defined(colors) ? colors.subarray(0, endIndex * 4) : undefined;
    var colorsURL;
    if (defaultValue.defined(meshColorsInBytes)) {
      var colorsBlob = new Blob([meshColorsInBytes], {
        type: "application/binary"
      });
      colorsURL = URL.createObjectURL(colorsBlob);
    }
    var posIndex = 0;
    var normalIndex = 0;
    var uv0Index = 0;
    var colorIndex = 0;
    var indicesIndex = 0;
    var currentIndex = posIndex;
    var attributes = {};

    // POSITIONS
    attributes.POSITION = posIndex;
    buffers.push({
      uri: positionsURL,
      byteLength: meshPositions.byteLength
    });
    bufferViews.push({
      buffer: posIndex,
      byteOffset: 0,
      byteLength: meshPositions.byteLength,
      target: 34962
    });
    accessors.push({
      bufferView: posIndex,
      byteOffset: 0,
      componentType: 5126,
      count: vertexCount,
      type: "VEC3",
      max: [minX, minY, minZ],
      min: [maxX, maxY, maxZ]
    });

    // NORMALS
    if (defaultValue.defined(normalsURL)) {
      ++currentIndex;
      normalIndex = currentIndex;
      attributes.NORMAL = normalIndex;
      buffers.push({
        uri: normalsURL,
        byteLength: meshNormals.byteLength
      });
      bufferViews.push({
        buffer: normalIndex,
        byteOffset: 0,
        byteLength: meshNormals.byteLength,
        target: 34962
      });
      accessors.push({
        bufferView: normalIndex,
        byteOffset: 0,
        componentType: 5126,
        count: vertexCount,
        type: "VEC3"
      });
    }

    // UV0
    if (defaultValue.defined(uv0URL)) {
      ++currentIndex;
      uv0Index = currentIndex;
      attributes.TEXCOORD_0 = uv0Index;
      buffers.push({
        uri: uv0URL,
        byteLength: meshUv0s.byteLength
      });
      bufferViews.push({
        buffer: uv0Index,
        byteOffset: 0,
        byteLength: meshUv0s.byteLength,
        target: 34962
      });
      accessors.push({
        bufferView: uv0Index,
        byteOffset: 0,
        componentType: 5126,
        count: vertexCount,
        type: "VEC2"
      });
    }

    // COLORS
    if (defaultValue.defined(colorsURL)) {
      ++currentIndex;
      colorIndex = currentIndex;
      attributes.COLOR_0 = colorIndex;
      buffers.push({
        uri: colorsURL,
        byteLength: meshColorsInBytes.byteLength
      });
      bufferViews.push({
        buffer: colorIndex,
        byteOffset: 0,
        byteLength: meshColorsInBytes.byteLength,
        target: 34962
      });
      accessors.push({
        bufferView: colorIndex,
        byteOffset: 0,
        componentType: 5121,
        normalized: true,
        count: vertexCount,
        type: "VEC4"
      });
    }

    // INDICES
    ++currentIndex;
    indicesIndex = currentIndex;
    buffers.push({
      uri: indicesURL,
      byteLength: indexArray.byteLength
    });
    bufferViews.push({
      buffer: indicesIndex,
      byteOffset: 0,
      byteLength: indexArray.byteLength,
      target: 34963
    });
    accessors.push({
      bufferView: indicesIndex,
      byteOffset: 0,
      componentType: 5125,
      count: vertexCount,
      type: "SCALAR"
    });

    // Create a new mesh for this page
    meshes.push({
      primitives: [{
        attributes: attributes,
        indices: indicesIndex,
        material: 0
      }]
    });
    nodesInScene.push(0);
    nodes.push({
      mesh: 0
    });
    return {
      buffers: buffers,
      bufferViews: bufferViews,
      accessors: accessors,
      meshes: meshes,
      nodes: nodes,
      nodesInScene: nodesInScene
    };
  }
  function decode(data, schema, bufferInfo, featureData) {
    var magicNumber = new Uint8Array(data, 0, 5);
    if (magicNumber[0] === "D".charCodeAt() && magicNumber[1] === "R".charCodeAt() && magicNumber[2] === "A".charCodeAt() && magicNumber[3] === "C".charCodeAt() && magicNumber[4] === "O".charCodeAt()) {
      return decodeDracoEncodedGeometry(data);
    }
    return decodeBinaryGeometry(data, schema, bufferInfo, featureData);
  }
  function decodeDracoEncodedGeometry(data) {
    // Create the Draco decoder.
    var dracoDecoderModule = draco;
    var buffer = new dracoDecoderModule.DecoderBuffer();
    var byteArray = new Uint8Array(data);
    buffer.Init(byteArray, byteArray.length);

    // Create a buffer to hold the encoded data.
    var dracoDecoder = new dracoDecoderModule.Decoder();
    var geometryType = dracoDecoder.GetEncodedGeometryType(buffer);
    var metadataQuerier = new dracoDecoderModule.MetadataQuerier();

    // Decode the encoded geometry.
    // See: https://github.com/google/draco/blob/master/src/draco/javascript/emscripten/draco_web_decoder.idl
    var dracoGeometry;
    var status;
    if (geometryType === dracoDecoderModule.TRIANGULAR_MESH) {
      dracoGeometry = new dracoDecoderModule.Mesh();
      status = dracoDecoder.DecodeBufferToMesh(buffer, dracoGeometry);
    }
    var decodedGeometry = {
      vertexCount: [0],
      featureCount: 0
    };

    // if all is OK
    if (defaultValue.defined(status) && status.ok() && dracoGeometry.ptr !== 0) {
      var faceCount = dracoGeometry.num_faces();
      var attributesCount = dracoGeometry.num_attributes();
      var vertexCount = dracoGeometry.num_points();
      decodedGeometry.indices = new Uint32Array(faceCount * 3);
      var faces = decodedGeometry.indices;
      decodedGeometry.vertexCount[0] = vertexCount;
      decodedGeometry.scale_x = 1;
      decodedGeometry.scale_y = 1;

      // Decode faces
      // @TODO: Replace that code with GetTrianglesUInt32Array for better efficiency
      var face = new dracoDecoderModule.DracoInt32Array(3);
      for (var faceIndex = 0; faceIndex < faceCount; ++faceIndex) {
        dracoDecoder.GetFaceFromMesh(dracoGeometry, faceIndex, face);
        faces[faceIndex * 3] = face.GetValue(0);
        faces[faceIndex * 3 + 1] = face.GetValue(1);
        faces[faceIndex * 3 + 2] = face.GetValue(2);
      }
      dracoDecoderModule.destroy(face);
      for (var attrIndex = 0; attrIndex < attributesCount; ++attrIndex) {
        var dracoAttribute = dracoDecoder.GetAttribute(dracoGeometry, attrIndex);
        var attributeData = decodeDracoAttribute(dracoDecoderModule, dracoDecoder, dracoGeometry, dracoAttribute, vertexCount);

        // initial mapping
        var dracoAttributeType = dracoAttribute.attribute_type();
        var attributei3sName = "unknown";
        if (dracoAttributeType === dracoDecoderModule.POSITION) {
          attributei3sName = "positions";
        } else if (dracoAttributeType === dracoDecoderModule.NORMAL) {
          attributei3sName = "normals";
        } else if (dracoAttributeType === dracoDecoderModule.COLOR) {
          attributei3sName = "colors";
        } else if (dracoAttributeType === dracoDecoderModule.TEX_COORD) {
          attributei3sName = "uv0s";
        }

        // get the metadata
        var metadata = dracoDecoder.GetAttributeMetadata(dracoGeometry, attrIndex);
        if (metadata.ptr !== 0) {
          var numEntries = metadataQuerier.NumEntries(metadata);
          for (var entry = 0; entry < numEntries; ++entry) {
            var entryName = metadataQuerier.GetEntryName(metadata, entry);
            if (entryName === "i3s-scale_x") {
              decodedGeometry.scale_x = metadataQuerier.GetDoubleEntry(metadata, "i3s-scale_x");
            } else if (entryName === "i3s-scale_y") {
              decodedGeometry.scale_y = metadataQuerier.GetDoubleEntry(metadata, "i3s-scale_y");
            } else if (entryName === "i3s-attribute-type") {
              attributei3sName = metadataQuerier.GetStringEntry(metadata, "i3s-attribute-type");
            }
          }
        }
        if (defaultValue.defined(decodedGeometry[attributei3sName])) {
          console.log("Attribute already exists", attributei3sName);
        }
        decodedGeometry[attributei3sName] = attributeData;
        if (attributei3sName === "feature-index") {
          decodedGeometry.featureCount++;
        }
      }
      dracoDecoderModule.destroy(dracoGeometry);
    }
    dracoDecoderModule.destroy(metadataQuerier);
    dracoDecoderModule.destroy(dracoDecoder);
    return decodedGeometry;
  }
  function decodeDracoAttribute(dracoDecoderModule, dracoDecoder, dracoGeometry, dracoAttribute, vertexCount) {
    var bufferSize = dracoAttribute.num_components() * vertexCount;
    var dracoAttributeData;
    var handlers = [function () {},
    // DT_INVALID - 0
    function () {
      // DT_INT8 - 1
      dracoAttributeData = new dracoDecoderModule.DracoInt8Array(bufferSize);
      var success = dracoDecoder.GetAttributeInt8ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Int8Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_UINT8 - 2
      dracoAttributeData = new dracoDecoderModule.DracoInt8Array(bufferSize);
      var success = dracoDecoder.GetAttributeUInt8ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Uint8Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_INT16 - 3
      dracoAttributeData = new dracoDecoderModule.DracoInt16Array(bufferSize);
      var success = dracoDecoder.GetAttributeInt16ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Int16Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_UINT16 - 4
      dracoAttributeData = new dracoDecoderModule.DracoInt16Array(bufferSize);
      var success = dracoDecoder.GetAttributeUInt16ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Uint16Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_INT32 - 5
      dracoAttributeData = new dracoDecoderModule.DracoInt32Array(bufferSize);
      var success = dracoDecoder.GetAttributeInt32ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Int32Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_UINT32 - 6
      dracoAttributeData = new dracoDecoderModule.DracoInt32Array(bufferSize);
      var success = dracoDecoder.GetAttributeUInt32ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Uint32Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_INT64 - 7
    }, function () {
      // DT_UINT64 - 8
    }, function () {
      // DT_FLOAT32 - 9
      dracoAttributeData = new dracoDecoderModule.DracoFloat32Array(bufferSize);
      var success = dracoDecoder.GetAttributeFloatForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Float32Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }, function () {
      // DT_FLOAT64 - 10
    }, function () {
      // DT_FLOAT32 - 11
      dracoAttributeData = new dracoDecoderModule.DracoUInt8Array(bufferSize);
      var success = dracoDecoder.GetAttributeUInt8ForAllPoints(dracoGeometry, dracoAttribute, dracoAttributeData);
      if (!success) {
        console.error("Bad stream");
      }
      var attributeData = new Uint8Array(bufferSize);
      for (var i = 0; i < bufferSize; ++i) {
        attributeData[i] = dracoAttributeData.GetValue(i);
      }
      return attributeData;
    }];
    var attributeData = handlers[dracoAttribute.data_type()]();
    if (defaultValue.defined(dracoAttributeData)) {
      dracoDecoderModule.destroy(dracoAttributeData);
    }
    return attributeData;
  }
  var binaryAttributeDecoders = {
    position: function position(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 3;
      decodedGeometry.positions = new Float32Array(data, offset, count);
      offset += count * 4;
      return offset;
    },
    normal: function normal(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 3;
      decodedGeometry.normals = new Float32Array(data, offset, count);
      offset += count * 4;
      return offset;
    },
    uv0: function uv0(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 2;
      decodedGeometry.uv0s = new Float32Array(data, offset, count);
      offset += count * 4;
      return offset;
    },
    color: function color(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 4;
      decodedGeometry.colors = new Uint8Array(data, offset, count);
      offset += count;
      return offset;
    },
    featureId: function featureId(decodedGeometry, data, offset) {
      // We don't need to use this for anything so just increment the offset
      var count = decodedGeometry.featureCount;
      offset += count * 8;
      return offset;
    },
    id: function id(decodedGeometry, data, offset) {
      // We don't need to use this for anything so just increment the offset
      var count = decodedGeometry.featureCount;
      offset += count * 8;
      return offset;
    },
    faceRange: function faceRange(decodedGeometry, data, offset) {
      var count = decodedGeometry.featureCount * 2;
      decodedGeometry.faceRange = new Uint32Array(data, offset, count);
      offset += count * 4;
      return offset;
    },
    uvRegion: function uvRegion(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 4;
      decodedGeometry["uv-region"] = new Uint16Array(data, offset, count);
      offset += count * 2;
      return offset;
    },
    region: function region(decodedGeometry, data, offset) {
      var count = decodedGeometry.vertexCount * 4;
      decodedGeometry["uv-region"] = new Uint16Array(data, offset, count);
      offset += count * 2;
      return offset;
    }
  };
  function decodeBinaryGeometry(data, schema, bufferInfo, featureData) {
    // From this spec:
    // https://github.com/Esri/i3s-spec/blob/master/docs/1.7/defaultGeometrySchema.cmn.md
    var decodedGeometry = {
      vertexCount: 0
    };
    var dataView = new DataView(data);
    try {
      var offset = 0;
      decodedGeometry.vertexCount = dataView.getUint32(offset, 1);
      offset += 4;
      decodedGeometry.featureCount = dataView.getUint32(offset, 1);
      offset += 4;
      if (defaultValue.defined(bufferInfo)) {
        for (var attrIndex = 0; attrIndex < bufferInfo.attributes.length; attrIndex++) {
          if (defaultValue.defined(binaryAttributeDecoders[bufferInfo.attributes[attrIndex]])) {
            offset = binaryAttributeDecoders[bufferInfo.attributes[attrIndex]](decodedGeometry, data, offset);
          } else {
            console.error("Unknown decoder for", bufferInfo.attributes[attrIndex]);
          }
        }
      } else {
        var ordering = schema.ordering;
        var featureAttributeOrder = schema.featureAttributeOrder;
        if (defaultValue.defined(featureData) && defaultValue.defined(featureData.geometryData) && defaultValue.defined(featureData.geometryData[0]) && defaultValue.defined(featureData.geometryData[0].params)) {
          ordering = Object.keys(featureData.geometryData[0].params.vertexAttributes);
          featureAttributeOrder = Object.keys(featureData.geometryData[0].params.featureAttributes);
        }

        // Use default geometry schema
        for (var i = 0; i < ordering.length; i++) {
          var decoder = binaryAttributeDecoders[ordering[i]];
          if (!defaultValue.defined(decoder)) {
            console.log(ordering[i]);
          }
          offset = decoder(decodedGeometry, data, offset);
        }
        for (var j = 0; j < featureAttributeOrder.length; j++) {
          var curDecoder = binaryAttributeDecoders[featureAttributeOrder[j]];
          if (!defaultValue.defined(curDecoder)) {
            console.log(featureAttributeOrder[j]);
          }
          offset = curDecoder(decodedGeometry, data, offset);
        }
      }
    } catch (e) {
      console.error(e);
    }
    decodedGeometry.scale_x = 1;
    decodedGeometry.scale_y = 1;
    return decodedGeometry;
  }
  function decodeI3S(parameters) {
    // Decode the data into geometry
    var geometryData = decode(parameters.binaryData, parameters.schema, parameters.bufferInfo, parameters.featureData);

    // Adjust height from orthometric to ellipsoidal
    if (defaultValue.defined(parameters.geoidDataList) && parameters.geoidDataList.length > 0) {
      orthometricToEllipsoidal(geometryData.vertexCount, geometryData.positions, geometryData.scale_x, geometryData.scale_y, parameters.cartographicCenter, parameters.geoidDataList, false);
    }

    // Transform vertices to local
    transformToLocal(geometryData.vertexCount, geometryData.positions, geometryData.normals, parameters.cartographicCenter, parameters.cartesianCenter, parameters.parentRotation, parameters.ellipsoidRadiiSquare, geometryData.scale_x, geometryData.scale_y);

    // Adjust UVs if there is a UV region
    if (defaultValue.defined(geometryData.uv0s) && defaultValue.defined(geometryData["uv-region"])) {
      cropUVs(geometryData.vertexCount, geometryData.uv0s, geometryData["uv-region"]);
    }

    // Create the final buffer
    var meshData = generateGltfBuffer(geometryData.vertexCount, geometryData.indices, geometryData.positions, geometryData.normals, geometryData.uv0s, geometryData.colors);
    var customAttributes = {};
    if (defaultValue.defined(geometryData["feature-index"])) {
      customAttributes.positions = geometryData.positions;
      customAttributes.indices = geometryData.indices;
      customAttributes.featureIndex = geometryData["feature-index"];
      customAttributes.cartesianCenter = parameters.cartesianCenter;
      customAttributes.parentRotation = parameters.parentRotation;
    } else if (defaultValue.defined(geometryData["faceRange"])) {
      customAttributes.positions = geometryData.positions;
      customAttributes.indices = geometryData.indices;
      customAttributes.sourceURL = parameters.url;
      customAttributes.cartesianCenter = parameters.cartesianCenter;
      customAttributes.parentRotation = parameters.parentRotation;

      // Build the feature index array from the faceRange.
      customAttributes.featureIndex = new Array(geometryData.positions.length);
      for (var range = 0; range < geometryData["faceRange"].length - 1; range += 2) {
        var curIndex = range / 2;
        var rangeStart = geometryData["faceRange"][range];
        var rangeEnd = geometryData["faceRange"][range + 1];
        for (var i = rangeStart; i <= rangeEnd; i++) {
          customAttributes.featureIndex[i * 3] = curIndex;
          customAttributes.featureIndex[i * 3 + 1] = curIndex;
          customAttributes.featureIndex[i * 3 + 2] = curIndex;
        }
      }
    }
    meshData._customAttributes = customAttributes;
    var results = {
      meshData: meshData
    };
    return results;
  }
  function initWorker(dracoModule) {
    draco = dracoModule;
    self.onmessage = createTaskProcessorWorker(decodeI3S);
    self.postMessage(true);
  }
  function decodeI3SStart(event) {
    var data = event.data;

    // Expect the first message to be to load a web assembly module
    var wasmConfig = data.webAssemblyConfig;
    if (defaultValue.defined(wasmConfig)) {
      // Require and compile WebAssembly module, or use fallback if not supported
      return require([wasmConfig.modulePath], function (dracoModule) {
        if (defaultValue.defined(wasmConfig.wasmBinaryFile)) {
          if (!defaultValue.defined(dracoModule)) {
            dracoModule = self.DracoDecoderModule;
          }
          dracoModule(wasmConfig).then(function (compiledModule) {
            initWorker(compiledModule);
          });
        } else {
          initWorker(dracoModule());
        }
      });
    }
  }
  return decodeI3SStart;
});