define(['./Matrix3-315394f6', './combine-ca22a614', './AttributeCompression-b646d393', './Math-2dbd6b93', './IndexDatatype-a55ceaa1', './Matrix2-13178034', './createTaskProcessorWorker', './Check-666ab1a0', './defaultValue-0a909f67', './ComponentDatatype-f7b11d02', './WebGLConstants-a8cc3e8c', './RuntimeError-06c93819'], function (Matrix3, combine, AttributeCompression, Math, IndexDatatype, Matrix2, createTaskProcessorWorker, Check, defaultValue, ComponentDatatype, WebGLConstants, RuntimeError) {
  'use strict';

  var maxShort = 32767;
  var scratchBVCartographic = new Matrix3.Cartographic();
  var scratchEncodedPosition = new Matrix3.Cartesian3();
  function decodeVectorPolylinePositions(positions, rectangle, minimumHeight, maximumHeight, ellipsoid) {
    var positionsLength = positions.length / 3;
    var uBuffer = positions.subarray(0, positionsLength);
    var vBuffer = positions.subarray(positionsLength, 2 * positionsLength);
    var heightBuffer = positions.subarray(2 * positionsLength, 3 * positionsLength);
    AttributeCompression.AttributeCompression.zigZagDeltaDecode(uBuffer, vBuffer, heightBuffer);
    var decoded = new Float64Array(positions.length);
    for (var i = 0; i < positionsLength; ++i) {
      var u = uBuffer[i];
      var v = vBuffer[i];
      var h = heightBuffer[i];
      var lon = Math.CesiumMath.lerp(rectangle.west, rectangle.east, u / maxShort);
      var lat = Math.CesiumMath.lerp(rectangle.south, rectangle.north, v / maxShort);
      var alt = Math.CesiumMath.lerp(minimumHeight, maximumHeight, h / maxShort);
      var cartographic = Matrix3.Cartographic.fromRadians(lon, lat, alt, scratchBVCartographic);
      var decodedPosition = ellipsoid.cartographicToCartesian(cartographic, scratchEncodedPosition);
      Matrix3.Cartesian3.pack(decodedPosition, decoded, i * 3);
    }
    return decoded;
  }
  var scratchRectangle = new Matrix2.Rectangle();
  var scratchEllipsoid = new Matrix3.Ellipsoid();
  var scratchCenter = new Matrix3.Cartesian3();
  var scratchMinMaxHeights = {
    min: undefined,
    max: undefined
  };
  function unpackBuffer(packedBuffer) {
    packedBuffer = new Float64Array(packedBuffer);
    var offset = 0;
    scratchMinMaxHeights.min = packedBuffer[offset++];
    scratchMinMaxHeights.max = packedBuffer[offset++];
    Matrix2.Rectangle.unpack(packedBuffer, offset, scratchRectangle);
    offset += Matrix2.Rectangle.packedLength;
    Matrix3.Ellipsoid.unpack(packedBuffer, offset, scratchEllipsoid);
    offset += Matrix3.Ellipsoid.packedLength;
    Matrix3.Cartesian3.unpack(packedBuffer, offset, scratchCenter);
  }
  function getPositionOffsets(counts) {
    var countsLength = counts.length;
    var positionOffsets = new Uint32Array(countsLength + 1);
    var offset = 0;
    for (var i = 0; i < countsLength; ++i) {
      positionOffsets[i] = offset;
      offset += counts[i];
    }
    positionOffsets[countsLength] = offset;
    return positionOffsets;
  }
  var scratchP0 = new Matrix3.Cartesian3();
  var scratchP1 = new Matrix3.Cartesian3();
  var scratchPrev = new Matrix3.Cartesian3();
  var scratchCur = new Matrix3.Cartesian3();
  var scratchNext = new Matrix3.Cartesian3();
  function createVectorTilePolylines(parameters, transferableObjects) {
    var encodedPositions = new Uint16Array(parameters.positions);
    var widths = new Uint16Array(parameters.widths);
    var counts = new Uint32Array(parameters.counts);
    var batchIds = new Uint16Array(parameters.batchIds);
    unpackBuffer(parameters.packedBuffer);
    var rectangle = scratchRectangle;
    var ellipsoid = scratchEllipsoid;
    var center = scratchCenter;
    var minimumHeight = scratchMinMaxHeights.min;
    var maximumHeight = scratchMinMaxHeights.max;
    var positions = decodeVectorPolylinePositions(encodedPositions, rectangle, minimumHeight, maximumHeight, ellipsoid);
    var positionsLength = positions.length / 3;
    var size = positionsLength * 4 - 4;
    var curPositions = new Float32Array(size * 3);
    var prevPositions = new Float32Array(size * 3);
    var nextPositions = new Float32Array(size * 3);
    var expandAndWidth = new Float32Array(size * 2);
    var vertexBatchIds = new Uint16Array(size);
    var positionIndex = 0;
    var expandAndWidthIndex = 0;
    var batchIdIndex = 0;
    var i;
    var offset = 0;
    var length = counts.length;
    for (i = 0; i < length; ++i) {
      var count = counts[i];
      var width = widths[i];
      var batchId = batchIds[i];
      for (var j = 0; j < count; ++j) {
        var previous = void 0;
        if (j === 0) {
          var p0 = Matrix3.Cartesian3.unpack(positions, offset * 3, scratchP0);
          var p1 = Matrix3.Cartesian3.unpack(positions, (offset + 1) * 3, scratchP1);
          previous = Matrix3.Cartesian3.subtract(p0, p1, scratchPrev);
          Matrix3.Cartesian3.add(p0, previous, previous);
        } else {
          previous = Matrix3.Cartesian3.unpack(positions, (offset + j - 1) * 3, scratchPrev);
        }
        var current = Matrix3.Cartesian3.unpack(positions, (offset + j) * 3, scratchCur);
        var next = void 0;
        if (j === count - 1) {
          var p2 = Matrix3.Cartesian3.unpack(positions, (offset + count - 1) * 3, scratchP0);
          var p3 = Matrix3.Cartesian3.unpack(positions, (offset + count - 2) * 3, scratchP1);
          next = Matrix3.Cartesian3.subtract(p2, p3, scratchNext);
          Matrix3.Cartesian3.add(p2, next, next);
        } else {
          next = Matrix3.Cartesian3.unpack(positions, (offset + j + 1) * 3, scratchNext);
        }
        Matrix3.Cartesian3.subtract(previous, center, previous);
        Matrix3.Cartesian3.subtract(current, center, current);
        Matrix3.Cartesian3.subtract(next, center, next);
        var startK = j === 0 ? 2 : 0;
        var endK = j === count - 1 ? 2 : 4;
        for (var k = startK; k < endK; ++k) {
          Matrix3.Cartesian3.pack(current, curPositions, positionIndex);
          Matrix3.Cartesian3.pack(previous, prevPositions, positionIndex);
          Matrix3.Cartesian3.pack(next, nextPositions, positionIndex);
          positionIndex += 3;
          var direction = k - 2 < 0 ? -1.0 : 1.0;
          expandAndWidth[expandAndWidthIndex++] = 2 * (k % 2) - 1;
          expandAndWidth[expandAndWidthIndex++] = direction * width;
          vertexBatchIds[batchIdIndex++] = batchId;
        }
      }
      offset += count;
    }
    var indices = IndexDatatype.IndexDatatype.createTypedArray(size, positionsLength * 6 - 6);
    var index = 0;
    var indicesIndex = 0;
    length = positionsLength - 1;
    for (i = 0; i < length; ++i) {
      indices[indicesIndex++] = index;
      indices[indicesIndex++] = index + 2;
      indices[indicesIndex++] = index + 1;
      indices[indicesIndex++] = index + 1;
      indices[indicesIndex++] = index + 2;
      indices[indicesIndex++] = index + 3;
      index += 4;
    }
    transferableObjects.push(curPositions.buffer, prevPositions.buffer, nextPositions.buffer);
    transferableObjects.push(expandAndWidth.buffer, vertexBatchIds.buffer, indices.buffer);
    var results = {
      indexDatatype: indices.BYTES_PER_ELEMENT === 2 ? IndexDatatype.IndexDatatype.UNSIGNED_SHORT : IndexDatatype.IndexDatatype.UNSIGNED_INT,
      currentPositions: curPositions.buffer,
      previousPositions: prevPositions.buffer,
      nextPositions: nextPositions.buffer,
      expandAndWidth: expandAndWidth.buffer,
      batchIds: vertexBatchIds.buffer,
      indices: indices.buffer
    };
    if (parameters.keepDecodedPositions) {
      var positionOffsets = getPositionOffsets(counts);
      transferableObjects.push(positions.buffer, positionOffsets.buffer);
      results = combine.combine(results, {
        decodedPositions: positions.buffer,
        decodedPositionOffsets: positionOffsets.buffer
      });
    }
    return results;
  }
  var createVectorTilePolylines$1 = createTaskProcessorWorker(createVectorTilePolylines);
  return createVectorTilePolylines$1;
});