import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Import for NativeArray (adjust path if necessary based on your project structure)
import 'package:flutter_angle/native-array/index.dart';

// Import for MaterialProperty (adjust path if necessary)
import 'package:three_js_core/materials/material.dart';

import 'package:three_js/three_js.dart' as three; // Keep the alias
import 'package:three_js_objects/three_js_objects.dart'; // Keep this for MarchingCubes, OrbitControls etc.

/*// --- Main App Setup ---
void main() {
  runApp(const MarchingApp());
}*/

class MarchingApp extends StatelessWidget {
  const MarchingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marching Cubes Demo',
      theme: ThemeData.dark(),
      home: const Marching(),
    );
  }
}

// --- Effect Controller ---
// (EffectController remains the same)
class EffectController {
  EffectController({
    this.material = 'shiny',
    this.speed = 1.0,
    this.numBlobs = 1,
    this.resolution = 28,
    this.isolation = 80,
    this.floor = true,
    this.wallx = false,
    this.wallz = false,
    this.rippleStrength = 1.0,
    this.showWidgetTexture = false,
  });

  String material;
  double speed;
  int numBlobs;
  int resolution;
  int isolation;
  bool floor;
  bool wallx;
  bool wallz;
  double rippleStrength;
  bool showWidgetTexture;
}


// --- Marching Cubes Widget ---
class Marching extends StatefulWidget {
  const Marching({super.key});
  @override
  _MarchingState createState() => _MarchingState();
}

class _MarchingState extends State<Marching> {
  List<int> data = List.filled(60, 0, growable: true);
  Timer? timer;
  late three.ThreeJS threeJs;
  three.OrbitControls? controls;
  late EffectController effectController;
  String currentMaterial = 'shiny';
  MarchingCubes? effect;
  double time = 0;
  bool _isSetupComplete = false;

  three.Vector3? _rippleCenter;
  double _rippleStartTime = -1.0;
  static const double RIPPLE_DURATION = 1.5;

  three.Texture? _widgetTexture;
  final GlobalKey _widgetBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    effectController = EffectController();
    currentMaterial = effectController.material;

