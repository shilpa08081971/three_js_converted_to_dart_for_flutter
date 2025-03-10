part of three_webgl;

class BaseWebGLBufferRenderer {
  void setIndex(value) {
    throw (" BaseWebGLBufferRenderer.setIndex value: $value  ");
  }

  void render(int start, int count) {
    throw (" BaseWebGLBufferRenderer.render start: $start $count  ");
  }

  void renderInstances(int start, int count, int primcount) {
    throw (" BaseWebGLBufferRenderer.renderInstances start: $start $count primcount: $primcount  ");
  }

  void setMode(value) {
    throw (" BaseWebGLBufferRenderer.setMode value: $value ");
  }
}

class WebGLBufferRenderer extends BaseWebGLBufferRenderer {
  RenderingContext gl;
  bool isWebGL2 = true;
  dynamic mode;
  WebGLExtensions extensions;
  WebGLInfo info;
  WebGLCapabilities capabilities;

  WebGLBufferRenderer(this.gl, this.extensions, this.info, this.capabilities) {
    isWebGL2 = capabilities.isWebGL2;
  }

  @override
  void setMode(value) {
    mode = value;
  }

  @override
  void render(int start, int count) {
    gl.drawArrays(mode, start, count);
    info.update(count, mode, 1);
  }

  @override
  void renderInstances(int start, int count, int primcount) {
    if (primcount == 0) return;

    dynamic extension;
    String methodName;

    if (isWebGL2) {
      gl.drawArraysInstanced(mode, start, count, primcount);
    } 
    else {
      extension = extensions.get('ANGLE_instanced_arrays');
      methodName = 'drawArraysInstancedANGLE';

      if (extension == null) {
        console.info('WebGLBufferRenderer: using three.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.');
        return;
      }
      extension[methodName](mode, start, count, primcount);
    }

    info.update(count, mode, primcount);
  }
}
