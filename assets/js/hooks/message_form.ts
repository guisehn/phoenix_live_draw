import { makeHook, Hook } from "phoenix_typed_hook";

class MessageForm extends Hook {
  mounted() {
    const input = this.el.querySelector<HTMLInputElement>("input")!;

    this.el.addEventListener("submit", () => {
      setTimeout(() => {
        input.value = "";
      }, 1);
      input.focus();
    });

    input.addEventListener("blur", () => {
      input.focus();
    });

    input.focus();
  }
}

export default makeHook(MessageForm);