    threeJs = three.ThreeJS(
      onSetupComplete: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setup();
        });
      },
      setup: null,
      settings: three.Settings(
        renderOptions: {"format": three.RGBAFormat, "samples": 8},
        useOpenGL: true,
      ),
    );
  }

  void startFpsTimer() {
     timer?.cancel();
     timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Revert to using clock.fps - If this fails later, the source of FPS needs investigation
      // Removed the check for threeJs.Info != null
      if (mounted && _isSetupComplete && threeJs.clock != null) {
        setState(() {
          data.removeAt(0);
          // <<<<<<< FIX 1: Revert to clock.fps >>>>>>>
          data.add(threeJs.clock.fps);
        });
      } else if (!mounted) {
        t.cancel();
      }
      // Add a check in case clock itself becomes null or fps isn't available
      else if (threeJs.clock == null) {
         debugPrint("Warning: threeJs.clock is null, cannot get FPS.");
         // Optionally stop the timer or log an empty value
         // data.add(0);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controls?.dispose();
    _widgetTexture?.dispose();
    threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (Widget build logic remains the same as previous version)
    // ... see previous response ...
     final widgetToCapture = RepaintBoundary(
      key: _widgetBoundaryKey,
      child: Container(
        width: 256,
        height: 128,
        color: Colors.deepPurple, // Changed color for visibility
        padding: const EdgeInsets.all(10),
        child: const Center(
          child: Text(
            'Flutter Power!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.yellowAccent, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marching Cubes Interactive Demo'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: -1000, // Keep offscreen
            top: -1000,
            child: widgetToCapture,
          ),
          GestureDetector(
            onPanDown: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null && _isSetupComplete && effect != null) {
                 final localPosition = renderBox.globalToLocal(details.globalPosition);
                 handleTap(localPosition);
              }
            },
            child: threeJs.build(),
          ),
          // Optional FPS counter
          // Positioned(top: 0, left: 0, child: Statistics(data: data)),
          if (_isSetupComplete)
             Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                color: Colors.black.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildControls(),
                    ),
                  ),
                ),
              ),
            ),
          if (!_isSetupComplete)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  List<Widget> _buildControls() {
    // (UI Control building logic remains the same)
    // ... see previous response ...
     return [
      // --- Material ---
      _buildDropdownControl(
        label: 'Material:',
        value: effectController.material,
        items: generateMaterials().keys.toList(), // Ensure keys are used
        onChanged: (String? newMaterial) {
          if (newMaterial != null && effect != null) { // Check effect non-null
            setState(() {
              effectController.material = newMaterial;
              currentMaterial = newMaterial;
              final materials = generateMaterials();
              // Ensure the key exists before accessing
              if (materials.containsKey(newMaterial)) {
                  effect!.material = materials[newMaterial]!;
                  if (newMaterial == 'widgetTextured' && _widgetTexture != null) {
                      effect!.material?.map = _widgetTexture;
                      effect!.material?.needsUpdate = true;
                  } else if (effect!.material?.map != null) {
                      effect!.material?.map = null;
                      effect!.material?.needsUpdate = true;
                  }
              } else {
                  debugPrint("Warning: Material key '$newMaterial' not found.");
                  // Optionally revert to a default material
                  effect!.material = materials['shiny']!;
              }
            });
          }
        },
      ),
      const SizedBox(height: 5),

      // --- Speed ---
      _buildSliderControl(
        label: 'Speed:',
        value: effectController.speed,
        min: 0.1,
        max: 5.0,
        divisions: 49,
        onChanged: (value) => setState(() => effectController.speed = value),
      ),

      // --- Blobs ---
      _buildCounterControl(
        label: 'Blobs:',
        value: effectController.numBlobs,
        onIncrement: () => setState(() => effectController.numBlobs++),
        onDecrement: () => setState(() => effectController.numBlobs = math.max(1, effectController.numBlobs - 1)),
      ),

      // --- Floor/Walls ---
      _buildSwitchControl(
        label: 'Floor',
        value: effectController.floor,
        onChanged: (val) => setState(() => effectController.floor = val),
      ),
      _buildSwitchControl(
        label: 'Wall X',
        value: effectController.wallx,
        onChanged: (val) => setState(() => effectController.wallx = val),
      ),
      _buildSwitchControl(
        label: 'Wall Z',
        value: effectController.wallz,
        onChanged: (val) => setState(() => effectController.wallz = val),
      ),

      const Divider(color: Colors.white54),

      // --- New Features ---
      const Text("Interactions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

      // --- Ripple Strength ---
      _buildSliderControl(
        label: 'Ripple Strength:',
        value: effectController.rippleStrength,
        min: 0.1,
        max: 5.0,
        divisions: 49,
        onChanged: (value) => setState(() => effectController.rippleStrength = value),
      ),

      // --- Widget Texture ---
      _buildSwitchControl(
        label: 'Show Widget Texture',
        value: effectController.showWidgetTexture,
        onChanged: (val) {
           setState(() {
             effectController.showWidgetTexture = val;
             if(val) {
               effectController.material = 'widgetTextured';
               currentMaterial = 'widgetTextured';
               applyWidgetTexture();
             } else if (effectController.material == 'widgetTextured') {
               effectController.material = 'shiny'; // Default back
               currentMaterial = 'shiny';
               if(effect != null) {
                 effect!.material = generateMaterials()['shiny']!;
                 effect!.material?.map = null;
                 effect!.material?.needsUpdate = true;
               }
             }
           });
        }
      ),
      const SizedBox(height: 10),
    ];
  }

  // --- Helper Widgets for Controls ---
  // (Control helper widgets remain the same)
  // ... see previous response ...
    Widget _buildDropdownControl({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        DropdownButton<String>(
          value: value,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

   Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.blueGrey,
          ),
        ),
        Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)), // Show value next to slider
      ],
    );
  }

  Widget _buildCounterControl({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const Spacer(), // Push controls to the right
        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.white70), onPressed: onDecrement, iconSize: 20,),
        Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white70), onPressed: onIncrement, iconSize: 20,),
      ],
    );
  }

   Widget _buildSwitchControl({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.lightBlueAccent,
        ),
      ],
    );
  }

  // --- Core Logic ---

  Future<void> setup() async {
    if (!mounted) return;

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(0x050505);
    threeJs.camera = three.PerspectiveCamera(45, threeJs.width / threeJs.height, 1, 10000);
    threeJs.camera.position.setValues(-700, 500, 700);

    // Lighting...
    final light = three.DirectionalLight(0xffffff, 3);
    light.position.setValues(0.5, 0.5, 1);
    threeJs.scene.add(light);
    final pointLight = three.PointLight(0xff7c00, 5, 0, 0);
    pointLight.position.setValues(0, 0, 100);
    threeJs.scene.add(pointLight);
    final ambientLight = three.AmbientLight(0x323232, 1);
    threeJs.scene.add(ambientLight);

    final materials = generateMaterials();
    effect = MarchingCubes(
      effectController.resolution.toDouble(),
      materials[currentMaterial]!,
      true, true, 100000,
    );
    effect!.position.setValues(0, 0, 0);
    effect!.scale.setValues(700, 700, 700);
    threeJs.scene.add(effect!);

    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    controls!.minDistance = 300;
    controls!.maxDistance = 4000;
    controls!.enablePan = true;

    if (mounted) {
       setState(() => _isSetupComplete = true);
       startFpsTimer();
    }

    threeJs.addAnimationEvent((dt) {
       if(!mounted || effect == null || controls == null) return;
       time += dt * effectController.speed * 0.5;
       controls!.update();
       updateCubes(
         effect!, time, effectController.numBlobs,
         effectController.floor, effectController.wallx, effectController.wallz,
         _rippleCenter, _rippleStartTime, effectController.rippleStrength,
       );
       if (_rippleCenter != null && (time - _rippleStartTime) > RIPPLE_DURATION) {
           _rippleCenter = null;
           _rippleStartTime = -1.0;
       }
    });

    if (effectController.showWidgetTexture) await applyWidgetTexture();
  }

  // (updateCubes logic remains the same)
  // ... see previous response ...
  void updateCubes(
    MarchingCubes object, double time, int numBlobs,
    bool floor, bool wallx, bool wallz,
    three.Vector3? rippleCenter, double rippleStartTime, double rippleStrength,
  ) {
    object.reset();

    final rainbow = [
      three.Color(0xff0000), three.Color(0xffbb00), three.Color(0xffff00),
      three.Color(0x00ff00), three.Color(0x0000ff), three.Color(0x9400bd),
      three.Color(0xc800eb),
    ]; // Use three.Color directly
    const subtract = 12;
    final baseStrength = 1.2 / ((math.sqrt(numBlobs) - 1) / 4 + 1);

    for (int i = 0; i < numBlobs; i++) {
      final ballx = math.sin(i + 1.26 * time * (1.03 + 0.5 * math.cos(0.21 * i))) * 0.27 + 0.5;
      final bally = math.cos(i + 1.12 * time * math.cos(1.22 + 0.1424 * i)).abs() * 0.77;
      final ballz = math.cos(i + 1.32 * time * 0.1 * math.sin((0.92 + 0.53 * i))) * 0.27 + 0.5;

      if (currentMaterial == 'multiColors') {
        object.addBall(ballx, bally, ballz, baseStrength, subtract, rainbow[i % rainbow.length]);
      } else {
        object.addBall(ballx, bally, ballz, baseStrength, subtract);
      }
    }

    if (rippleCenter != null && time - rippleStartTime <= RIPPLE_DURATION) {
      const rippleRadius = 0.2;
      final double rippleTimeElapsed = time - rippleStartTime;
      final double res = object.resolution;
      final three.Vector3 rippleCenterNormalized = rippleCenter.clone().divide(object.scale);

      // Performance optimization: iterate only near the ripple
      final int minX = math.max(0, ((rippleCenterNormalized.x - rippleRadius * 1.5) * res).floor());
      final int maxX = math.min(res.toInt(), ((rippleCenterNormalized.x + rippleRadius * 1.5) * res).ceil());
      final int minY = math.max(0, ((rippleCenterNormalized.y - rippleRadius * 1.5) * res).floor());
      final int maxY = math.min(res.toInt(), ((rippleCenterNormalized.y + rippleRadius * 1.5) * res).ceil());
      final int minZ = math.max(0, ((rippleCenterNormalized.z - rippleRadius * 1.5) * res).floor());
      final int maxZ = math.min(res.toInt(), ((rippleCenterNormalized.z + rippleRadius * 1.5) * res).ceil());

      for (int i = minX; i < maxX; i++) {
        for (int j = minY; j < maxY; j++) {
          for (int k = minZ; k < maxZ; k++) {
            final voxelPosNormalized = three.Vector3(i / res, j / res, k / res);
            final distance = rippleCenterNormalized.distanceTo(voxelPosNormalized);

            if (distance < rippleRadius && distance > 0.001) {
              final double rippleValue = math.sin(distance * 20 - rippleTimeElapsed * 10)
                  * rippleStrength
                  / (distance * 20 + 1)
                  * math.max(0.0, (1.0 - rippleTimeElapsed / RIPPLE_DURATION)); // Ensure non-negative multiplier

              object.addBall(
                voxelPosNormalized.x, voxelPosNormalized.y, voxelPosNormalized.z,
                rippleValue * 0.1, // Scale ripple influence
                subtract,
              );
            }
          }
        }
      }
    }

    if (floor) object.addPlaneY(2, subtract);
    if (wallz) object.addPlaneZ(2, subtract);
    if (wallx) object.addPlaneX(2, subtract);

    object.update();
  }


  // (handleTap logic remains the same)
  // ... see previous response ...
   void handleTap(Offset tapPosition) {
     if (effect == null || !_isSetupComplete) return;

    final ndcX = (tapPosition.dx / threeJs.width) * 2 - 1;
    final ndcY = -(tapPosition.dy / threeJs.height) * 2 + 1;

    final raycaster = three.Raycaster();
    if (threeJs.camera == null) return;
    raycaster.setFromCamera(three.Vector2(ndcX, ndcY), threeJs.camera!);

    final intersects = raycaster.intersectObject(effect!);

    if (intersects.isNotEmpty) {
      final intersection = intersects.first;
      final point = intersection.point;

      if (point != null) {
          _rippleCenter = point;
          _rippleStartTime = time;
      } else {
        debugPrint("Intersection point is null, cannot start ripple.");
      }
    }
  }


  Future<three.Texture?> createWidgetTexture() async {
    try {
      if (_widgetBoundaryKey.currentContext == null) {
         debugPrint("Widget boundary context null");
         return null;
      }
      RenderRepaintBoundary boundary = _widgetBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await Future.delayed(const Duration(milliseconds: 100));
      ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final height = image.height;
      image.dispose();

      if (byteData != null) {
        // <<<<<<< FIX: Use concrete Uint8Array instead of abstract NativeArray >>>>>>>
        final nativeData = Uint8Array.fromList(byteData.buffer.asUint8List()); // Use Uint8Array.fromList

        final texture = three.DataTexture(
          nativeData, // Use the Uint8Array
          width, height,
          three.RGBAFormat, three.UnsignedByteType,
        );
        texture.needsUpdate = true;
        debugPrint("Texture created: ${width}x$height");
        return texture;
      } else {
        debugPrint("ByteData null");
      }
    } catch (e, stacktrace) {
      debugPrint("Error creating widget texture: $e\n$stacktrace");
    }
    return null;
  }

  // (applyWidgetTexture logic remains the same)
  // ... see previous response ...
  Future<void> applyWidgetTexture() async {
    if (effect == null) {
       debugPrint("Cannot apply texture: effect is null.");
       return;
    }

    _widgetTexture?.dispose(); // Dispose previous
    _widgetTexture = await createWidgetTexture();

    if (_widgetTexture != null && effect!.material != null) {
      if (effectController.material == 'widgetTextured') {
         effect!.material!.map = _widgetTexture;
         effect!.material!.needsUpdate = true;
         debugPrint("Widget texture applied to material.");
      } else {
         debugPrint("Widget texture created but current material is not 'widgetTextured'.");
      }
    } else if (_widgetTexture == null) {
       debugPrint("Failed to create widget texture.");
    } else {
       debugPrint("Cannot apply texture: effect material is null.");
    }
  }


  // Generates the material map
  Map<String, three.Material> generateMaterials() {
    // <<<<<<< FIX 2 & 3: Revert to Map-based constructor with MaterialProperty keys >>>>>>>
    final Map<String, three.Material> materials = {
      'shiny': three.MeshStandardMaterial({
        MaterialProperty.color: three.Color(0x9c0000), // Use Enum
        MaterialProperty.roughness: 0.1,
        MaterialProperty.metalness: 1.0,
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false
      }),
      'chrome': three.MeshLambertMaterial({
        MaterialProperty.color: three.Color(0xffffff),
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false
      }),
      'liquid': three.MeshLambertMaterial({
        MaterialProperty.color: three.Color(0x87ceeb),
        MaterialProperty.refractionRatio: 0.85,
        MaterialProperty.reflectivity: 0.9,
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false
      }),
      'matte': three.MeshPhongMaterial({
        MaterialProperty.color: three.Color(0x005500),
        MaterialProperty.specular: three.Color(0x111111), // Specular is also a Color
        MaterialProperty.shininess: 1,
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false
      }),
      'flat': three.MeshLambertMaterial({
        MaterialProperty.color: three.Color(0xffddcc),
        MaterialProperty.flatShading: true,
        MaterialProperty.vertexColors: false
      }),
      'plastic': three.MeshPhongMaterial({
        MaterialProperty.color: three.Color(0xff414141),
        MaterialProperty.specular: three.Color(0x808080), // << FIX 3: Use Hex for 0.5,0.5,0.5 gray
        MaterialProperty.shininess: 30,
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false
      }),
      'colors': three.MeshPhongMaterial({
         // MaterialProperty.color: three.Color(0xffffff), // Optional base if vertex colors don't cover
         MaterialProperty.specular: three.Color(0xffffff),
         MaterialProperty.shininess: 2,
         MaterialProperty.vertexColors: true, // Enable vertex colors
         MaterialProperty.flatShading: false
      }),
      'multiColors': three.MeshPhongMaterial({
         // No base color needed
         MaterialProperty.shininess: 2,
         MaterialProperty.vertexColors: true, // Enable vertex colors
         MaterialProperty.flatShading: false
      }),
      'widgetTextured': three.MeshStandardMaterial({
        MaterialProperty.color: three.Color(0xffffff), // Base color
        MaterialProperty.roughness: 0.8,
        MaterialProperty.metalness: 0.1,
        MaterialProperty.flatShading: false,
        MaterialProperty.vertexColors: false,
        // MaterialProperty.map: _widgetTexture // Applied dynamically
      }),
    };

    materials.forEach((key, value) {
       // Make sure setting side via property works, otherwise set it in the map too
      // value.side = three.DoubleSide; // This might not work if properties are immutable after creation
       value.setValue(MaterialProperty.side, three.DoubleSide); // Try setting via setValue
    });

    return materials;
  }
}

