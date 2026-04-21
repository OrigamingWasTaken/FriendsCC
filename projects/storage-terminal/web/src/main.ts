import App from "./App.svelte";
import { mount } from "svelte";
import { connect } from "./lib/ws";

const app = mount(App, { target: document.getElementById("app")! });

connect();

export default app;
