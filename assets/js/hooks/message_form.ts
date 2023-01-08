import { makeHook, Hook } from "phoenix_typed_hook";

class MessageForm extends Hook {
  private input: HTMLInputElement;

  mounted() {
    this.input = this.el.querySelector<HTMLInputElement>("input")!;
    this.clearOnSubmit();
    this.persistentFocus();
  }

  private clearOnSubmit() {
    const { el, input } = this;

    el.addEventListener("submit", () => {
      setTimeout(() => {
        input.value = "";
      }, 1);
      input.focus();
    });
  }

  private persistentFocus() {
    const { input } = this;

    input.addEventListener("blur", () => {
      if (!this.isModalOpen()) {
        input.focus();
      }
    });

    if (!this.isModalOpen()) input.focus();
  }

  private isModalOpen() {
    return Boolean(document.querySelector("[data-modal]"));
  }
}

export default makeHook(MessageForm);
