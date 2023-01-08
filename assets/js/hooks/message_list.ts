import { makeHook, Hook } from "phoenix_typed_hook";

class MessageList extends Hook {
  updated() {
    this.scrollDown();
  }

  private scrollDown() {
    this.el.scrollTo(0, this.el.scrollHeight);
  }
}

export default makeHook(MessageList);