// --- Statistics Widget Placeholder ---
// (Statistics widget remains the same)
// ... see previous response ...
class Statistics extends StatelessWidget {
  final List<int> data;
  const Statistics({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final fps = data.isNotEmpty ? data.last : 0;
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black.withOpacity(0.5),
      child: Text('FPS: $fps', style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

/*
import 'package:example/src/statistics.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_objects/three_js_objects.dart';

class EffectController{
  EffectController({
    this.material = 'shiny',
    this.speed = 1.0,
    this.numBlobs = 10,
    this.resolution = 28,
    this.isolation = 80,

    this.floor = true,
    this.wallx = false,
    this.wallz = false,
    Function()? dummy
  }){
    this.dummy = dummy ?? (){};

  }

  String material;
  double speed;
  int numBlobs;
  int resolution;
  int isolation;
  bool floor;
  bool wallx;
  bool wallz;

  late Function? dummy;
}

class Marching extends StatefulWidget {
  const Marching({super.key});

  @override
  _MarchingState createState() => _MarchingState();
}

class _MarchingState extends State<Marching> {
  List<int> data = List.filled(60, 0, growable: true);
  late Timer timer;
  late three.ThreeJS threeJs;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (t){
      setState(() {
        data.removeAt(0);
        data.add(threeJs.clock.fps);
      });
    });
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});},
      setup: setup,
      settings: three.Settings(
        renderOptions: {"format": three.RGBAFormat,"samples": 8},
        useOpenGL: useOpenGL
      )
    );
    super.initState();
  }
  @override
  void dispose() {
    controls.dispose();
    timer.cancel();
    threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          threeJs.build(),
          Statistics(data: data)
        ],
      ) 
    );
  }
  
  late three.OrbitControls controls;
  late EffectController effectController;
  String currentMaterial = 'shiny';
  late MarchingCubes effect;
  double time = 0;

	// this controls content of marching cubes voxel field
  void updateCubes(MarchingCubes object, double time, int numblobs, bool floor, bool wallx, bool wallz ) {
    object.reset();

    // fill the field with some metaballs
    final rainbow = [
      three.Color.fromHex32( 0xff0000 ),
      three.Color.fromHex32( 0xffbb00 ),
      three.Color.fromHex32( 0xffff00 ),
      three.Color.fromHex32( 0x00ff00 ),
      three.Color.fromHex32( 0x0000ff ),
      three.Color.fromHex32( 0x9400bd ),
      three.Color.fromHex32( 0xc800eb )
    ];

    const subtract = 12;
    final strength = 1.2 / ( ( math.sqrt( numblobs ) - 1 ) / 4 + 1 );

    for (int i = 0; i < numblobs; i ++ ) {

      final ballx = math.sin( i + 1.26 * time * ( 1.03 + 0.5 * math.cos( 0.21 * i ) ) ) * 0.27 + 0.5;
      final bally = ( math.cos( i + 1.12 * time * math.cos( 1.22 + 0.1424 * i ) ) ).abs() * 0.77; // dip into the floor
      final ballz = math.cos( i + 1.32 * time * 0.1 * math.sin( ( 0.92 + 0.53 * i ) ) ) * 0.27 + 0.5;

      if(currentMaterial == 'multiColors' ) {
        object.addBall( ballx, bally, ballz, strength, subtract, rainbow[ i % 7 ] );
      } 
      else {
        object.addBall( ballx, bally, ballz, strength, subtract );
      }
    }

    if ( floor ) object.addPlaneY( 2, 12 );
    if ( wallz ) object.addPlaneZ( 2, 12 );
    if ( wallx ) object.addPlaneX( 2, 12 );

    object.update();

  }
  Future<void> setup() async {
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32( 0x050505 );

    threeJs.camera = three.PerspectiveCamera(45, threeJs.width / threeJs.height, 1, 10000);
    threeJs.camera.position.setValues( - 500, 500, 1500 );

    // lights
    three.DirectionalLight light = three.DirectionalLight( 0xffffff, 5 );
    light.position.setValues( 0.5, 0.5, 1 );
    threeJs.scene.add(light);

    three.PointLight pointLight = three.PointLight( 0xff7c00, 5, 0, 0 );
    pointLight.position.setValues( 0, 0, 100 );
    threeJs.scene.add( pointLight );

    three.AmbientLight ambientLight = three.AmbientLight( 0x323232, 5 );
    threeJs.scene.add( ambientLight );

    // MATERIALS
    Map<String,three.Material> materials = generateMaterials();

    // MARCHING CUBES

    double resolution = 28;

    effect = MarchingCubes(resolution, materials[currentMaterial], true, true, 100000 );
    effect.position.setValues( 0, 0, 0 );
    effect.scale.setValues( 700, 700, 700 );

    effect.enableUvs = false;
    effect.enableColors = false;

    threeJs.scene.add( effect );

    // CONTROLS
    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    controls.minDistance = 500;
    controls.maxDistance = 5000;

    effectController = EffectController(
      material: 'shiny',
      speed: 1.0,
      numBlobs: 10,
      resolution: 28,
      isolation: 80,
      floor: true,
      wallx: false,
      wallz: false,
    );

    threeJs.addAnimationEvent((dt){
      controls.update();
      time += dt * effectController.speed * 0.5;
      updateCubes(effect, time, effectController.numBlobs, effectController.floor, effectController.wallx, effectController.wallz );
    });
  }

  Map<String,three.Material> generateMaterials() {
    final materials = {
				'shiny': three.MeshStandardMaterial.fromMap( { 'color': 0x9c0000, 'roughness': 0.1, 'metalness': 1.0 } ),
				'chrome': three.MeshLambertMaterial.fromMap( { 'color': 0xffffff} ),
				'liquid': three.MeshLambertMaterial.fromMap( { 'color': 0xffffff, 'refractionRatio': 0.85 } ),
				'matte': three.MeshPhongMaterial.fromMap( { 'specular': 0x494949, 'shininess': 1 } ),
				'flat': three.MeshLambertMaterial.fromMap( {'flatShading': true} ),
				'textured': three.MeshPhongMaterial.fromMap( { 'color': 0xffffff, 'specular': 0x111111, 'shininess': 1} ),
				'colors': three.MeshPhongMaterial.fromMap( { 'color': 0xffffff, 'specular': 0xffffff, 'shininess': 2, 'vertexColors': true } ),
				'multiColors': three.MeshPhongMaterial.fromMap( { 'shininess': 2, 'vertexColors': true } ),
				'plastic': three.MeshPhongMaterial.fromMap( { 'color': 0xff414141,'specular': three.Color(0.5, 0.5, 0.5), 'shininess': 15 } ),
    };
    return materials;
  }
}
*/
