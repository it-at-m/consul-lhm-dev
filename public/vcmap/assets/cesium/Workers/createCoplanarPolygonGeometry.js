define(['./arrayRemoveDuplicates-c2038105', './BoundingRectangle-be5924f4', './Transforms-40229881', './Matrix2-13178034', './Matrix3-315394f6', './Check-666ab1a0', './ComponentDatatype-f7b11d02', './CoplanarPolygonGeometryLibrary-3272c1b3', './defaultValue-0a909f67', './GeometryAttribute-7d6f1732', './GeometryAttributes-f06a2792', './GeometryInstance-451dc1cd', './GeometryPipeline-ce4339ed', './IndexDatatype-a55ceaa1', './Math-2dbd6b93', './PolygonGeometryLibrary-a8680d96', './PolygonPipeline-844aab0a', './VertexFormat-6b480673', './combine-ca22a614', './RuntimeError-06c93819', './WebGLConstants-a8cc3e8c', './OrientedBoundingBox-04920dc7', './EllipsoidTangentPlane-214683dc', './AxisAlignedBoundingBox-ff186ccc', './IntersectionTests-f6e6bd8a', './Plane-900aa728', './AttributeCompression-b646d393', './EncodedCartesian3-81f70735', './ArcType-ce2e50ab', './EllipsoidRhumbLine-19756602'], function (arrayRemoveDuplicates, BoundingRectangle, Transforms, Matrix2, Matrix3, Check, ComponentDatatype, CoplanarPolygonGeometryLibrary, defaultValue, GeometryAttribute, GeometryAttributes, GeometryInstance, GeometryPipeline, IndexDatatype, Math, PolygonGeometryLibrary, PolygonPipeline, VertexFormat, combine, RuntimeError, WebGLConstants, OrientedBoundingBox, EllipsoidTangentPlane, AxisAlignedBoundingBox, IntersectionTests, Plane, AttributeCompression, EncodedCartesian3, ArcType, EllipsoidRhumbLine) {
  'use strict';

  var scratchPosition = new Matrix3.Cartesian3();
  var scratchBR = new BoundingRectangle.BoundingRectangle();
  var stScratch = new Matrix2.Cartesian2();
  var textureCoordinatesOrigin = new Matrix2.Cartesian2();
  var scratchNormal = new Matrix3.Cartesian3();
  var scratchTangent = new Matrix3.Cartesian3();
  var scratchBitangent = new Matrix3.Cartesian3();
  var centerScratch = new Matrix3.Cartesian3();
  var axis1Scratch = new Matrix3.Cartesian3();
  var axis2Scratch = new Matrix3.Cartesian3();
  var quaternionScratch = new Transforms.Quaternion();
  var textureMatrixScratch = new Matrix3.Matrix3();
  var tangentRotationScratch = new Matrix3.Matrix3();
  var surfaceNormalScratch = new Matrix3.Cartesian3();
  function createGeometryFromPolygon(polygon, vertexFormat, boundingRectangle, stRotation, hardcodedTextureCoordinates, projectPointTo2D, normal, tangent, bitangent) {
    var positions = polygon.positions;
    var indices = PolygonPipeline.PolygonPipeline.triangulate(polygon.positions2D, polygon.holes);

    /* If polygon is completely unrenderable, just use the first three vertices */
    if (indices.length < 3) {
      indices = [0, 1, 2];
    }
    var newIndices = IndexDatatype.IndexDatatype.createTypedArray(positions.length, indices.length);
    newIndices.set(indices);
    var textureMatrix = textureMatrixScratch;
    if (stRotation !== 0.0) {
      var rotation = Transforms.Quaternion.fromAxisAngle(normal, stRotation, quaternionScratch);
      textureMatrix = Matrix3.Matrix3.fromQuaternion(rotation, textureMatrix);
      if (vertexFormat.tangent || vertexFormat.bitangent) {
        rotation = Transforms.Quaternion.fromAxisAngle(normal, -stRotation, quaternionScratch);
        var tangentRotation = Matrix3.Matrix3.fromQuaternion(rotation, tangentRotationScratch);
        tangent = Matrix3.Cartesian3.normalize(Matrix3.Matrix3.multiplyByVector(tangentRotation, tangent, tangent), tangent);
        if (vertexFormat.bitangent) {
          bitangent = Matrix3.Cartesian3.normalize(Matrix3.Cartesian3.cross(normal, tangent, bitangent), bitangent);
        }
      }
    } else {
      textureMatrix = Matrix3.Matrix3.clone(Matrix3.Matrix3.IDENTITY, textureMatrix);
    }
    var stOrigin = textureCoordinatesOrigin;
    if (vertexFormat.st) {
      stOrigin.x = boundingRectangle.x;
      stOrigin.y = boundingRectangle.y;
    }
    var length = positions.length;
    var size = length * 3;
    var flatPositions = new Float64Array(size);
    var normals = vertexFormat.normal ? new Float32Array(size) : undefined;
    var tangents = vertexFormat.tangent ? new Float32Array(size) : undefined;
    var bitangents = vertexFormat.bitangent ? new Float32Array(size) : undefined;
    var textureCoordinates = vertexFormat.st ? new Float32Array(length * 2) : undefined;
    var positionIndex = 0;
    var normalIndex = 0;
    var bitangentIndex = 0;
    var tangentIndex = 0;
    var stIndex = 0;
    for (var i = 0; i < length; i++) {
      var position = positions[i];
      flatPositions[positionIndex++] = position.x;
      flatPositions[positionIndex++] = position.y;
      flatPositions[positionIndex++] = position.z;
      if (vertexFormat.st) {
        if (defaultValue.defined(hardcodedTextureCoordinates) && hardcodedTextureCoordinates.positions.length === length) {
          textureCoordinates[stIndex++] = hardcodedTextureCoordinates.positions[i].x;
          textureCoordinates[stIndex++] = hardcodedTextureCoordinates.positions[i].y;
        } else {
          var p = Matrix3.Matrix3.multiplyByVector(textureMatrix, position, scratchPosition);
          var st = projectPointTo2D(p, stScratch);
          Matrix2.Cartesian2.subtract(st, stOrigin, st);
          var stx = Math.CesiumMath.clamp(st.x / boundingRectangle.width, 0, 1);
          var sty = Math.CesiumMath.clamp(st.y / boundingRectangle.height, 0, 1);
          textureCoordinates[stIndex++] = stx;
          textureCoordinates[stIndex++] = sty;
        }
      }
      if (vertexFormat.normal) {
        normals[normalIndex++] = normal.x;
        normals[normalIndex++] = normal.y;
        normals[normalIndex++] = normal.z;
      }
      if (vertexFormat.tangent) {
        tangents[tangentIndex++] = tangent.x;
        tangents[tangentIndex++] = tangent.y;
        tangents[tangentIndex++] = tangent.z;
      }
      if (vertexFormat.bitangent) {
        bitangents[bitangentIndex++] = bitangent.x;
        bitangents[bitangentIndex++] = bitangent.y;
        bitangents[bitangentIndex++] = bitangent.z;
      }
    }
    var attributes = new GeometryAttributes.GeometryAttributes();
    if (vertexFormat.position) {
      attributes.position = new GeometryAttribute.GeometryAttribute({
        componentDatatype: ComponentDatatype.ComponentDatatype.DOUBLE,
        componentsPerAttribute: 3,
        values: flatPositions
      });
    }
    if (vertexFormat.normal) {
      attributes.normal = new GeometryAttribute.GeometryAttribute({
        componentDatatype: ComponentDatatype.ComponentDatatype.FLOAT,
        componentsPerAttribute: 3,
        values: normals
      });
    }
    if (vertexFormat.tangent) {
      attributes.tangent = new GeometryAttribute.GeometryAttribute({
        componentDatatype: ComponentDatatype.ComponentDatatype.FLOAT,
        componentsPerAttribute: 3,
        values: tangents
      });
    }
    if (vertexFormat.bitangent) {
      attributes.bitangent = new GeometryAttribute.GeometryAttribute({
        componentDatatype: ComponentDatatype.ComponentDatatype.FLOAT,
        componentsPerAttribute: 3,
        values: bitangents
      });
    }
    if (vertexFormat.st) {
      attributes.st = new GeometryAttribute.GeometryAttribute({
        componentDatatype: ComponentDatatype.ComponentDatatype.FLOAT,
        componentsPerAttribute: 2,
        values: textureCoordinates
      });
    }
    return new GeometryAttribute.Geometry({
      attributes: attributes,
      indices: newIndices,
      primitiveType: GeometryAttribute.PrimitiveType.TRIANGLES
    });
  }

  /**
   * A description of a polygon composed of arbitrary coplanar positions.
   *
   * @alias CoplanarPolygonGeometry
   * @constructor
   *
   * @param {Object} options Object with the following properties:
   * @param {PolygonHierarchy} options.polygonHierarchy A polygon hierarchy that can include holes.
   * @param {Number} [options.stRotation=0.0] The rotation of the texture coordinates, in radians. A positive rotation is counter-clockwise.
   * @param {VertexFormat} [options.vertexFormat=VertexFormat.DEFAULT] The vertex attributes to be computed.
   * @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid to be used as a reference.
   * @param {PolygonHierarchy} [options.textureCoordinates] Texture coordinates as a {@link PolygonHierarchy} of {@link Cartesian2} points.
   *
   * @example
   * const polygonGeometry = new Cesium.CoplanarPolygonGeometry({
   *  polygonHierarchy: new Cesium.PolygonHierarchy(
   *     Cesium.Cartesian3.fromDegreesArrayHeights([
   *      -90.0, 30.0, 0.0,
   *      -90.0, 30.0, 300000.0,
   *      -80.0, 30.0, 300000.0,
   *      -80.0, 30.0, 0.0
   *   ]))
   * });
   *
   */
  function CoplanarPolygonGeometry(options) {
    options = defaultValue.defaultValue(options, defaultValue.defaultValue.EMPTY_OBJECT);
    var polygonHierarchy = options.polygonHierarchy;
    var textureCoordinates = options.textureCoordinates;
    //>>includeStart('debug', pragmas.debug);
    Check.Check.defined("options.polygonHierarchy", polygonHierarchy);
    //>>includeEnd('debug');

    var vertexFormat = defaultValue.defaultValue(options.vertexFormat, VertexFormat.VertexFormat.DEFAULT);
    this._vertexFormat = VertexFormat.VertexFormat.clone(vertexFormat);
    this._polygonHierarchy = polygonHierarchy;
    this._stRotation = defaultValue.defaultValue(options.stRotation, 0.0);
    this._ellipsoid = Matrix3.Ellipsoid.clone(defaultValue.defaultValue(options.ellipsoid, Matrix3.Ellipsoid.WGS84));
    this._workerName = "createCoplanarPolygonGeometry";
    this._textureCoordinates = textureCoordinates;

    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    this.packedLength = PolygonGeometryLibrary.PolygonGeometryLibrary.computeHierarchyPackedLength(polygonHierarchy, Matrix3.Cartesian3) + VertexFormat.VertexFormat.packedLength + Matrix3.Ellipsoid.packedLength + (defaultValue.defined(textureCoordinates) ? PolygonGeometryLibrary.PolygonGeometryLibrary.computeHierarchyPackedLength(textureCoordinates, Matrix2.Cartesian2) : 1) + 2;
  }

  /**
   * A description of a coplanar polygon from an array of positions.
   *
   * @param {Object} options Object with the following properties:
   * @param {Cartesian3[]} options.positions An array of positions that defined the corner points of the polygon.
   * @param {VertexFormat} [options.vertexFormat=VertexFormat.DEFAULT] The vertex attributes to be computed.
   * @param {Number} [options.stRotation=0.0] The rotation of the texture coordinates, in radians. A positive rotation is counter-clockwise.
   * @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid to be used as a reference.
   * @param {PolygonHierarchy} [options.textureCoordinates] Texture coordinates as a {@link PolygonHierarchy} of {@link Cartesian2} points.
   * @returns {CoplanarPolygonGeometry}
   *
   * @example
   * // create a polygon from points
   * const polygon = Cesium.CoplanarPolygonGeometry.fromPositions({
   *   positions : Cesium.Cartesian3.fromDegreesArray([
   *     -72.0, 40.0,
   *     -70.0, 35.0,
   *     -75.0, 30.0,
   *     -70.0, 30.0,
   *     -68.0, 40.0
   *   ])
   * });
   * const geometry = Cesium.PolygonGeometry.createGeometry(polygon);
   *
   * @see PolygonGeometry#createGeometry
   */
  CoplanarPolygonGeometry.fromPositions = function (options) {
    options = defaultValue.defaultValue(options, defaultValue.defaultValue.EMPTY_OBJECT);

    //>>includeStart('debug', pragmas.debug);
    Check.Check.defined("options.positions", options.positions);
    //>>includeEnd('debug');

    var newOptions = {
      polygonHierarchy: {
        positions: options.positions
      },
      vertexFormat: options.vertexFormat,
      stRotation: options.stRotation,
      ellipsoid: options.ellipsoid,
      textureCoordinates: options.textureCoordinates
    };
    return new CoplanarPolygonGeometry(newOptions);
  };

  /**
   * Stores the provided instance into the provided array.
   *
   * @param {CoplanarPolygonGeometry} value The value to pack.
   * @param {Number[]} array The array to pack into.
   * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
   *
   * @returns {Number[]} The array that was packed into
   */
  CoplanarPolygonGeometry.pack = function (value, array, startingIndex) {
    //>>includeStart('debug', pragmas.debug);
    Check.Check.typeOf.object("value", value);
    Check.Check.defined("array", array);
    //>>includeEnd('debug');

    startingIndex = defaultValue.defaultValue(startingIndex, 0);
    startingIndex = PolygonGeometryLibrary.PolygonGeometryLibrary.packPolygonHierarchy(value._polygonHierarchy, array, startingIndex, Matrix3.Cartesian3);
    Matrix3.Ellipsoid.pack(value._ellipsoid, array, startingIndex);
    startingIndex += Matrix3.Ellipsoid.packedLength;
    VertexFormat.VertexFormat.pack(value._vertexFormat, array, startingIndex);
    startingIndex += VertexFormat.VertexFormat.packedLength;
    array[startingIndex++] = value._stRotation;
    if (defaultValue.defined(value._textureCoordinates)) {
      startingIndex = PolygonGeometryLibrary.PolygonGeometryLibrary.packPolygonHierarchy(value._textureCoordinates, array, startingIndex, Matrix2.Cartesian2);
    } else {
      array[startingIndex++] = -1.0;
    }
    array[startingIndex++] = value.packedLength;
    return array;
  };
  var scratchEllipsoid = Matrix3.Ellipsoid.clone(Matrix3.Ellipsoid.UNIT_SPHERE);
  var scratchVertexFormat = new VertexFormat.VertexFormat();
  var scratchOptions = {
    polygonHierarchy: {}
  };
  /**
   * Retrieves an instance from a packed array.
   *
   * @param {Number[]} array The packed array.
   * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
   * @param {CoplanarPolygonGeometry} [result] The object into which to store the result.
   * @returns {CoplanarPolygonGeometry} The modified result parameter or a new CoplanarPolygonGeometry instance if one was not provided.
   */
  CoplanarPolygonGeometry.unpack = function (array, startingIndex, result) {
    //>>includeStart('debug', pragmas.debug);
    Check.Check.defined("array", array);
    //>>includeEnd('debug');

    startingIndex = defaultValue.defaultValue(startingIndex, 0);
    var polygonHierarchy = PolygonGeometryLibrary.PolygonGeometryLibrary.unpackPolygonHierarchy(array, startingIndex, Matrix3.Cartesian3);
    startingIndex = polygonHierarchy.startingIndex;
    delete polygonHierarchy.startingIndex;
    var ellipsoid = Matrix3.Ellipsoid.unpack(array, startingIndex, scratchEllipsoid);
    startingIndex += Matrix3.Ellipsoid.packedLength;
    var vertexFormat = VertexFormat.VertexFormat.unpack(array, startingIndex, scratchVertexFormat);
    startingIndex += VertexFormat.VertexFormat.packedLength;
    var stRotation = array[startingIndex++];
    var textureCoordinates = array[startingIndex] === -1.0 ? undefined : PolygonGeometryLibrary.PolygonGeometryLibrary.unpackPolygonHierarchy(array, startingIndex, Matrix2.Cartesian2);
    if (defaultValue.defined(textureCoordinates)) {
      startingIndex = textureCoordinates.startingIndex;
      delete textureCoordinates.startingIndex;
    } else {
      startingIndex++;
    }
    var packedLength = array[startingIndex++];
    if (!defaultValue.defined(result)) {
      result = new CoplanarPolygonGeometry(scratchOptions);
    }
    result._polygonHierarchy = polygonHierarchy;
    result._ellipsoid = Matrix3.Ellipsoid.clone(ellipsoid, result._ellipsoid);
    result._vertexFormat = VertexFormat.VertexFormat.clone(vertexFormat, result._vertexFormat);
    result._stRotation = stRotation;
    result._textureCoordinates = textureCoordinates;
    result.packedLength = packedLength;
    return result;
  };

  /**
   * Computes the geometric representation of an arbitrary coplanar polygon, including its vertices, indices, and a bounding sphere.
   *
   * @param {CoplanarPolygonGeometry} polygonGeometry A description of the polygon.
   * @returns {Geometry|undefined} The computed vertices and indices.
   */
  CoplanarPolygonGeometry.createGeometry = function (polygonGeometry) {
    var vertexFormat = polygonGeometry._vertexFormat;
    var polygonHierarchy = polygonGeometry._polygonHierarchy;
    var stRotation = polygonGeometry._stRotation;
    var textureCoordinates = polygonGeometry._textureCoordinates;
    var hasTextureCoordinates = defaultValue.defined(textureCoordinates);
    var outerPositions = polygonHierarchy.positions;
    outerPositions = arrayRemoveDuplicates.arrayRemoveDuplicates(outerPositions, Matrix3.Cartesian3.equalsEpsilon, true);
    if (outerPositions.length < 3) {
      return;
    }
    var normal = scratchNormal;
    var tangent = scratchTangent;
    var bitangent = scratchBitangent;
    var axis1 = axis1Scratch;
    var axis2 = axis2Scratch;
    var validGeometry = CoplanarPolygonGeometryLibrary.CoplanarPolygonGeometryLibrary.computeProjectTo2DArguments(outerPositions, centerScratch, axis1, axis2);
    if (!validGeometry) {
      return undefined;
    }
    normal = Matrix3.Cartesian3.cross(axis1, axis2, normal);
    normal = Matrix3.Cartesian3.normalize(normal, normal);
    if (!Matrix3.Cartesian3.equalsEpsilon(centerScratch, Matrix3.Cartesian3.ZERO, Math.CesiumMath.EPSILON6)) {
      var surfaceNormal = polygonGeometry._ellipsoid.geodeticSurfaceNormal(centerScratch, surfaceNormalScratch);
      if (Matrix3.Cartesian3.dot(normal, surfaceNormal) < 0) {
        normal = Matrix3.Cartesian3.negate(normal, normal);
        axis1 = Matrix3.Cartesian3.negate(axis1, axis1);
      }
    }
    var projectPoints = CoplanarPolygonGeometryLibrary.CoplanarPolygonGeometryLibrary.createProjectPointsTo2DFunction(centerScratch, axis1, axis2);
    var projectPoint = CoplanarPolygonGeometryLibrary.CoplanarPolygonGeometryLibrary.createProjectPointTo2DFunction(centerScratch, axis1, axis2);
    if (vertexFormat.tangent) {
      tangent = Matrix3.Cartesian3.clone(axis1, tangent);
    }
    if (vertexFormat.bitangent) {
      bitangent = Matrix3.Cartesian3.clone(axis2, bitangent);
    }
    var results = PolygonGeometryLibrary.PolygonGeometryLibrary.polygonsFromHierarchy(polygonHierarchy, hasTextureCoordinates, projectPoints, false);
    var hierarchy = results.hierarchy;
    var polygons = results.polygons;
    var dummyFunction = function dummyFunction(identity) {
      return identity;
    };
    var textureCoordinatePolygons = hasTextureCoordinates ? PolygonGeometryLibrary.PolygonGeometryLibrary.polygonsFromHierarchy(textureCoordinates, true, dummyFunction, false).polygons : undefined;
    if (hierarchy.length === 0) {
      return;
    }
    outerPositions = hierarchy[0].outerRing;
    var boundingSphere = Transforms.BoundingSphere.fromPoints(outerPositions);
    var boundingRectangle = PolygonGeometryLibrary.PolygonGeometryLibrary.computeBoundingRectangle(normal, projectPoint, outerPositions, stRotation, scratchBR);
    var geometries = [];
    for (var i = 0; i < polygons.length; i++) {
      var geometryInstance = new GeometryInstance.GeometryInstance({
        geometry: createGeometryFromPolygon(polygons[i], vertexFormat, boundingRectangle, stRotation, hasTextureCoordinates ? textureCoordinatePolygons[i] : undefined, projectPoint, normal, tangent, bitangent)
      });
      geometries.push(geometryInstance);
    }
    var geometry = GeometryPipeline.GeometryPipeline.combineInstances(geometries)[0];
    geometry.attributes.position.values = new Float64Array(geometry.attributes.position.values);
    geometry.indices = IndexDatatype.IndexDatatype.createTypedArray(geometry.attributes.position.values.length / 3, geometry.indices);
    var attributes = geometry.attributes;
    if (!vertexFormat.position) {
      delete attributes.position;
    }
    return new GeometryAttribute.Geometry({
      attributes: attributes,
      indices: geometry.indices,
      primitiveType: geometry.primitiveType,
      boundingSphere: boundingSphere
    });
  };
  function createCoplanarPolygonGeometry(polygonGeometry, offset) {
    if (defaultValue.defined(offset)) {
      polygonGeometry = CoplanarPolygonGeometry.unpack(polygonGeometry, offset);
    }
    return CoplanarPolygonGeometry.createGeometry(polygonGeometry);
  }
  return createCoplanarPolygonGeometry;
});