import '../core/index.dart';
import 'package:three_js_math/three_js_math.dart';
import 'dart:math' as math;

/// A class for generating sphere geometries.
/// 
/// ```
/// final geometry = SphereGeometry( 15, 32, 16 ); 
/// final material = MeshBasicMaterial({MaterialProperty.color: 0xffff00 } ); 
/// final sphere = Mesh( geometry, material ); 
/// scene.add( sphere );
/// ```
///
class SphereGeometry extends BufferGeometry {

  /// [radius] — sphere radius. Default is `1`.
  /// 
  /// [widthSegments] — number of horizontal segments. Minimum value is `3`, and the
  /// default is `32`.
  /// 
  /// [heightSegments] — number of vertical segments. Minimum value is `2`, and the
  /// default is `16`.
  /// 
  /// [phiStart] — specify horizontal starting angle. Default is `0`.
  /// 
  /// [phiLength] — specify horizontal sweep angle size. Default is Math.PI *
  /// 2.
  /// 
  /// [thetaStart] — specify vertical starting angle. Default is `0`.
  /// 
  /// [thetaLength] — specify vertical sweep angle size. Default is Math.PI.
  /// 
  /// The geometry is created by sweeping and calculating vertexes around the Y
  /// axis (horizontal sweep) and the Z axis (vertical sweep). Thus, incomplete
  /// spheres (akin to `'sphere slices'`) can be created through the use of
  /// different values of phiStart, phiLength, thetaStart and thetaLength, in
  /// order to define the points in which we start (or end) calculating those
  /// vertices.
  /// 
  SphereGeometry([
    double radius = 1,
    int widthSegments = 32,
    int heightSegments = 16,
    double phiStart = 0,
    double phiLength = math.pi * 2,
    double thetaStart = 0,
    double thetaLength = math.pi
  ]):super() {
    type = "SphereGeometry";
    parameters = {
      "radius": radius,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments,
      "phiStart": phiStart,
      "phiLength": phiLength,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    widthSegments = math.max(3, widthSegments);
    heightSegments = math.max(2, heightSegments);

    final thetaEnd = math.min<double>(thetaStart + thetaLength, math.pi);

    int index = 0;
    final grid = [];

    final vertex = Vector3.zero();
    final normal = Vector3.zero();

    // buffers

    List<int> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // generate vertices, normals and uvs

    for (int iy = 0; iy <= heightSegments; iy++) {
      final verticesRow = [];
      final v = iy / heightSegments;
      double uOffset = 0;

      if (iy == 0 && thetaStart == 0) {
        uOffset = 0.5 / widthSegments;
      } else if (iy == heightSegments && thetaEnd == math.pi) {
        uOffset = -0.5 / widthSegments;
      }

      for (int ix = 0; ix <= widthSegments; ix++) {
        final u = ix / widthSegments;

        vertex.x = -radius *
            math.cos(phiStart + u * phiLength) *
            math.sin(thetaStart + v * thetaLength);
        vertex.y = radius * math.cos(thetaStart + v * thetaLength);
        vertex.z = radius *
            math.sin(phiStart + u * phiLength) *
            math.sin(thetaStart + v * thetaLength);

        vertices.addAll([vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        normal.setFrom(vertex);
        normal.normalize();
        normals.addAll([normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);
        uvs.addAll([u + uOffset, 1 - v]);
        verticesRow.add(index++);
      }

      grid.add(verticesRow);
    }

    // indices

    for (int iy = 0; iy < heightSegments; iy++) {
      for (int ix = 0; ix < widthSegments; ix++) {
        final a = grid[iy][ix + 1];
        final b = grid[iy][ix];
        final c = grid[iy + 1][ix];
        final d = grid[iy + 1][ix + 1];

        if (iy != 0 || thetaStart > 0) indices.addAll([a, b, d]);
        if (iy != heightSegments - 1 || thetaEnd < math.pi) {
          indices.addAll([b, c, d]);
        }
      }
    }

    // build geometry

    setIndex(indices);
    setAttributeFromString('position',Float32BufferAttribute.fromList(vertices, 3, false));
    setAttributeFromString('normal',Float32BufferAttribute.fromList(normals, 3, false));
    setAttributeFromString('uv', Float32BufferAttribute.fromList(uvs, 2, false));
  }

  static fromJson(data) {
    return SphereGeometry(
        data["radius"],
        data["widthSegments"],
        data["heightSegments"],
        data["phiStart"],
        data["phiLength"],
        data["thetaStart"],
        data["thetaLength"]);
  }
}
