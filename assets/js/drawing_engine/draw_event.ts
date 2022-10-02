import type { Coordinates } from "./types";

export type EventType = "start" | "move" | "end" | "unknown";

/**
 * Represents a drawing event.
 *
 * It abstracts mouse and touch events, providing a common API for dealing
 * with 'start', 'move' and 'end' actions, as long as access to draw coordinates.
 */
export default class DrawEvent {
  private event: MouseEvent;
  private _coordinates?: Coordinates;

  constructor(event: MouseEvent) {
    this.event = event;
  }

  get coordinates(): Coordinates {
    this.buildCoordinates();
    return this._coordinates!;
  }

  get originalEvent(): MouseEvent {
    return this.event;
  }

  get type(): EventType {
    // TODO: deal with touch events
    switch (this.originalEvent.type) {
      case "mousedown":
        return "start";
      case "mousemove":
        return "move";
      case "mouseup":
        return "end";
      default:
        return "unknown";
    }
  }

  private buildCoordinates() {
    if (this._coordinates) return;

    const e = this.event as MouseEvent;
    this._coordinates = { x: e.offsetX, y: e.offsetY };
  }
}
