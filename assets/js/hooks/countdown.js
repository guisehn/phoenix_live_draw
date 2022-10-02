import { makeHook, Hook } from "phoenix_typed_hook";

class Countdown extends Hook {
  mounted() {
    const seconds = this.fetchSeconds();
    const expiration = this.fetchExpiration(seconds);
    const bar = this.el.querySelector("[data-bar]");

    this.interval = setInterval(
      () => this.updateBar(bar, seconds, expiration),
      25
    );
  }

  updateBar(bar, seconds, expiration) {
    const secondsLeft = (expiration - new Date()) / 1000;
    let percentage = (secondsLeft / seconds) * 100;

    if (percentage < 0) {
      percentage = 0;
      clearInterval(this.interval);
    }

    if (secondsLeft <= 5 && !this.pulsing) {
      this.pulsing = true;
      bar.classList.add("animate-[pulse_1s_infinite]");
    }

    bar.style.width = percentage + "%";
  }

  fetchSeconds() {
    if (!("seconds" in this.el.dataset)) {
      throw new Error("Countdown missing 'seconds' assign");
    }

    return Number(this.el.dataset.seconds);
  }

  fetchExpiration(seconds) {
    const date = new Date();
    date.setSeconds(date.getSeconds() + seconds);
    return date;
  }
}

export default makeHook(Countdown);
