define(['./AttributeCompression-b646d393', './Matrix3-315394f6', './Math-2dbd6b93', './Matrix2-13178034', './createTaskProcessorWorker', './ComponentDatatype-f7b11d02', './defaultValue-0a909f67', './Check-666ab1a0', './WebGLConstants-a8cc3e8c', './RuntimeError-06c93819'], function (AttributeCompression, Matrix3, Math, Matrix2, createTaskProcessorWorker, ComponentDatatype, defaultValue, Check, WebGLConstants, RuntimeError) {
  'use strict';

  var maxShort = 32767;
  var scratchBVCartographic = new Matrix3.Cartographic();
  var scratchEncodedPosition = new Matrix3.Cartesian3();
  var scratchRectangle = new Matrix2.Rectangle();
  var scratchEllipsoid = new Matrix3.Ellipsoid();
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
  }
  function createVectorTilePoints(parameters, transferableObjects) {
    var positions = new Uint16Array(parameters.positions);
    unpackBuffer(parameters.packedBuffer);
    var rectangle = scratchRectangle;
    var ellipsoid = scratchEllipsoid;
    var minimumHeight = scratchMinMaxHeights.min;
    var maximumHeight = scratchMinMaxHeights.max;
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
    transferableObjects.push(decoded.buffer);
    return {
      positions: decoded.buffer
    };
  }
  var createVectorTilePoints$1 = createTaskProcessorWorker(createVectorTilePoints);
  return createVectorTilePoints$1;
});