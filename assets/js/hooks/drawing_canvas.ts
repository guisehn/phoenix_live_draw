import DrawingEngine, { Mode } from "../drawing_engine/drawing_engine";
import { Coordinates } from "../drawing_engine/types";
import { makeHook, Hook } from "phoenix_typed_hook";

class DrawingCanvas extends Hook {
  private mode: Mode;
  private engine: DrawingEngine;

  mounted() {
    this.mode = this.el.dataset.mode as Mode;

    const [frontCanvas, backCanvas] = [
      this.createCanvas({ zIndex: 2 }),
      this.createCanvas({ zIndex: 1 }),
    ];

    this.engine = new DrawingEngine({
      frontCanvas,
      backCanvas,
      mode: this.mode,
      onDraw: (path) => this.currentUserDrew(path),
    });

    this.engine.setup();

    this.handleEvent("draw", (path) => this.otherUserDrew(path));
  }

  private createCanvas({ zIndex }: { zIndex: number }) {
    const canvas = document.createElement("canvas");
    canvas.width = 660;
    canvas.height = 390;
    canvas.className =
      "absolute top-0 left-0 w-full h-full " +
      (this.mode === "draw" ? "cursor-crosshair" : "");
    canvas.style.zIndex = zIndex.toString();
    this.el.appendChild(canvas);
    return canvas;
  }

  private currentUserDrew(_path: Coordinates[]) {
    // TODO: send to server
  }

  private otherUserDrew(path: Coordinates[]) {
    this.engine.draw(path);
  }
}

export default makeHook(DrawingCanvas);