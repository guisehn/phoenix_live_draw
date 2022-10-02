import DrawEvent from "./draw_event";
import { Coordinates } from "./types";

export type DrawCallback = (path: Coordinates[]) => void;

export type Mode = "draw" | "guess" | null;

export type SetupOptions = {
  frontCanvas: HTMLCanvasElement;
  backCanvas: HTMLCanvasElement;
  mode: Mode;
  onDraw: DrawCallback;
};

class DrawingEngine {
  private mode: Mode;
  private frontCanvas: HTMLCanvasElement;
  private backCanvas: HTMLCanvasElement;
  private drawCallback: (object: Coordinates[]) => void;

  private isDrawing: boolean = false;
  private drawingPath: Coordinates[] = [];

  constructor(options: SetupOptions) {
    this.mode = options.mode;
    this.frontCanvas = options.frontCanvas;
    this.backCanvas = options.backCanvas;
    this.drawCallback = options.onDraw;
  }

  setup() {
    if (this.mode !== "draw") return;

    this.frontCanvas.addEventListener("mousedown", (e) => this.handleEvent(e));
    this.frontCanvas.addEventListener("mouseup", (e) => this.handleEvent(e));
    this.frontCanvas.addEventListener("mousemove", (e) => this.handleEvent(e));
  }

  draw(drawingPath: Coordinates[]) {
    this.drawOn(this.backCanvas, drawingPath);
  }

  private handleEvent(originalEvent: MouseEvent) {
    const event = new DrawEvent(originalEvent);

    switch (event.type) {
      case "start":
        return this.drawingStarted(event);
      case "move":
        return this.cursorMoved(event);
      case "end":
        return this.drawingEnded(event);
    }
  }

  private drawingStarted(event: DrawEvent) {
    this.isDrawing = true;
    console.log("COORDS", event.coordinates);
    this.drawingPath = [event.coordinates];

    this.clearCanvas(this.frontCanvas);
    this.drawOn(this.frontCanvas, this.drawingPath);

    console.log("started");
  }

  private cursorMoved(event: DrawEvent) {
    if (!this.isDrawing) return;

    this.drawingPath.push(event.coordinates);

    this.clearCanvas(this.frontCanvas);
    this.drawOn(this.frontCanvas, this.drawingPath);
  }

  private drawingEnded(event: DrawEvent) {
    if (!this.isDrawing) return;

    this.isDrawing = false;
    this.drawingPath.push(event.coordinates);

    this.clearCanvas(this.frontCanvas);
    this.drawOn(this.backCanvas, this.drawingPath);

    this.drawCallback(this.drawingPath);
    this.drawingPath = [];
  }

  private clearCanvas(canvas: HTMLCanvasElement) {
    const ctx = canvas.getContext("2d")!;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  }

  private drawOn(canvas: HTMLCanvasElement, drawingPath: Coordinates[]) {
    const ctx = canvas.getContext("2d")!;

    ctx.beginPath();
    ctx.lineWidth = 2;
    ctx.strokeStyle = "black";

    console.log({ drawingPath });

    const [first, ...rest] = drawingPath;

    ctx.fillRect(first.x, first.y, ctx.lineWidth, ctx.lineWidth);
    ctx.moveTo(first.x, first.y);

    for (const point of rest) {
      ctx.lineTo(point.x, point.y);
      ctx.stroke();
    }
  }
}

export default DrawingEngine;
